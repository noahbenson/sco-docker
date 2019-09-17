
FROM httpd:2.4

LABEL MAINTAINER="Noah C. Benson <nben@nyu.edu>"

# Update Ububtu:

RUN apt-get update \
 && apt-get upgrade -y \
 && apt autoremove -y \
 && apt-get install -y wget bzip2 emacs git python python-pip


# Install a few relevant libraries

RUN pip install numpy scipy matplotlib scikit-image nibabel pandas pimms neuropythy


# Install the SCO libraries

RUN mkdir -p /repos && cd /repos \
 && git clone https://github.com/noahbenson/sco \
 && git clone https://github.com/noahbenson/sco-datastore \
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


# Setup the Apache data:

# Fix the localhost / server name:
RUN cd /repos/sco-ui \
 && mv src/index.html ./orig.index.html \
 && cat ./orig.index.html | sed 's/cds-jaw.cims.nyu.edu/localhost:5000/g' > src/index.html \
 && cat src/index.html

# Copy data over to the appropriate directories
RUN mv /usr/local/apache2/htdocs /usr/local/apache2/orig.htdocs \
 && cp -RL /repos/sco-ui/src /usr/local/apache2/htdocs
COPY ./httpd.conf /usr/local/apache2/conf/httpd.conf

COPY sco-server.sh /sco-server.sh
COPY sco-config.yml /sco-config.yml
RUN chmod 755 /sco-server.sh
RUN mkdir -p /sco-resources/data

# And mark the entrypoint
CMD [ "/sco-server.sh" ]




