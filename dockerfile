FROM --platform=linux/amd64 golang:1.23

ARG WHISPER_MODEL=base.en-q5_1
ARG STT=whisper
ARG STT_SERVICE=whisper.cpp
ARG GGML_CUDA=1

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  cmake

RUN apt-get update && apt-get install -y libomp-dev
RUN mkdir -p /usr/lib/gcc/x86_64-linux-gnu/13
RUN ln -s /usr/lib/gcc/x86_64-linux-gnu/12/libgomp.so /usr/lib/gcc/x86_64-linux-gnu/13/libgomp.so

COPY . .

# Set environment variables for Go bindings
ENV C_INCLUDE_PATH=/app/whisper.cpp
ENV LIBRARY_PATH=/app/whisper.cpp

ENV LD_LIBRARY_PATH=/app/whisper.cpp/build/src
ENV CGO_LDFLAGS="-L/app/whisper.cpp/build/src -lwhisper"
ENV CGO_CFLAGS="-I/app/whisper.cpp"


# Your Go application code can be added here
ENV STT=${STT} \
  STT_SERVICE=${STT_SERVICE} \
  WHISPER_MODEL=${WHISPER_MODEL} \
  GGML_CUDA=${GGML_CUDA}

# RUN chmod +x ./setup.sh && apt-get update && apt-get install -y dos2unix && dos2unix ./setup.sh && apt-get install -y avahi-daemon avahi-autoipd

# Note: ignore error code 2, due to bindings/go make whisper which calls make "libwhisper.a"
RUN ./setup.sh || exit $(($? == 2 ? 0 : $?))

WORKDIR /app/whisper.cpp
RUN make

# RUN chmod +x /chipper/start.sh && dos2unix /chipper/start.sh
WORKDIR /app
CMD ["/bin/sh", "-c", "./chipper/start.sh"]
