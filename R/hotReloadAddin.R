# References:
# http://stackoverflow.com/questions/8743390
# http://stackoverflow.com/questions/23279904
# http://stackoverflow.com/questions/26381474

#' Hot reload selected code into an installed package, by default nimble.
#'
#' @export
hotReload <- function(name, newValue, package = 'nimble') {
    library(package, character.only = TRUE)
    ns <- asNamespace(package)
    if (!exists(name, envir = ns, inherits = FALSE)) {
        stop(paste('Symbol', name, 'is not part of package', package))
    }

    # Copy environment and attributes.
    oldValue <- get(name, envir = ns, inherits = FALSE)
    environment(newValue) <- environment(oldValue)
    attributes(newValue) <- attributes(oldValue)

    # Update the namespace:_ environment.
    assignInNamespace(name, newValue, ns = ns)

    # Update the package:_ environment if name is exported.
    pkg <- as.environment(paste0('package:', package))
    if (exists(name, envir = pkg, inherits = FALSE)) {
        assign(name, newValue, envir = pkg)
    }

    # Check that namespace was correctly set.
    if(is.null(environment(get(name, envir = ns, inherits = FALSE)))) {
        stop(paste('Failed to set environment of', name))
    }
    cat('Reloaded nimble::', name, sep = '')
}

#' Hot reload selected code into package:nimble.
#'
#' @export
hotReloadHere <- function(newValue) {
    name <- as.character(match.call()[[2]])
    hotReload(name, newValue)
}

#' Hot reload selected code into package:nimble.
#'
#' To use this, first select a definition like `name <- function(...){...}` in
#' an editor window, then trigger the addin.
#'
#' @export
hotReloadAddin <- function() {
    # Grab selected text of the form 'name <- ...' from an rstudio editor window.
    selection <- rstudioapi::getSourceEditorContext()$selection
    expr <- parse(text = paste0(selection[[1]]$text, collapse = '\n'))
    if(deparse(expr[[1]][[1]]) != '<-' || !is.name(expr[[1]][[2]])) {
        stop(paste('Expected an assignment like "name <- ...", but got:',
                   deparse(expr[[1]]), sep = '\n'))
    }
    name <- as.character(expr[[1]][[2]])
    newValue <- expr[[1]][[3]]
    hotReload(name, newValue, 'nimble')
}
