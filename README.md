# Rocker with development packages

This repository contains a Docker image definition that is primarily
designed to serve as a base image for other docker images to build
upon.  It is essentially equivalent to
[rocker/tidyverse](https://rocker-project.org/images/versioned/rstudio.html),
but installs additional Ubuntu packages that may be useful for package
development. 

More packages may be added as needed. Feel free to request additional
packages if you find this image useful.

Inherited from rocker/tidyverse:

* RStudio Server (on port 8787)

* R packages tidyverse, devtools, rmarkdown, data.table, fst, some R
  Database Interface packages, and the Apache Arrow R package.

Main additions:

* LaTeX / XeTeX for PDF output

* Editors (emacs / vim)

* SSH

* Python3

* git / subversion

* Various development packages needed for R packages

* Some additional R packages

# Instructions

## Build

It may be useful to redirect the console output to a log file, as it
will contain informative messages about failures. This may be done
using something like

```
export CVERSION=4.4
time docker build --progress plain --shm-size=2048M --platform=linux/amd64 --tag epiconnector-rdev -f Dockerfile . &> build.log
```

To upload to docker hub:

```
echo ${CVERSION}
docker tag epiconnector-rdev deepayansarkar/rdev:${CVERSION}
docker push deepayansarkar/rdev:${CVERSION}
```


