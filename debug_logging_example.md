**Objective:** Enable printf-style debugging of recursive function calls
with minimal code.

Let's define a simple recursive debug logger. The logger will print
function name, argument names and values, and return value. We want the
logger to be minmally invasive so that it is easy to annotate a function
as debugged.

    ## Logging annotations for internal functions.
    ## Logging is controlled by the environment variable NIMBLE_LOG.
    ## For example to log a function `myFun` to the `DEBUG channel`, annotate the function definition with
    ##   myFun <- 'DEBUG' %logged% function (...) {...}
    ## and add `DEBUG` to the list of logged channels
    ##   NIMBLE_LOG=DEBUG  R CMD BATCH myScript.R   # in bash.
    ## or
    ##   Sys.setenv(NIMBLE_LOG = 'DEBUG'); ...reload nimble library...  # in R.
    ## To enable multiple loggingn channels, set `NIMBLE_LOG` to a comma delimited list.
    `%logged%` <- function(prefix, fun) {
        # if (length(grep(prefix, Sys.getenv('NIMBLE_LOG'))) == 0) return(fun)  # Logging is disabled.
        function (...) {
            .GlobalEnv$.log.indent <- max(0, .GlobalEnv$.log.indent)
            prefix <- paste0(prefix, paste0(rep('  ', .GlobalEnv$.log.indent), collapse=''))
            cat(prefix, deparse(match.call()), '\n', file = stderr())
            cat(prefix, '>', capture.output(print(list(...))), '\n', file = stderr())
            .GlobalEnv$.log.indent <- .GlobalEnv$.log.indent + 1
            tryCatch({
                ret <- fun(...)
            }, finally = {
                .GlobalEnv$.log.indent <- .GlobalEnv$.log.indent - 1
            })
            cat(prefix, '<', capture.output(print(ret)), '\n', file = stderr())
            return(ret)
        }
    }

To use our debugger, we need only prepend `'DEBUG' %logged%` to each
function we want to debug. Suppose we start with a function

    fib <- function (x) {
        if (x == 0 || x == 1) return(x)
        return(fib(x - 1) + fib(x - 2))
    }
    fib(5)

    ## [1] 5

To debug `fib`, we'll simply add `'DEBUG' %logged%` to its definition
(typically deep in some .R file)

    fib <- 'DEBUG' %logged% function (x) {  # <--- only this line changed
        if (x == 0 || x == 1) return(x)
        return(fib(x - 1) + fib(x - 2))
    }
    fib(5)

    ## [1] 5

Here the `>` lines print the input arguments to `fib()` and the `>`
print its return value. Since `fib()` calls itself, we also see
intermediate logging between `>` and `<`.

If you want to log two different subsystems, you can give them different
prefixes instead of just `'DEBUG'`, but all prefixes should have the
same number of characters.
