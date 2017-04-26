#!/bin/sh -ex

cd $HOME/nimble-dev/nimble/packages
rm -f nimble_*.tar.gz

R CMD build \
  --no-build-vignettes \
  --no-manual \
  --no-resave-data \
  nimble

R CMD INSTALL \
  --no-docs \
  --no-html \
  --no-data \
  --no-help \
  --no-demo \
  --no-multiarch \
  --with-keep.source \
  --no-byte-compile \
  nimble_*.tar.gz
