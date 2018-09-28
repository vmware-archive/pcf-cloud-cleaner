FROM ubuntu

COPY clean-empty-folders.sh /usr/bin/clean-empty-folders
COPY setup.sh /usr/bin/setup-pcf-image
COPY run.sh /usr/bin/run-cloud-cleaner
RUN setup-pcf-image
RUN apt-get install -y jq python python-pip python-yaml
