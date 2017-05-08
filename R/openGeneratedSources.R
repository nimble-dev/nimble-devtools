
#' Open the latest generated C++ files in tempdir().
#'
#' @export
openGeneratedSources <- function() {
    root <- file.path(tempdir(), 'nimble_generatedCode')
    files <- file.info(list.files(root, full.names = TRUE))
    files <- files[order(files$mtime, decreasing = TRUE),]
    paths <- rownames(files)
    paths_h <- paths[grep('\\bP_\\w+\\.h$', paths)]
    paths_cpp <- paths[grep('\\bP_\\w+\\.cpp$', paths)]
    system2('clang-format', list('-i', paths_h[1], paths_cpp[1]))
    rstudioapi::navigateToFile(paths_h[1])
    rstudioapi::navigateToFile(paths_cpp[1])
}
