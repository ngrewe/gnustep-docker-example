FROM ngrewe/gnustep-headless-rt
MAINTAINER niels.grewe@halbordnung.de

COPY stage_ws/usr/local /usr/local
COPY stage/usr/local /usr/local
RUN ldconfig
EXPOSE 8080
ENTRYPOINT [ "/usr/local/bin/WebServerExample" ]
CMD [ "-Port", "8080", "-Debug", "NO" ]
