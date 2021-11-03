[![deploy github pages](https://github.com/gdamjan/tidy-tuesday-kika/actions/workflows/deploy-github-pages.yml/badge.svg)](https://github.com/gdamjan/tidy-tuesday-kika/actions/workflows/deploy-github-pages.yml)
[![build docker image](https://github.com/gdamjan/tidy-tuesday-kika/actions/workflows/build-docker-image.yml/badge.svg)](https://github.com/gdamjan/tidy-tuesday-kika/actions/workflows/build-docker-image.yml)
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

## Using the Docker image

The `gdamjan/tidy-tuesday-kika:latest` docker image can be used to build a web site from
the source `.Rmd` files. It includes the needed tools, R and its dependencies, and is
automatically rebuilt when the dependencies are changed
(see the [github actions workflow](.github/workflows/docker-image.yml)).

This is helpful if you want to avoid fiddling with R on your own computer.

```sh
docker run -it --rm \
    --user $UID \
    --workdir /src \
    --volume $PWD:/src/ \
    gdamjan/tidy-tuesday-kika:latest

# now, first update the dependencies if there are some not present in the image
make deps

# next, compile all Rmds and put the result in `./public`
make DESTDIR=./public dist
```
> PS. almost the same steps are done by the [github action](.github/workflows/github-pages.yml)
> which deploys this site to github pages.
