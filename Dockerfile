From python:3.7

RUN apt-get update
RUN apt-get -y upgrade

RUN apt -y install libblas-dev
RUN apt -y install liblapack-dev
RUN apt -y install libgl1-mesa-glx
RUN apt -y install libglu1
RUN apt -y install jq
RUN apt -y install rename

ADD JHU_template_GIN_dil.tar.bz2 /JHU_template_GIN_dil
ADD filtering_lists.tar.bz2 /filtering_lists

WORKDIR /
ENV SCILPY_VERSION="master"
RUN wget https://github.com/scilus/scilpy/archive/${SCILPY_VERSION}.zip
RUN unzip ${SCILPY_VERSION}.zip
RUN mv scilpy-${SCILPY_VERSION} scilpy

WORKDIR /scilpy
RUN pip install -e .

RUN sed -i '41s/.*/backend : Agg/' /usr/local/lib/python3.7/site-packages/matplotlib/mpl-data/matplotlibrc

WORKDIR /
RUN wget http://trackvis.org/bin/TrackVis_v0.6.1_x86_64.tar.gz
run mkdir TrackVis
RUN tar -xzf TrackVis_v0.6.1_x86_64.tar.gz -C TrackVis
ENV PATH="/TrackVis:${PATH}"
