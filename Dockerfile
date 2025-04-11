#
# Container image with NHANES data inside a Postgres database
# Author: Deepayan Sarkar

## Build / run: See README.md

# rocker/r-base is Debian unstable, whereas rocker/r-ver|tidyverse is
# Ubuntu LTS. It has more stuff built-in, including RStudio server,
# DBI, etc, but no arm64 support

FROM rocker/tidyverse:4.4

# TODO: See <https://eddelbuettel.github.io/r2u/> to get binary packages

#------------------------------------------------------------------------------
# Basic initial system configuration
#------------------------------------------------------------------------------

USER root

# install standard Ubuntu Server packages --- WHY?
# RUN yes | unminimize

# we're going to create a non-root user at runtime and give the user sudo
RUN apt-get update && \
	apt-get -y install sudo \
	&& echo "Set disable_coredump false" >> /etc/sudo.conf
	
# set locale info
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& apt-get update && apt-get install -y locales \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"
ENV TZ="America/New_York"

WORKDIR /tmp

#------------------------------------------------------------------------------
# Install system tools and libraries via apt
#------------------------------------------------------------------------------

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install \
	       -y \
	       ca-certificates \
	       curl \
	       less \
	       libgomp1 \
	       libpango-1.0-0 \
	       libxt6 \
	       libsm6 \
	       make \
	       texinfo \
	       texlive-latex-base \
	       texlive-latex-recommended \
	       texlive-latex-extra \
	       texlive-xetex \
	       fonts-noto \
	       libtiff-dev \
	       libpng-dev \
	       libicu-dev \
	       libpcre3 \
	       libpcre3-dev \
	       libbz2-dev \
	       liblzma-dev \
	       gcc \
	       g++ \
	       openjdk-8-jre \
	       openjdk-8-jdk \
	       gfortran \
	       libreadline-dev \
	       libx11-dev \
	       libcurl4-openssl-dev \
	       libssl-dev \
	       libxml2-dev \
	       wget \
	       openssh-server \
	       ssh \
	       xterm \
	       xauth \
	       screen \
	       subversion-tools \
	       git libgit2-dev \
	       nano emacs vim \
	       gnupg \
	       krb5-user \
	       python3-dev \
	       python3 \
	       python3-pip \
	       # libaio1 \
	       libaio1t64 \
	       pkg-config \
	       libkrb5-dev \
	       unzip \
	       cifs-utils \
	       lsof \
	       libnlopt-dev \
	       libopenblas-openmp-dev \
	       libpcre2-dev \
	       systemd \
	       libcairo2-dev \
	       libharfbuzz-dev \
	       libfribidi-dev \
	       cmake \
	       qpdf \
	       postgresql postgresql-client phppgadmin libpq-dev \
    && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------
# Configure system tools
#------------------------------------------------------------------------------

# Create a mount point for host filesystem data, enable password
# authedtication over SSH, configure X11, tell git to use the cache
# credential helper and set a 1 day-expiration

RUN mkdir /HostData \
    && mkdir /var/run/sshd	\
    && sed -i 's!^#PasswordAuthentication yes!PasswordAuthentication yes!' /etc/ssh/sshd_config \
    && sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config \
    && sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config \
    && grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config \
    && git config --system credential.helper 'cache --timeout 86400'


#------------------------------------------------------------------------------
# Additional R packages that are potentially useful for data analysis
#------------------------------------------------------------------------------

RUN Rscript -e "install.packages(c('git2r', 'getPass', 'xlsx', 'forestplot', 'glmnet', 'glmpath', 'kableExtra', 'plotROC', 'sjPlot', 'survey', 'mitools', 'bookdown', 'lme4', 'survminer', 'DT', 'Hmisc', 'latticeExtra'))"

# allow modification of these locations so users can install R packages without warnings
RUN chmod -R 777 /usr/local/lib/R/library
RUN chmod -R 777 /usr/local/lib/R/site-library
RUN chmod -R 777 /usr/local/lib/R/doc/html/packages.html

# Copy startup script
RUN mkdir /startup
COPY startup.sh /startup/startup.sh
RUN chmod 700 /startup/startup.sh

CMD ["/startup/startup.sh"]

# Local Variables:
# mode: sh
# End:
