# Set options here
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode

# Comment this if you don't want the app to be served on a random port
options(shiny.port = httpuv::randomPort())

# Set options safely before running the app
options(shiny.maxRequestSize = 2 * 1024^3) # Forces Shiny to accept up to 2GB files
options(shiny.sanitize.errors = FALSE) # Displays clear errors during your testing phase

# Set your app theme globally if not hardcoded in page_navbar
options(shiny.useragg = TRUE) # Forces high-speed graphics rendering

# Detach all loaded packages and clean your environment
golem::detach_all_attached()
# rm(list=ls(all.names = TRUE))

# Document and reload your package
golem::document_and_reload()

# Run the application
run_app()
