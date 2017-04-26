
setwd('~/nimble-dev/nimble/packages')
profilePath <- '/tmp/install-nimble.Rprof'

Rprof(profilePath)
try(tools:::.install_packages(args = c('nimble')))
Rprof(NULL)

summaryRprof(profilePath)
