##################################
# Development of a Targeting Scorecard for DRC
# APP-FA Targeting Team
# Data source: EFSA 2025
# Script 1 of 1 - OLS and Machine Learning Models Development
##################################
rm(list = ls())
gc()

#--------------------------
# Load Libraries
#--------------------------
library(tidyverse)
library(car)
library(scales)
library(caret)          # for preprocessing and model pipelines
library(glmnet)         # for Lasso/Ridge
library(randomForest)   # for Random Forest
library(xgboost)        # for Gradient Boosting
library(Metrics)
library(gridExtra)
library(grid)
library(doParallel)
library(doRNG)         
library(gt)
library(Boruta) 
library(detectseparation)
library(margins)  
library(pROC)
library(openxlsx)

set.seed(123)  # global seed for reproducibility


#--------------------------
# Functions
#--------------------------
# round up function
round_up <- function(x, digits = 0) {
  pos <- 10^digits
  ceiling(x * pos) / pos
}

# univariate logistic analysis function
screen_univariate_logit_robust <- function(df, y, alpha = 0.05, adjust = "BH", fisher_fallback = TRUE) {
  stopifnot(y %in% names(df))
  df <- as.data.frame(df)
  df[] <- lapply(df, function(x) if (is.character(x)) factor(x) else x)
  
  # Ensure binary outcome
  if (is.factor(df[[y]])) {
    if (nlevels(df[[y]]) != 2) stop("Dependent variable must be binary (2 levels).")
    df[[y]] <- droplevels(df[[y]])
  } else {
    u <- unique(na.omit(df[[y]]))
    if (!all(u %in% c(0, 1))) stop("Dependent variable must be 0/1 or a 2-level factor.")
    df[[y]] <- factor(df[[y]], levels = c(0, 1))
  }
  
  preds <- setdiff(names(df), y)
  
  rows <- lapply(preds, function(p) {
    d <- df[, c(y, p)]
    d <- stats::na.omit(d)
    # Skip if empty
    if (nrow(d) == 0) {
      return(data.frame(predictor = p, class = class(df[[p]])[1], levels = if (is.factor(df[[p]])) paste(levels(df[[p]]), collapse = "|") else NA_character_,
                        n = 0, test = NA_character_, p_value = NA_real_, padj = NA_real_,
                        OR = NA_real_, OR_low = NA_real_, OR_high = NA_real_,
                        stringsAsFactors = FALSE))
    }
    
    # Constant predictor?
    constant <- (is.factor(d[[p]]) && nlevels(d[[p]]) < 2) ||
      (is.numeric(d[[p]]) && (is.na(stats::sd(d[[p]])) || stats::sd(d[[p]]) == 0))
    if (constant) {
      return(data.frame(predictor = p, class = class(d[[p]])[1],
                        levels = if (is.factor(d[[p]])) paste(levels(d[[p]]), collapse = "|") else NA_character_,
                        n = nrow(d), test = "constant", p_value = NA_real_, padj = NA_real_,
                        OR = NA_real_, OR_low = NA_real_, OR_high = NA_real_,
                        stringsAsFactors = FALSE))
    }
    
    # Try GLM
    m0 <- tryCatch(stats::glm(stats::reformulate(NULL, y), data = d, family = stats::binomial()),
                   error = function(e) NULL)
    m1 <- tryCatch(stats::glm(stats::reformulate(p,    y), data = d, family = stats::binomial()),
                   error = function(e) NULL)
    
    get_or_from_glm <- function(mod) {
      cf <- summary(mod)$coef
      if (nrow(cf) >= 2) {
        beta <- cf[2, 1]; se <- cf[2, 2]
        c(OR = exp(beta), OR_low = exp(beta - 1.96 * se), OR_high = exp(beta + 1.96 * se))
      } else c(OR = NA_real_, OR_low = NA_real_, OR_high = NA_real_)
    }
    
    # Default: attempt LR test
    if (!is.null(m0) && !is.null(m1)) {
      a <- tryCatch(stats::anova(m0, m1, test = "Chisq"), error = function(e) NULL)
      if (!is.null(a)) {
        pval <- a$`Pr(>Chi)`[2]
        ORs <- get_or_from_glm(m1)
        if (!is.na(pval)) {
          return(data.frame(predictor = p, class = class(d[[p]])[1],
                            levels = if (is.factor(d[[p]])) paste(levels(d[[p]]), collapse = "|") else NA_character_,
                            n = stats::nobs(m1), test = "LR",
                            p_value = pval, padj = NA_real_,
                            OR = ORs["OR"], OR_low = ORs["OR_low"], OR_high = ORs["OR_high"],
                            stringsAsFactors = FALSE))
        }
      }
    }
    
    # Fisher fallback for 2x2
    if (fisher_fallback) {
      tab <- table(d[[y]], d[[p]])
      if (all(dim(tab) == c(2, 2))) {
        ft <- stats::fisher.test(tab)
        # Haldane–Anscombe correction for OR and CI if any zero cell
        a <- tab[1,1]; b <- tab[1,2]; c <- tab[2,1]; d2 <- tab[2,2]
        if (any(c(a,b,c,d2) == 0)) {
          a <- a + 0.5; b <- b + 0.5; c <- c + 0.5; d2 <- d2 + 0.5
        }
        or  <- (a * d2) / (b * c)
        se  <- sqrt(1/a + 1/b + 1/c + 1/d2)
        ciL <- exp(log(or) - 1.96 * se)
        ciU <- exp(log(or) + 1.96 * se)
        
        return(data.frame(predictor = p, class = class(d[[p]])[1],
                          levels = if (is.factor(d[[p]])) paste(levels(d[[p]]), collapse = "|") else NA_character_,
                          n = sum(tab), test = "Fisher",
                          p_value = unname(ft$p.value), padj = NA_real_,
                          OR = unname(or), OR_low = unname(ciL), OR_high = unname(ciU),
                          stringsAsFactors = FALSE))
      }
    }
    
    # If we reach here, no test was possible
    data.frame(predictor = p, class = class(d[[p]])[1],
               levels = if (is.factor(d[[p]])) paste(levels(d[[p]]), collapse = "|") else NA_character_,
               n = nrow(d), test = NA_character_, p_value = NA_real_, padj = NA_real_,
               OR = NA_real_, OR_low = NA_real_, OR_high = NA_real_,
               stringsAsFactors = FALSE)
  })
  
  out <- do.call(rbind, rows)
  out$padj <- p.adjust(out$p_value, method = adjust)
  out$significant <- !is.na(out$padj) & out$padj < alpha
  out <- out[order(out$padj), ]
  rownames(out) <- NULL
  out
}


