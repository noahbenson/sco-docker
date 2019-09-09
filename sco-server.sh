#! /bin/bash

export PATH="/opt/conda/bin:$PATH"

# Starts the SCO Server on the SCO-GUI docker image

cd repos/sco-server
export FLASK_APP=scoserv.server
export FLASK_ENV=development
export SCOSERVER_CONFIG=/sco-config.yml
exec flask run
