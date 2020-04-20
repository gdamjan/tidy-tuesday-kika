# TidyTuesday At KIKA

Slides and other resources from the #TidyTuesday events at [KIKA](https://kika.spodeli.org) hacklab in Skopje.


## CI

This repository is configured to use Github Actions that builds `.Rmd` files to
a static site, that's then published as `gh-pages`.

To improve on the velocity of the build, a custom docker image is pre-built that includes
all the dependencies needed for the site.

## Adding dependencies

R dependencies should be added to the `DESCRIPTION` file (see the `Imports:` list).
If the dependencies are also available as ubuntu 20.04 packages add them
in `ubuntu-packages.list` too, that will avoid them beeing built from source.

All dependencies will be installed in the docker image, so it can be used for building
the site. Running `make deps` will also install dependencies locally but make sure you
have `R`, `devtools` and the rest of the system dependencies installed.