#--------------------------
# Setup Parallel Backend
#--------------------------
cl <- makeCluster(parallel::detectCores() - 1)
registerDoParallel(cl)
registerDoRNG(123)  # ensures reproducible parallel loops

#--------------------------
# Load & preprocess data
#--------------------------
data <- readRDS("./output/targeting_dataset.rds") %>% filter(final_cohort == TRUE)

prop.table(table(data$FSI_CARI2_2class))*100  ## 74% of the population is food insecure
prop.table(table(data$FSI_CARI2_4class))*100

# Create variables for targeting indicators
data <- data %>% mutate(
                        FemHHH = case_when(SexHHH_Ok == "Female" ~ "Yes",  TRUE ~ "No"),
                        HHHDisplArriveDate = as_datetime(HHHDisplArrive/10, origin = "1970-01-01", tz = "Africa/Kinshasa"),
                        HHHDisplArriveYrsNb = as.numeric(difftime(Sys.Date(), HHHDisplArriveDate, units = "days") / 365.25),
                        FSI_CARI2_2classBin = ifelse(FSI_CARI2_2class == "Food insecure", 1,0))

# Assets Stuff
data <- data %>%
  mutate(across(starts_with("HHAsset"), 
                ~ ifelse(!is.na(.) & . >=1, "Yes", "No"), 
                .names = "Targ_{.col}_YN"))


