FROM haxe:latest AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app
COPY . /app

RUN haxelib git hxWebSockets https://github.com/jefvel/hxWebSockets
RUN haxelib git weblink https://github.com/PXshadow/weblink 
RUN haxelib install hashlink

RUN haxe build.hxml

## pull hashlink
WORKDIR /hashlink
RUN git clone https://github.com/HaxeFoundation/hashlink .


FROM haxe:latest

# ## Install hashlink
RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ \
    libmbedtls-dev \
    libopenal-dev \
    libpng-dev \
    libsdl2-dev \
    libturbojpeg-dev \
    libuv1-dev \
    libvorbis-dev \
    libsqlite3-dev \
    libglu1-mesa-dev \
    libgl-dev \
    make \
    nginx

WORKDIR /hashlink
COPY --from=build /hashlink /hashlink
RUN make && make install
## clean up
RUN cd /
RUN rm -rf /hashlink


COPY --from=build /app/nginx/nginx.conf /etc/nginx/nginx.conf

WORKDIR /app
COPY --from=build /app/dist /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]