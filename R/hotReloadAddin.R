# References:
# http://stackoverflow.com/questions/8743390
# http://stackoverflow.com/questions/23279904
# http://stackoverflow.com/questions/26381474

is.parsable <- function(text) {
    return(!inherits(try(parse(text = text), silent = TRUE), 'try-error'))
}

getEditorText <- function() {
    range <- rstudioapi::primary_selection(rstudioapi::getSourceEditorContext())$range
    rstudioapi::setSelectionRanges(c(range$start[['row']], 1, Inf, 1))
    text <- rstudioapi::primary_selection(rstudioapi::getSourceEditorContext())$text
    rstudioapi::setSelectionRanges(range)
    lines <- strsplit(text, '\n')[[1]]
    for (n in 1:length(lines)) {
        if (is.parsable(lines[1:n])) {
            return(paste(lines, collapse = '\n'))
        }
    }
    stop('Failed to parse selection')
}

assignEvenIfLocked <- function(name, value, envir) {
    if (bindingIsLocked(name, envir)) {
        unlockBinding(name, envir)
        on.exit(lockBinding(name, envir))
    }
    assign(name, value, envir = envir, inherits = FALSE)
}

#' Hot reload selected code into package:nimble.
#'
#' To use this, first select a definition like `name <- function(...){...}` in
#' an editor window, then trigger the addin.
#'
#' @export
hotReloadAddin <- function() {
    library('nimble')
    ns <- asNamespace('nimble')
    pkg <- as.environment('package:nimble')
    
    # Grab selected text of the form 'name <- ...' from an RStudio editor window.
    text <- getEditorText()
    expr <- parse(text = text)
    if(deparse(expr[[1]][[1]]) != '<-' || !is.name(expr[[1]][[2]])) {
        stop(paste('Expected an assignment like "name <- ...", but got:',
                   deparse(expr[[1]]), sep = '\n'))
    }
    name <- as.character(expr[[1]][[2]])
    if(!exists(name, envir = ns, inherits = FALSE)) {
        stop(paste('Symbol', name, 'is not part of NIMBLE'))
    }
    value <- eval(expr[[1]][[3]], envir = ns)

    # Update the namespace:nimble environment.
    assignInNamespace(name, value, ns = ns)

    # Update the package:nimble environment if name is exported.
    exported <- exists(name, envir = pkg, inherits = FALSE)
    if(exported) {
        assignEvenIfLocked(name, value, envir = pkg)
        cat('Reloaded nimble::', name, sep = '')
    } else {
        cat('Reloaded nimble:::', name, sep = '')
    }
}
