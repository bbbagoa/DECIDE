# Explicit entry point for Golem Package deployment

# Production runtime options
options(viewer = NULL)
options(shiny.launch.browser = TRUE)
options(shiny.maxRequestSize = 2 * 1024^3) # 2 GB upload limit

library(golem)
pkgload::load_all(export_all = FALSE)

# Force the environment to run the app startup function found in your run_app.R
run_app()
