
#' Set options(error = recover)
#'
#' @export
optionsErrorRecover <- function() {
    cat('options(error = recover)\n')
    options(error = recover)
}


#' Set options(error = NULL)
#'
#' @export
optionsErrorNull <- function() {
    cat('options(error = NULL)\n')
    options(error = NULL)
}
