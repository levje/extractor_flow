FROM scilus/scilus:2.1.0

WORKDIR /

RUN mkdir extractor_flow
ADD containers/filtering_lists.tar.bz2 /extractor_flow/
ADD containers/templates_and_ROIs.tar.bz2 /extractor_flow/