# Create dummy variables for scorecard
data <- data %>%
  mutate(
    Targ_HHSize1 = factor(if_else(HHSize == 1, 1, 0),
                     levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 1
    
    Targ_HHSize1ElderlyHHH = factor(if_else(HHSize == 1 & AgeHHH_Ok >= 60, 1, 0),
                               levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 1 and Elderly
    
    Targ_HHSize1ElderlyFemHHH = factor(if_else(HHSize == 1 & AgeHHH_Ok >= 60 & FemHHH == "Yes", 1, 0),
                                  levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 1, Elderly and a Woman
    
    Targ_HHMinorHHH = factor(if_else(AgeHHH_Ok < 18, 1, 0),
                        levels = c(1, 0), labels = c("Yes","No")), ## HH is under 18 years old
    
    Targ_HHSize1U30HHH = factor(if_else(HHSize == 1 & AgeHHH_Ok <= 30 , 1, 0),
                           levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 1 and under 30 years old
    
    Targ_HHSize1U30FemHHH = factor(if_else(HHSize == 1 & AgeHHH_Ok <= 30 & FemHHH == "Yes", 1, 0),
                              levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 1, under 30 years old and a Woman
    
    Targ_HHSize4plus = factor(if_else(HHSize >= 4, 1, 0),
                         levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 4 or more
    
    Targ_HHSize5plus = factor(if_else(HHSize >= 5, 1, 0),
                         levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 5 or more
    
    Targ_HHSize6plus = factor(if_else(HHSize >= 6, 1, 0),
                         levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 6 or more
    
    Targ_HHSize7plus = factor(if_else(HHSize >= 7, 1, 0),
                         levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 7 or more
    
    Targ_HHSize8plus = factor(if_else(HHSize >= 8, 1, 0),
                         levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 8 or more
    
    Targ_HHSize9plus = factor(if_else(HHSize >= 9, 1, 0),
                         levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 9 or more
    
    Targ_HHSize10plus = factor(if_else(HHSize >= 10, 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## HH is Size 19 or more
    
    Targ_HHAllElderly = factor(if_else(HHSize60AboveM + HHSize60AboveF == HHSize, 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## HH is all elderly 60+
    
    Targ_HHHElderly = factor(if_else(AgeHHH_Ok >= 60, 1, 0),
                        levels = c(1, 0), labels = c("Yes","No")), ## HHH Elderly
    
    Targ_HHHElderlyFem = factor(if_else(AgeHHH_Ok >= 60 & FemHHH == "Yes", 1, 0),
                           levels = c(1, 0), labels = c("Yes","No")), ## HHH Elderly and Woman
    
    DepRatio = (HHSize01M + HHSize01F + HHSize24M + HHSize24F + 
                  HHSize511M + HHSize511F + HHSize1217M + HHSize1217F +
                  HHSize60AboveM + HHSize60AboveF)/(HHSize1859M + HHSize1859F),
    
    DepRatio = if_else(is.na(DepRatio), 0, DepRatio),
    
    Targ_HHDepRatio2plus = factor(if_else(DepRatio >= 2, 1, 0),
                             levels = c(1, 0), labels = c("Yes","No")), ## HH dependency ratio is above 2
    
    Targ_ChildU1 = factor(if_else(HHSize01M + HHSize01F > 0, 1, 0),
                     levels = c(1, 0), labels = c("Yes","No")), ## Any Child Under 1 year
    
    Targ_ChildU5 = factor(if_else(HHSize24M + HHSize24F > 0, 1, 0),
                     levels = c(1, 0), labels = c("Yes","No")), ## Any Child Under 5 years
    
    Targ_ChildU12more = factor(if_else(HHSize01M + HHSize01F > 1, 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## Two or More Children Under 1 year
    
    Targ_ChildU52more = factor(if_else(HHSize24M + HHSize24F > 1, 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## Two or More Children Under 5 years
    
    Targ_HHHFemChildU1 = factor(if_else(HHSize01M + HHSize01F > 0 & FemHHH == "Yes", 1, 0),
                           levels = c(1, 0), labels = c("Yes","No")), ## Any Child Under 1 year and Female Headed
    
    Targ_HHHFemChildU5 = factor(if_else(HHSize24M + HHSize24F > 0 & FemHHH == "Yes", 1, 0),
                           levels = c(1, 0), labels = c("Yes","No")), ## Any Child Under 5 years and Female Headed
    
    Targ_HHHFemChildU12more = factor(if_else(HHSize01M + HHSize01F > 1 & FemHHH == "Yes", 1, 0),
                                levels = c(1, 0), labels = c("Yes","No")), ##  Two or More Children Under 1 year and Female Headed
    
    Targ_HHHFemChildU52more = factor(if_else(HHSize24M + HHSize24F > 1 & FemHHH == "Yes", 1, 0),
                                levels = c(1, 0), labels = c("Yes","No")), ##  Two or More Children Under 5 years and Female Headed
    
    Targ_HHPLW = factor(if_else(HHPregLactNb > 0, 1, 0),
                   levels = c(1, 0), labels = c("Yes","No")), ## Any number of pregnant or lactating individuals
    
    Targ_HHPLW2more = factor(if_else(HHPregLactNb > 1, 1, 0),
                        levels = c(1, 0), labels = c("Yes","No")), ## Two or More pregnant or lactating individuals
    
    #Targ_HHChronIll = factor(if_else(MDDIHHENHealthMed_milieu > 0, 1, 0),
    #                    levels = c(1, 0), labels = c("Yes","No")), ## Any individuals with chronic illness
    
    #Targ_HHChronIll2more = factor(if_else(MDDIHHENHealthMed_milieu > 1, 1, 0),
    #                         levels = c(1, 0), labels = c("Yes","No")), ## Two or More individuals with chronic illness
    
    Targ_HHUnschoolHHH = factor(if_else(AC2 == "None", 1, 0),
                           levels = c(1, 0), labels = c("Yes","No")), ## Uneducated HHH
    
    Targ_HHDispMore10Y = factor(if_else(HHHDisplArriveYrsNb > 10, 1, 0),
                                       levels = c(1, 0), labels = c("Yes","No")), ## Displaced more than 10 years ago
    
    Targ_HHDispLess6m = factor(if_else(TypeHousehold %in% c("0 to 3 months", "3 to 6 months"), 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## Displaced less than 6 m
    
    Targ_HHDispLess6mto1y = factor(if_else(TypeHousehold %in% c("6 to 12 months"), 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## Displaced less than 1 year
    
    Targ_HHDispMore1y = factor(if_else(TypeHousehold %in% c("More than 12 months"), 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## Displaced more than 1 year
    
    Targ_IDP_HostFam = factor(if_else(HHStatus %in% c("IDP in host family"), 1, 0),
                         levels = c(1, 0), labels = c("Yes","No")), ## IDPs in Host family
    
    Targ_IDP_ManSites = factor(if_else(HHStatus %in% c("IDP in site"), 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## IDPs in Managed Sites
    
    Targ_IDP_SpontSites = factor(if_else(HHStatus %in% c("IDP in site no managed"), 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## IDPs in Managed Sites
    
    Targ_HHRefugee = factor(if_else(HHStatus %in% c("HH Refugee"), 1, 0),
                                 levels = c(1, 0), labels = c("Yes","No")), ## HH is a refugee
    
    Targ_HHHostPop = factor(if_else(HHStatus %in% c("Host population"), 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## HH is a host population
    
    Targ_HHOldIDP = factor(if_else(HHStatus %in% c("HH Returnee (Old IDP)"), 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## HH is a returnee (old IPD)
    
    Targ_HHTransitRet = factor(if_else(HHStatus %in% c("HH Returnee in transit"), 1, 0),
                           levels = c(1, 0), labels = c("Yes","No")), ## HH is a returnee in transit
    
    Targ_HHIndigenous = factor(if_else(HHStatus %in% c("Indigenous populations (Pygmies)"), 1, 0),
                               levels = c(1, 0), labels = c("Yes","No")), ## HH is a Indigenous populations (Pygmies)
    
    
    Targ_HHDwellDamaged = factor(if_else(HHDwellCond %in% c("somewhat damaged","very damaged"), 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## Damaged Residence 
    
    
    Targ_HHOwnLand = factor(if_else(modePossessionTerre == "Personal or family property", 1, 0),
                       levels = c(1, 0), labels = c("Yes","No")), ## HH Own a Land
    
    Targ_HHOwnLivestock = factor(if_else(betail == "Yes", 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## Household Owns Livestock
    
    #Targ_HHNoLivestock = factor(if_else(betail == "No", 1, 0),
    #                       levels = c(1, 0), labels = c("Yes","No")), ## Household Does Not Own Livestock
    
    Targ_HHOwnCattle2more = factor(if_else(nbrBetail_1 >= 2, 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## Household Owns Two or More Cattle Heads
    
    Targ_HHOwnSheeps5more = factor(if_else(nbrBetail_3 >= 5, 1, 0),
                                   levels = c(1, 0), labels = c("Yes","No")), ## Household Owns Five or More Sheep Heads
    
    Targ_HHOwnGoats5more = factor(if_else(nbrBetail_4 >= 5, 1, 0),
                                   levels = c(1, 0), labels = c("Yes","No")), ## Household Owns Ten or More Goats
    
    Targ_HHOwnChicken10more = factor(if_else(nbrBetail_5 >= 10, 1, 0),
                                     levels = c(1, 0), labels = c("Yes","No")), ## Household Owns Ten or More Chickens
    
    Targ_HHOwnPigs2more = factor(if_else(nbrBetail_2 >= 2, 1, 0),
                                  levels = c(1, 0), labels = c("Yes","No")), ## Household Owns Two or More Pigs Heads
    
    Targ_HHOwnRabbits10more = factor(if_else(nbrBetail_6 >= 10, 1, 0),
                                 levels = c(1, 0), labels = c("Yes","No")), ## Household Owns Two or More Rabbits
    
    Targ_HHHousingTent = factor(if_else(HHDwellType == "Traditional tent (sheet, tarpaulin)", 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## Household Lives in a Tent
    
    Targ_HHImprovedHousing = factor(if_else(HHDwellType %in% c("Apartment in a building", "Villa", "Studio", "Single room", "Multi-family house", "Duplex"), 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## Household Lives Good House
    
    Targ_HHHousingUnsafe = factor(if_else(HHDwellType == "Unsanitary shelter (factory/warehouse/garage/workshop/construction site/unfinished building)", 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## Household Lives in a Unsafe Shelter
    
    Targ_HHDetachedDamegedHouse = factor(if_else(HHDwellType == "Detached house" & HHDwellCond %in% c("somewhat damaged","very damaged"), 1, 0),
                                      levels = c(1, 0), labels = c("Yes","No")), ## Household Lives in a Detached Damaged House
    
    Targ_HHRoofUnsafe = factor(if_else(HHRoofType %in% c("Leaves", "Mats", "No roof", "Straw/palm leaf/Chaume", "Tarpaulin", "Wood/Board"), 1, 0),
                          levels = c(1, 0), labels = c("Yes","No")), ## Household Roof is Unsafe
    
    Targ_HHRoofSafe = factor(if_else(HHRoofType %in% c("Cement/Concrete", "Roof tile", "Sheet metal"), 1, 0),
                               levels = c(1, 0), labels = c("Yes","No")), ## Household Roof is Safe
    
    Targ_HHWallUnsafe = factor(if_else(HHWallType %in% c("Bamboo/palm", "Leaf", "Recycled wood", "Straw", "Basic plank",
                                                         "Palm leaves/palm leaves/natural wood", "Tarpaulin", "Mud","Unfired bricks"), 1, 0),
                               levels = c(1, 0), labels = c("Yes","No")), ## Household Wall is Unsafe
    
    Targ_HHWallSafe = factor(if_else(HHWallType %in% c("Cement/Stone with lime ", "Elaborate plank (industrial)", "Sheet metal",
                                                       "Cement bricks (cinder block, chipboard)", "Fired bricks", "Stones"), 1, 0),
                             levels = c(1, 0), labels = c("Yes","No")), ## Household Wall is Safe
    
    Targ_HHFloorUnsafe = factor(if_else(HHFloorType %in% c("Earth/Sand Flooring", "Straw/Bamboo/Thatch", "Wood/Plank"), 1, 0),
                               levels = c(1, 0), labels = c("Yes","No")), ## Household Floor is Unsafe
    
    Targ_HHFloorSafe = factor(if_else(HHFloorType %in% c("Cement", "Cement/Concrete", "Marble", "Stone", "Tile"), 1, 0),
                             levels = c(1, 0), labels = c("Yes","No")), ## Household Floor is Safe
    
    CrowdIndex = (HHSize / HHRoom), ## Household Crowding Index
    
    Targ_HHCrowdIndex = factor(if_else(CrowdIndex > 2, 1, 0),
                             levels = c(1, 0), labels = c("Yes","No")), ## Household Crowding Index is above 2
    
  
    Targ_HHUnsafeWater = factor(if_else(HHWaterSRC %in% c("Unprotected spring", "Rain water collection", 
                                                          "Surface water (e.g. river, pond)", "Unprotected dug well"), 1, 0),
                           levels = c(1, 0), labels = c("Yes","No")), ## Main source of drinking water is surface or other unprotected water sources
    
    Targ_HHNoCookEnergy = factor(if_else(HHEnerCookSRC == "None", 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## No Energy Source for cooking in the household
    
    Targ_HHUnsafeEnergy = factor(if_else(HHEnerCookSRC %in% c("Firewood (Purchased)", "Firewood (Collected)", "Straw"), 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## Main source of cooking energy in unsafe
    
    Targ_HHNoLight = factor(if_else(HHEnerLightSRC == "None", 1, 0),
                       levels = c(1, 0), labels = c("Yes","No")), ## No Light Source in the household
    
    Targ_HHUnsafeLight = factor(if_else(HHEnerLightSRC %in% c("Fire (wood, straw, etc.)", "Charcoal",
                                                              "Candles", "Petrol lamp"), 1, 0),
                           levels = c(1, 0), labels = c("Yes","No")), ## Main energy source for light is unsafe
    
    Targ_HHNoToilet = factor(if_else(HHToiletType %in% c("No toilets : Stream", "No toilets : In nature", 
                                                    "No toilets : Neighbors' house", "No toilet : Bucket/pot/bag"), 1, 0),
                        levels = c(1, 0), labels = c("Yes","No")), ## Main energy source for light is unsafe
    
    Targ_HHUnsafeToilet = factor(if_else(HHToiletType %in% c("Summary latrines (no slab, open hole)", 
                                                        "Suspended toilets/Sur Pilotis"), 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## Main energy source for light is unsafe
    
    Targ_HHChildWork = factor(if_else(Childwork == "Yes", 1, 0),
                        levels = c(1, 0), labels = c("Yes","No")), ## Child Work in the household
    
    Targ_HHRemittance = factor(if_else(HHRemittYN == "Yes", 1, 0),
                              levels = c(1, 0), labels = c("Yes","No")), ## HH Receiving remittances
    
    Targ_HHSepChild = factor(if_else(prot_child_sep == "Yes", 1, 0),
                               levels = c(1, 0), labels = c("Yes","No")), ## HH with separated child
  
    Targ_HHCredAcc = factor(if_else(HHCreditAccess == "Yes", 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## HH has access to credit
    
    Targ_HHWasteDispNeg = factor(if_else(HHWasteOut %in% c("Burning", "In nature", "Street/Gutter", 
                                                           "Throws it away in nearby bush", "Watercourse"), 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## HH uses negative waste disposal methods
    
    Targ_HHWithSpecNeeds = factor(if_else((nbr_pbs_masc + nbr_pbs_fem) >= 1, 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## HH has individuals with special needs
    
    Targ_HHWithSpecNeeds2more = factor(if_else((nbr_pbs_masc + nbr_pbs_fem) >= 2, 1, 0),
                                  levels = c(1, 0), labels = c("Yes","No")), ## HH has 2 or more individuals with special needs
    
    Targ_HHIncAgri = factor(if_else(Rev1 > 0, 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## Income from agriculture, livestock, forestry and other
    
    Targ_HHIncMining = factor(if_else(Rev2 > 0, 1, 0),
                            levels = c(1, 0), labels = c("Yes","No")), ## Income from mining
    
    Targ_HHIncInfTrade = factor(if_else(Rev3 > 0, 1, 0),
                              levels = c(1, 0), labels = c("Yes","No")), ## Income from informal/unqualified work
    
    Targ_HHIncTransport = factor(if_else(Rev4 > 0, 1, 0),
                                levels = c(1, 0), labels = c("Yes","No")), ## Income from transport
    
    Targ_HHIncQualified = factor(if_else(Rev5 > 0, 1, 0),
                                 levels = c(1, 0), labels = c("Yes","No")), ## Income from qualified/professional work
    
    Targ_HHIncComme = factor(if_else(Rev6 > 0, 1, 0),
                                 levels = c(1, 0), labels = c("Yes","No")), ## Income from business or commerce
    
    Targ_HHIncAid = factor(if_else(Rev7 > 0, 1, 0),
                             levels = c(1, 0), labels = c("Yes","No")), ## Income from assistance or aid
    
    Targ_HHIncRemitt = factor(if_else(Rev8 > 0, 1, 0),
                           levels = c(1, 0), labels = c("Yes","No")), ## Income from remittances
    
    Targ_HHFarm2025 = factor(if_else(HH_agrIC2025 == "Agriculteur ayant exploité cette année", 1, 0),
                              levels = c(1, 0), labels = c("Yes","No")) ## Household engaged in agriculture in 2025
  )


# Select only the targeting variables and CARI Variable
modelData <- data %>% select(FSI_CARI2_2classBin, starts_with("Targ_"))
predictors <- modelData %>% select(starts_with("Targ_")) %>% colnames()

# Convert Yes/No to 1/0
modelData[predictors] <- lapply(modelData[predictors], function(x) {
  x <- as.character(x)  # Ensure character format
  x <- ifelse(x == "Yes", 1, 0)  # Convert Yes to 1, No to 0
  return(as.numeric(x))
})

# Convert to tibble
modelData <- as_tibble(modelData) %>% filter(!is.na(FSI_CARI2_2classBin)) # Remove NAs in CARI Variable
modelData <- modelData %>% mutate(across(everything(), ~replace(., is.na(.), 0))) %>% # Replace NAs with 0
                           mutate(across(everything(), ~as.numeric(.))) %>% # Convert all to factor
                           select(where(~ !(all(. == 1) | all(. == 0)))) # Remove constant variables

modelData <- modelData %>% drop_na() # Just to check no NAs now

## Save Targeting Dataset
saveRDS(modelData, "./output/modeling_dataset.rds")

#--------------------------
# Remove Highly Correlated Variables
#--------------------------
# Outcome
outcome_col <- 1

# Only numeric predictors, excluding outcome
predictors <- modelData[ , -outcome_col]
na_pct <- colMeans(is.na(predictors))

corr_matrix <- cor(predictors)

highCorr <- findCorrelation(corr_matrix, cutoff = 0.8)
predictors_clean <- predictors[, -highCorr]

modelDataClean <- cbind(modelData[, outcome_col, drop = FALSE], predictors_clean)

## Final
modelData <- modelDataClean

rm(modelDataClean , corr_matrix, predictors, predictors_clean, highCorr, outcome_col, na_pct)

#--------------------------
# Check for zero-variance predictors
#--------------------------
y <- "FSI_CARI2_2classBin"
preds <- setdiff(names(modelData), y)

# Check zero-variance predictors
zero_var <- sapply(modelData[preds], function(x) {
  x <- x[!is.na(x)]
  if (is.factor(x)) nlevels(x) < 2 else (length(unique(x)) < 2 || (is.numeric(x) && sd(x) == 0))
})

which(zero_var)

# Among *_YN columns, check for (quasi) separation via empty rows/cols in 2x2 tables
yn <- grep("_YN$", preds, value = TRUE)
sep <- sapply(yn, function(p) {
  d <- modelData[, c(y, p)]
  d <- stats::na.omit(d)
  if (!all(unique(d[[y]]) %in% c(0,1)) && !is.factor(d[[y]])) {
    # coerce outcome to factor if it's not 0/1 numeric
    d[[y]] <- factor(d[[y]])
  }
  tab <- table(d[[y]], d[[p]])
  # Separation proxy: any row/column sum is zero (i.e., a margin has zero counts)
  any(rowSums(tab) == 0) || any(colSums(tab) == 0)
})

which(sep)

# Peek at a couple tables to confirm
head(yn, 5)

rm(y, preds, sep, yn, zero_var)

#--------------------------
# Univariate Screening
#--------------------------
# Run the univariate robust script
uni <- screen_univariate_logit_robust(
  df = modelData,
  y = "FSI_CARI2_2classBin",
  alpha = 0.05,
  adjust = "BH",
  fisher_fallback = TRUE
)

head(uni, 20)
uni <- subset(uni, significant)

# Identify Inclusion and exclusion variables
uni_incl <- uni %>% filter(OR > 1)
uni_excl <- uni %>% filter(OR < 1)

# Final set of 10-15 inclusion variables
# Vector of specific row identifiers to remove
rows_to_remove <- c("Targ_IDP_SpontSites", "Targ_IDP_ManSites", "Targ_IDP_HostFam",
                    "Targ_HHDispMore1y", "Targ_HHDispLess6m", "Targ_HHDispMore10Y",
                    "Targ_HHOldIDP", "Targ_HHWithSpecNeeds", 
                    "Targ_HHPLW2more", "Targ_HHWasteDispNeg")

# Remove rows where the identifier ends with "_YN" or is in the list
uni_incl <- uni_incl %>%
  filter(
    !(
      grepl("_YN$", predictor) | predictor %in% rows_to_remove
    )
  )


## Final dataset (also the basis for modeling)
cols_to_keep <- c(uni_incl$predictor, uni_excl$predictor)
modelData <- modelData[, c("FSI_CARI2_2classBin", cols_to_keep)]


rm(rows_to_remove, cols_to_keep, uni, uni_excl, uni_incl)

#--------------------------
# Train Test Split
#--------------------------
train_index <- createDataPartition(modelData$FSI_CARI2_2classBin, p = 0.80, list = FALSE)
train <- modelData[train_index, ]
test  <- modelData[-train_index, ]

train$FSI_CARI2_2classBin <- as.factor(train$FSI_CARI2_2classBin) # needs to be a factor to run classification modeling

# Matrix
x_train <- model.matrix(FSI_CARI2_2classBin ~ . - 1, data = train)
y_train <- train$FSI_CARI2_2classBin
x_test  <- model.matrix(FSI_CARI2_2classBin ~ . - 1, data = test)
y_test  <- test$FSI_CARI2_2classBin

#--------------------------
# 1. Logistic regression
#--------------------------
# Model
log_model <- glm(FSI_CARI2_2classBin ~ ., data = train, family = binomial(link = "logit"))

pred_logi <- predict(log_model, test)


#--------------------------
# 2. XGBoost with tuned parameters
#--------------------------
dtrain <- xgb.DMatrix(data = as.matrix(train %>% select(-FSI_CARI2_2classBin)), label = train$FSI_CARI2_2classBin)
dtest  <- xgb.DMatrix(data = as.matrix(test %>% select(-FSI_CARI2_2classBin)), label = test$FSI_CARI2_2classBin)

#--------------------------
# Hyperparameter grid
#--------------------------
param_grid <- expand.grid(
  eta = c(0.05, 0.1, 0.2),
  max_depth = c(3, 4, 5),
  subsample = c(0.8, 1),
  colsample_bytree = c(0.8, 1)
)

best_rmse <- Inf
best_params <- list()
best_nrounds <- 0

#--------------------------
# Parallel grid search
#--------------------------
results <- foreach(i = 1:nrow(param_grid), .combine = rbind, .packages = "xgboost") %dopar% {
  
  params <- list(
    objective = "reg:squarederror",
    eval_metric = "rmse",
    eta = param_grid$eta[i],
    max_depth = param_grid$max_depth[i],
    subsample = param_grid$subsample[i],
    colsample_bytree = param_grid$colsample_bytree[i],
    min_child_weight = 1,
    gamma = 0
  )
  
  dtrain_local <- xgb.DMatrix(data = x_train, label = y_train)
  
  cv <- xgb.cv(
    params = params,
    data = dtrain_local,
    nrounds = 500,
    nfold = 5,
    early_stopping_rounds = 20,
    verbose = FALSE
  )
  
  best_iter <- cv$best_iteration
  best_rmse_cv <- cv$evaluation_log[best_iter]$test_rmse_mean
  
  data.frame(
    eta = params$eta,
    max_depth = params$max_depth,
    subsample = params$subsample,
    colsample_bytree = params$colsample_bytree,
    nrounds = best_iter,
    RMSE = best_rmse_cv
  )
}

#--------------------------
# Select best params
#--------------------------
best_row <- results[which.min(results$RMSE), ]
cat("Best RMSE:", round(best_row$RMSE,4), "\n")
cat("Best params:\n")
print(best_row)

best_params <- list(
  objective = "reg:squarederror",
  eval_metric = "rmse",
  eta = best_row$eta,
  max_depth = best_row$max_depth,
  subsample = best_row$subsample,
  colsample_bytree = best_row$colsample_bytree,
  lambda = 1,
  alpha =  0.1,
  min_child_weight = 1,
  gamma = 0
)

best_nrounds <- best_row$nrounds

#--------------------------
# Train final model
#--------------------------
final_model <- xgb.train(
  params = best_params,
  data = dtrain,
  nrounds = best_nrounds
)

# Predictions
pred_xgb <- predict(final_model, dtest)

#--------------------------
# Feature importance
#--------------------------
importance_matrix <- xgb.importance(model = final_model)
head(importance_matrix, 20)

# Convert to dataframe for easier plotting
importance_df <- data.frame(
  Variable = importance_matrix[, 1],
  Importance = importance_matrix[, 2]   # %IncMSE (Mean decrease in accuracy)
)

# Order by importance
importance_df <- importance_df %>%
  arrange(desc(Gain))

# Increase Importance for better charting
importance_df <- importance_df %>% mutate(Gain = Gain*100)

# View top 10 variables
head(importance_df, 15)

#---------------------------
# 3. Elastic Net (Improved OLS)
#---------------------------
enet_model <- train(
  FSI_CARI2_2classBin ~ ., 
  data = train,
  method = "glmnet",
  trControl = trainControl("cv", number = 10, allowParallel = FALSE),
  tuneLength = 10
)

enet_pred_log <- predict(enet_model, newdata = test, type = "prob")
enet_pred_log <- enet_pred_log[, "1"]

#---------------------------
# 4. Random Forest
#---------------------------
rf_model <- randomForest(
  FSI_CARI2_2classBin ~ ., 
  data = train, 
  ntree = 1000, 
  mtry = floor(sqrt(ncol(train) - 1)), # typical RF default
  importance = TRUE
)

rf_pred <- predict(rf_model, newdata = test)

# Run a boruta model to identify shadow variables so to reduce covariates
boruta_model <- Boruta(FSI_CARI2_2classBin ~ ., data = test, doTrace = 2, maxRuns = 500)

print(boruta_model)
plot(boruta_model, las = 2, cex.axis = 0.7)

final_boruta <- TentativeRoughFix(boruta_model)
print(final_boruta)

plot(final_boruta, las = 2, cex.axis = 0.7)

confirmed_vars <- getSelectedAttributes(final_boruta, withTentative = FALSE)
rejected_vars  <- setdiff(names(test)[-1], confirmed_vars)

confirmed_vars
rejected_vars

#--------------------------------------------------
# Retrain RF using only selected variables
#--------------------------------------------------
formula_selected <- as.formula(paste("FSI_CARI2_2classBin ~", paste(confirmed_vars, collapse = " + ")))

rf_selected <- randomForest(formula_selected, 
                            data = train,
                            ntree = 1000, 
                            mtry = floor(sqrt(ncol(train) - 1)), # typical RF default
                            importance = TRUE)

# Get importance scores
rf_importance <- importance(rf_selected)

# Convert to dataframe for easier plotting
rf_importance_df <- data.frame(
  Variable = rownames(rf_importance),
  Importance = rf_importance[, 1]   # %IncMSE (Mean decrease in accuracy)
)

# Order by importance
rf_importance_df <- rf_importance_df %>%
  arrange(desc(Importance))

# View top 10 variables
head(rf_importance_df, 16)
tail(importance_df, 15) 

#--------------------------------------------------
# Evaluate on test set
#--------------------------------------------------
# Predictions with selected features
pred_selected <- predict(rf_selected, newdata = test, type = "prob") %>% as.data.frame()
rf_pred_prob <- pred_selected[, "1"]

## ---------------------------
## Model Evaluation
## ---------------------------
# Create ROC objects
roc_log <- roc(FSI_CARI2_2classBin ~ pred_logi, data = test, direction = "<", quiet = TRUE)
roc_xgb <- roc(FSI_CARI2_2classBin ~ pred_xgb, data = test, direction = "<", quiet = TRUE)
roc_enet <- roc(FSI_CARI2_2classBin ~ enet_pred_log, data = test, direction = "<", quiet = TRUE)
roc_rf <- roc(FSI_CARI2_2classBin ~ rf_pred_prob, data = test, direction = "<", quiet = TRUE)


# Create combined plot
ggroc(list(
  "Logistic Model" = roc_log,
  "Elastic Net Model" = roc_enet,
  "XGBoost Model" = roc_xgb,
  "Random Forest Model" = roc_rf
), legacy.axes = TRUE) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "gray") +
  labs(title = "ROC Curve",
       x = "False Positive Rate (1 - Specificity)",
       y = "True Positive Rate (Sensitivity)",
       color = "Model") +
  scale_color_manual(values = c("#2ca02c", "purple", "blue", "red")) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  annotate("text", x = 0.75, y = 0.20, 
           label = paste("Logistic Model AUC =", round(auc(roc_log), 3)), 
           color = "#2ca02c") +
  annotate("text", x = 0.75, y = 0.15, 
           label = paste("Elastic Net Model AUC =", round(auc(roc_enet), 3)), 
           color = "purple") +
  annotate("text", x = 0.75, y = 0.10, 
           label = paste("XGBoost Model AUC =", round(auc(roc_xgb), 3)), 
           color = "blue") +
  annotate("text", x = 0.75, y = 0.05, 
           label = paste("Random Forest Model AUC =", round(auc(roc_rf), 3)), 
           color = "red")


## ---------------------------
## Targeting Implementation
## ---------------------------
# List of variables to exclude
exclude_vars <- c(
  "Targ_HHUnsafeToilet",
  "Targ_HHHostPop",
  "Targ_HHOwnLand",
  "Targ_HHOwnLivestock",
  "Targ_HHIncRemitt",
  "Targ_HHWallSafe"
)

# GLM Model
coef_df_glm <- data.frame(
  variable = names(coef(log_model)),
  coefficient = coef(log_model),
  odds_ratio = exp(coef(log_model))
) %>%
  # Remove intercept if needed
  filter(variable != "(Intercept)") %>%
  # Remove specific Targ_ variables (same as before)
  filter(!variable %in% exclude_vars) %>%
  # Remove Assets Variables
  filter(!grepl("_YN$", variable)) %>%
  # Sort by coefficient magnitude
  arrange(-abs(coefficient))

coef_df_glm


# Replace a coefficient according to local knowledge
coef_df_glm[coef_df_glm$variable == "Targ_HHOwnCattle2more", "odds_ratio"] <- 0.5301
coef_df_glm[coef_df_glm$variable == "Targ_HHOwnCattle2more", "coefficient"] <- -0.6346896
coef_df_glm[coef_df_glm$variable == "Targ_HHIncAgri", "odds_ratio"] <- 0.7279128
coef_df_glm[coef_df_glm$variable == "Targ_HHIncAgri", "coefficient"] <- -0.317574
coef_df_glm[coef_df_glm$variable == "Targ_HHIncInfTrade", "odds_ratio"] <- 0.8061924
coef_df_glm[coef_df_glm$variable == "Targ_HHIncInfTrade", "coefficient"] <- -0.2154329
coef_df_glm[coef_df_glm$variable == "Targ_HHOwnRabbits10more", "odds_ratio"] <- 0.9545986
coef_df_glm[coef_df_glm$variable == "Targ_HHOwnRabbits10more", "coefficient"] <- -0.04646434
coef_df_glm[coef_df_glm$variable == "Targ_HHFarm2025", "odds_ratio"] <- 0.9790112
coef_df_glm[coef_df_glm$variable == "Targ_HHFarm2025", "coefficient"] <- -0.0212122


# Add aggregated exclusion indicators
coef_df_glm <- coef_df_glm %>% 
  add_row(variable = "Targ_HHDigitalAssets",
          coefficient = 0,
          odds_ratio = 1) %>%
  add_row(variable = "Targ_HHTransportAssets",
          coefficient = 0,
          odds_ratio = 1) %>%
  add_row(variable = "Targ_HHHouseholdAssets",
          coefficient = 0,
          odds_ratio = 1)



ggplot(coef_df_glm, aes(x = reorder(variable, odds_ratio), y = odds_ratio)) +
  geom_col(aes(fill = odds_ratio > 1), width = 0.7) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "gray") +
  # Add text labels at the end of bars (adjust hjust for positioning)
  geom_text(
    aes(label = sprintf("%.2f", odds_ratio)), 
    hjust = -0.1,           # Push text slightly right of bar end
    size = 3.5,             # Adjust font size
    color = "black"         # Text color
  ) +
  coord_flip() +
  scale_fill_manual(
    values = c("red", "blue"),
    labels = c("Decreases odds", "Increases odds")
  ) +
  labs(
    title = "GLM Model: Odds Ratios (Standardized Predictors)",
    x = "Predictor",
    y = "Odds Ratio",
    fill = "Effect Direction"
  ) +
  theme_minimal()


## For exclusion instead of using all the variables we take the mean of the assets into three categories and livestock into one
# Create a Scorecard Model GLM
modelData <- modelData %>% mutate(
                  # Inclusion Criteria
                  Targ_Inc_Ind1 = ifelse(Targ_HHIndigenous == 1, 2.62, 0),
                  Targ_Inc_Ind2 = ifelse(Targ_HHHousingTent == 1, 2.23, 0),
                  Targ_Inc_Ind3 = ifelse(Targ_HHNoLight == 1, 2.81, 0),
                  Targ_Inc_Ind4 = ifelse(Targ_HHUnsafeEnergy == 1, 1.81, 0),
                  Targ_Inc_Ind5 = ifelse(Targ_HHFloorUnsafe == 1, 1.37, 0),
                  Targ_Inc_Ind6 = ifelse(Targ_HHUnsafeLight  == 1, 1.69, 0),
                  Targ_Inc_Ind7 = ifelse(Targ_HHWithSpecNeeds2more == 1, 3.30, 0),
                  Targ_Inc_Ind8 = ifelse(Targ_HHDetachedDamegedHouse == 1, 1.64, 0),
                  Targ_Inc_Ind9 = ifelse(Targ_HHCrowdIndex == 1, 1.60, 0),
                  Targ_Inc_Ind10 = ifelse(Targ_HHUnsafeWater == 1, 1.15, 0),
                  Targ_Inc_Ind11 = ifelse(Targ_HHChildWork  == 1, 1.60, 0),
                  Targ_Inc_Ind12 = ifelse(Targ_HHNoToilet  == 1, 1.32, 0),
                  Targ_Inc_Ind13 = ifelse(Targ_HHDepRatio2plus == 1, 1.20, 0),
                  Targ_Inc_Ind14 = ifelse(Targ_ChildU52more  == 1, 1.04, 0),
                  Targ_Inc_Ind15 = ifelse(Targ_HHPLW == 1, 1.02, 0),
                  
                  # Exclusion Criteria (Model)
                  Targ_Exc_Ind1 = ifelse(Targ_HHFarm2025  == 1, 0.98, 0),
                  Targ_Exc_Ind2 = ifelse(Targ_HHOwnRabbits10more == 1, 0.95, 0),  
                  Targ_Exc_Ind3 = ifelse(Targ_HHRoofSafe == 1, 0.93, 0),
                  Targ_Exc_Ind4 = ifelse(Targ_HHCredAcc == 1, 0.87, 0),
                  Targ_Exc_Ind5 = ifelse(Targ_HHOwnGoats5more == 1, 0.81, 0),
                  Targ_Exc_Ind6 = ifelse(Targ_HHRemittance == 1, 0.81, 0),
                  Targ_Exc_Ind7 = ifelse(Targ_HHIncInfTrade == 1, 0.81, 0),
                  Targ_Exc_Ind8 = ifelse(Targ_HHOwnPigs2more == 1, 0.78, 0),
                  Targ_Exc_Ind9 = ifelse(Targ_HHOwnChicken10more == 1, 0.77, 0),
                  Targ_Exc_Ind10 = ifelse(Targ_HHIncAgri == 1, 0.73, 0),
                  Targ_Exc_Ind11 = ifelse(Targ_HHIncComme == 1, 0.72, 0),
                  Targ_Exc_Ind12 = ifelse(Targ_HHIncQualified == 1, 0.70, 0),
                  Targ_Exc_Ind13 = ifelse(Targ_HHIncTransport == 1, 0.63, 0),
                  Targ_Exc_Ind14 = ifelse(Targ_HHOwnCattle2more == 1, 0.53, 0),
                  
                  # Exclusion Criteria (Semi-modelled)
                  Targ_Exc_Ind15 = ifelse((Targ_HHAssetTV_YN == 1 | 
                                           Targ_HHAssetSolar_YN == 1 |
                                           Targ_HHAssetSmartphone_YN == 1 | 
                                           Targ_HHAssetPC_YN == 1 |
                                           Targ_HHAssetSatellite_YN == 1 | 
                                           Targ_HHAssetRadio_YN == 1 |
                                           Targ_HHAssetLaptop_YN == 1 |
                                           Targ_HHAssetEGenerator_YN == 1 |
                                           Targ_HHAssetETablet_YN == 1 |
                                           Targ_HHAssetAirCond_YN == 1 |
                                           Targ_HHAssetCellphone_YN == 1
                                          ), 1, 0),
                  
                  Targ_Exc_Ind16 = ifelse((Targ_HHAssetTaxi_YN == 1 |
                                           #Targ_HHAssetTukTuk_YN == 1 |
                                           Targ_HHAssetMoto_YN == 1 |
                                           Targ_HHAssetCanoe_YN == 1 |
                                           Targ_HHAssetCar_YN == 1 |
                                           Targ_HHAssetBike_YN == 1
                                          ), 1, 0),
                  
                  Targ_Exc_Ind17 = ifelse((Targ_HHAssetWfilter_YN == 1 | 	
                                           Targ_HHAssetWashMach_YN == 1 |
                                           Targ_HHAssetTable_YN == 1 |
                                           Targ_HHAssetSofa_YN == 1 |
                                           Targ_HHAssetShovel_YN == 1 |
                                           Targ_HHAssetSewing_YN == 1 |
                                           Targ_HHAssetRefrig_YN == 1 |
                                           Targ_HHAssetOven_YN == 1 |
                                           Targ_HHAssetIron_YN == 1 |
                                           Targ_HHAssetHeater_YN == 1 |
                                           Targ_HHAssetElecStove_YN == 1 |
                                           Targ_HHAssetGHeat_YN == 1 |
                                           Targ_HHAssetEFan_YN == 1 |
                                           Targ_HHAssetGasStove_YN == 1 |
                                           Targ_HHAssetFreez_YN == 1 |
                                           Targ_HHAssetCarp_YN == 1 |
                                           Targ_HHAssetDVD_YN == 1 |
                                           #Targ_HHAssetBrick_YN == 1 |
                                           Targ_HHAssetCabinet_YN == 1
                                          ), 1, 0),
) %>% 
  rowwise() %>%
  mutate(TargScore = sum(c_across(starts_with("Targ_Inc_Ind")), na.rm = TRUE) - sum(c_across(starts_with("Targ_Exc_Ind")), na.rm = TRUE),
         TargScore = if_else(TargScore < 0, 0, TargScore)) %>%
  arrange(desc(TargScore)) %>%
  mutate(VulHH = if_else(TargScore > 0, "Eligible", "Non-Eligible"),
         CariHH = if_else(FSI_CARI2_2classBin == 1, "Vulnerable", "Non-Vulnerable")) %>% ungroup()

# Verify the distribution
modelData %>% 
  count(VulHH) %>% 
  mutate(Percentage = n/nrow(modelData)*100)


## ---------------------------
## Design Error Analysis
## ---------------------------
table(modelData$VulHH, modelData$CariHH)
1149/(1149+3824) # 22.4% exclusion error
621/(611+3824) # 14% inclusion error

# Define error rates
exclusion_error <- 1149/(1149+3824)
inclusion_error <- 621/(611+3824)

# Create a data frame
error_data <- data.frame(
  ErrorType = c("Exclusion Error", "Inclusion Error"),
  ErrorRate = c(exclusion_error, inclusion_error) * 100  # convert to percentage
)

# Load ggplot2
library(ggplot2)

# Create the bar chart
ggplot(error_data, aes(x = ErrorType, y = ErrorRate, fill = ErrorType)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_text(aes(label = sprintf("%.2f%%", ErrorRate)), vjust = -0.5, 
            fontface = "bold", size = 5, color = "black") +
  labs(title = "Exclusion and Inclusion Error Rates",
       y = "Error Rate (%)",
       x = "") +
  theme_minimal() +
  theme(legend.position = "none") +
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),  # remove vertical grid lines
    panel.grid.minor.x = element_blank()
  )


#--------------------------
# Quintiles and Quartiles
#--------------------------
# Add random noise to increase decimals to avoid households folling into multiple categories
modelData$TargScore <- modelData$TargScore + runif(length(modelData$TargScore), min = 0, max = 0.0099)

modelData$TargScore <- sprintf("%.4f", modelData$TargScore)

modelData <- modelData %>% mutate(TargScore = ifelse(TargScore < 1, 0, TargScore))

modelData$TargScore <- as.numeric(modelData$TargScore)

# Remove everyone with a score of zero to avoid issues
modelData2 <- modelData %>% filter(TargScore > 0)

# Divide into Quartiles
qs4 <- quantile(modelData2$TargScore, probs = seq(0, 1, 0.25), na.rm = TRUE)
qs4 

modelData2$TargScore_quartile <- cut(
  modelData2$TargScore,
  breaks = unique(qs4),
  include.lowest = TRUE,
  labels = FALSE
)

# Divide into Quintiles
qs5 <- quantile(modelData2$TargScore, probs = seq(0, 1, 0.20), na.rm = TRUE)
qs5

modelData2$TargScore_quintile <- cut(
  modelData2$TargScore,
  breaks = unique(qs5),
  include.lowest = TRUE,
  labels = FALSE
)

# Quartile counts
quartile_counts <- as.data.frame(table(modelData2$TargScore_quartile))
names(quartile_counts) <- c("Quartile", "Count")

# Quintile counts
quintile_counts <- as.data.frame(table(modelData2$TargScore_quintile))
names(quintile_counts) <- c("Quintile", "Count")

# Quartile intervals
quartile_intervals <- data.frame(
                        Quartile = 1:4,
                        From = qs4[1:4],
                        To   = qs4[2:5]
                        )

# Join counts
quartile_summary <- merge(quartile_intervals, quartile_counts, by = "Quartile")
quartile_summary

# Quintile intervals
quintile_intervals <- data.frame(
  Quintile = 1:5,
  From = qs5[1:5],
  To   = qs5[2:6]
)

# Join counts
quintile_summary <- merge(quintile_intervals, quintile_counts, by = "Quintile")
quintile_summary

# Create a new workbook
wb <- createWorkbook()

# Add sheets
addWorksheet(wb, "Quartiles")
addWorksheet(wb, "Quintiles")

# Write tables
writeData(wb, sheet = "Quartiles", quartile_summary)
writeData(wb, sheet = "Quintiles", quintile_summary)

# Save workbook
saveWorkbook(wb, file = "./output/Targeting_Summary.xlsx", overwrite = TRUE)

#--------------------------
# Stop cluster
#--------------------------
stopCluster(cl)

#--------------------------
# Save Final Dataset
#--------------------------
saveRDS(modelData, "./output/final_modeling_dataset.rds")

