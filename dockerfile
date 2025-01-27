FROM ubuntu


COPY . .

RUN chmod +x /setup.sh && apt-get update && apt-get install -y dos2unix && dos2unix /setup.sh && apt-get install -y avahi-daemon avahi-autoipd

ENV STT=whisper
ENV WHISPER_MODEL=base
RUN ["/bin/sh", "-c", "./setup.sh"]

RUN chmod +x /chipper/start.sh && dos2unix /chipper/start.sh

CMD ["/bin/sh", "-c", "./chipper/start.sh"]
