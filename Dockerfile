FROM rocker/shiny:latest

MAINTAINER Clemens Schmid <clemens@nevrome.de>

RUN mkdir /srv/shiny-server/app
COPY . /srv/shiny-server/app

# create config 
RUN echo "run_as shiny; \
		     server { \
  		       listen 3838; \
  		       location / { \
    		         app_dir /srv/shiny-server/app; \
    		         directory_index off; \
    		         log_dir /var/log/shiny-server; \
  		       } \
		     }" > /etc/shiny-server/shiny-server.conf

# if config file exists, then add it, overwriting the sample file
RUN if [ -f /srv/shiny-server/app/shiny-server.conf ]; \
               then (>&2 echo "Using config file inside app directory") \
               && cp /srv/shiny-server/app/shiny-server.conf /etc/shiny-server/shiny-server.conf; \
               fi

# install necessary system packages
RUN apt-get update -qq \
  && apt-get install -t unstable -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libsqlite3-dev \
    libxml2-dev \
    qpdf \
    vim \
    git \
    udunits-bin \
    libproj-dev \
    libgeos-dev \
    libgdal-dev \
    libudunits2-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# install necessary R packages
RUN R -e "install.packages('automagic')"
RUN R -e "setwd('/srv/shiny-server/app'); automagic::automagic()"

# give user shiny ability to install new packages and to manipulate data in the app
RUN usermod -a -G staff shiny
RUN chown -R :shiny /srv/shiny-server/app/data
RUN chmod -R 775 /srv/shiny-server/app/data

# start it
CMD exec shiny-server >> /var/log/shiny-server.log 2>&1
