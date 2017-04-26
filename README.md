# Developer tools for the [NIMBLE](http://r-nimble.org) project

## Speed up package installation

These steps attempt to speed up `R CMD build nimble && R CMD INSTALL nimble_*.tar.gz`:

1.  (Savings: 50%) On Linux or OS X, use ccache.
    Following Dirk Eddelbuettel's [advice](http://stackoverflow.com/questions/13929514/how-to-enable-ccache-on-linux), you can enable ccache globally on your system by creating symbolic links to ccache for each of the compilers you use: 

    ```{sh}
    cd /usr/local/bin
    sudo ln -s /usr/bin/ccache gcc
    sudo ln -s /usr/bin/ccache g++
    sudo ln -s /usr/bin/ccache clang
    sudo ln -s /usr/bin/ccache clang++
    ```

2.  (Savings: 25%) Add tons of `--no-<expensive operation>` flags to your R CMD INSTALL invocation.
     Fritz wrapped this in a script [nim-install.sh](nim-install.sh) in this repo.
     **TODO** add a .bat file or something for Windows users.
     
3.  Further research is needed. Fritz started to profile package installation with [profile_install_nimble.R](profile_install_nimble.R)

## Run a single test file

Perry suggested the following test wrapper to run tests in a single file:

```{r}().
library(nimble)
library(testthat)
source(system.file(file.path('tests', 'test_utils.R'), package = 'nimble'))
if (0) options(error = recover) else options(error = NULL)  # Toggle 0/1 to enable/disable recover().

# This tests the file 'tests/test-optim.R'.
test_package('nimble', 'optim', reporter = 'tap')  # tap has prettier error reporting.
```

## Navigate Source Code

If you're an Emacs or Vim user, you can make use of the [`rtags()`](https://www.rdocumentation.org/packages/utils/versions/3.3.2/topics/rtags) function to generate tags files to more quickly navigate source code.
Perry recommends the command `R CMD rtags`.
This lets you jump-to-defintion of a symbol.
