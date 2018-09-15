FROM 999eagle/docker-godot-build-server AS build-server
FROM 999eagle/docker-godot-build-templates:x11_64_debug AS build-template-x11-64-debug
FROM 999eagle/docker-godot-build-templates:x11_64_release AS build-template-x11-64-release

FROM ubuntu:18.04

RUN apt-get update && \
	apt-get -y upgrade

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get -y install ca-certificates gnupg2
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
	echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
	apt-get update && \
	apt-get -y install mono-complete

ARG GODOT_VERSION=3.0.6

LABEL mantainer="Sophie Tauchert <sophie@999eagle.moe>"

COPY --from=build-server /build/godot-src/src/bin/godot_server.server.opt.tools.64.mono /build/godot
COPY --from=build-server /build/godot-src/src/bin/GodotSharpTools.dll /build/
COPY --from=build-server /build/godot-src/src/bin/mscorlib.dll /build/

COPY --from=build-template-x11-64-debug   /build/godot-src/src/bin/godot.x11.opt.debug.64.mono /build/data/godot/templates/${GODOT_VERSION}.stable.mono/linux_x11_64_debug
COPY --from=build-template-x11-64-release /build/godot-src/src/bin/godot.x11.opt.64.mono       /build/data/godot/templates/${GODOT_VERSION}.stable.mono/linux_x11_64_release

ENV XDG_CACHE_HOME /build/cache
ENV XDG_CONFIG_HOME /build/config
ENV XDG_DATA_HOME /build/data
RUN mkdir -p ${XDG_CACHE_HOME} && mkdir -p ${XDG_CONFIG_HOME} && mkdir -p ${XDG_DATA_HOME}

WORKDIR /build
