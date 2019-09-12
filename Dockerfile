# This Dockerfile constructs a docker image that contains an installation
# of the popeye library.
#
# Example build:
#   docker build --no-cache --tag nben/popeye `pwd`
#

FROM continuumio/anaconda:latest

LABEL MAINTAINER="Noah C. Benson <nben@nyu.edu>"

ENV PATH "/opt/conda/bin:$PATH"

RUN conda update --yes -n base conda \
 && conda install --yes -c conda-forge py4j nibabel s3fs
RUN pip install --upgrade setuptools

RUN conda install --yes numpy scipy matplotlib pandas
RUN pip install pimms neuropythy
RUN mkdir -p /repos && cd /repos \
 && git clone https://github.com/noahbenson/sco \
 && git clone https://github.com/heikomuller/sco-datastore \
 && git clone https://github.com/heikomuller/sco-engine \
 && git clone https://github.com/heikomuller/sco-models \
 && git clone https://github.com/heikomuller/sco-client \
 && git clone https://github.com/heikomuller/sco-worker \
 && git clone https://github.com/heikomuller/sco-server \
 && git clone https://github.com/heikomuller/sco-ui
RUN cd /repos \
 && for r in sco sco-datastore sco-engine sco-models sco-client sco-worker sco-server; \
    do cd "$r"; \
       [ -r setup.py ] && python setup.py install; \
       pip install -r requirements.txt; \
       cd ..; \
    done

RUN apt-get update && apt-get install -y tini

COPY sco-server.sh /sco-server.sh
COPY sco-config.yml /sco-config.yml
RUN chmod 755 /sco-server.sh
RUN mkdir -p /sco-resources/data

# And mark the entrypoint
ENTRYPOINT [ "tini", "-g", "--", "/sco-server.sh" ]
