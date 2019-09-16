#! /bin/bash

export PATH="/opt/conda/bin:$PATH"

# Starts the SCO Server on the SCO-GUI docker image

{ cd /repos/sco-server
  export FLASK_APP=scoserv.server
  export FLASK_ENV=development
  export SCOSERVER_CONFIG=/sco-config.yml

  flask run --host=0.0.0.0
} &

httpd-foreground

