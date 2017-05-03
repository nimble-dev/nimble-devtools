
hotReload <- function() {
    library('nimble')

    # Grab selected text of the form 'name <- value' from an rstudio editor window.
    selection <- rstudioapi::getSourceEditorContext()$selection
    expr <- parse(text = paste0(selection[[1]]$text, collapse = '\n'))
    if(deparse(expr[[1]][[1]]) != '<-' || !is.name(expr[[1]][[2]])) {
        stop(paste('Expected an assignment like "name <- ...", but got:', deparse(expr[[1]]), sep = '\n'))
    }
    name <- as.character(expr[[1]][[2]])
    newValue <- expr[[1]][[3]]

    # Copy environment and attributes, as recommended by
    # http://stackoverflow.com/questions/23279904
    oldValue <- get(name, envir = asNamespace('nimble'))
    environment(newValue) <- environment(oldValue)
    attributes(newValue) <- attributes(oldValue)

    # Update the package:nimble environment.
    assignInNamespace(name, newValue, ns = 'nimble')
    if (!exists(name)) {
        # If name is internal, we also need to update the package:nimble environment.
        assignInNamespace(name, newValue, pos = 'package:nimble')
    }
}
