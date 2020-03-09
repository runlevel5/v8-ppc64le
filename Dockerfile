FROM ubuntu:bionic

ENV PATH=$PATH:/depot_tools
ENV VPYTHON_BYPASS="manually managed python not supported by chrome operations"
ENV V8_VERSION="7.3.495"
ENV GN_BIN_PATH="/gn/out"

COPY 0001-support-ninja-ppc64le.patch /tmp/0001-support-ninja-ppc64le.patch
COPY 0002-modify-the-gn-bin-path.patch /tmp/0002-modify-the-gn-bin-path.patch

RUN apt-get update && apt-get install -y pkg-config libglib2.0-dev clang-tools-9 vim libc6-dev make dpkg-dev python2.7 ninja-build git curl software-properties-common && \
update-alternatives --install /usr/bin/g++ c++ /usr/bin/clang++-9 1 && \
update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang-9 2 && \
ln /usr/bin/clang++-9 /usr/bin/clang++ && \
add-apt-repository -y ppa:deadsnakes/ppa && apt install -y python3.8 && \
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /depot_tools && \
mkdir -p /depot_tools/bootstrap-3.8.0.chromium.8_bin/python3/bin/ && \
ln -sf /usr/bin/python3 /depot_tools/bootstrap-3.8.0.chromium.8_bin/python3/bin/python3 && \
cd / && git clone https://gn.googlesource.com/gn && cd gn && python build/gen.py && ninja -C out && \
cd /tmp && fetch v8 && \
cd /tmp/v8 && git fetch origin && git checkout $V8_VERSION && gclient sync && \
cd /depot_tools && patch -p1 < /tmp/0001-support-ninja-ppc64le.patch && patch -p1 < /tmp/0002-modify-the-gn-bin-path.patch && \
cd /tmp/v8 && \
gn gen out.gn/libv8 --args='clang_use_chrome_plugins=false linux_use_bundled_binutils=false use_custom_libcxx=false use_sysroot=false is_debug=false symbol_level=0 is_component_build=false v8_monolithic=true v8_use_external_startup_data=false target_cpu="ppc64" v8_target_cpu="ppc64" treat_warnings_as_errors=false' && \
ninja -v -C out.gn/libv8 v8_monolith

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"

