FROM ubuntu:19.10

ENV DEPOT_TOOLS_PATH=/depot_tools
ENV PATH=$PATH:$DEPOT_TOOLS_PATH
ENV VPYTHON_BYPASS="manually managed python not supported by chrome operations"
ENV V8_VERSION="7.3.495"

COPY 0001-support-ninja-ppc64le.patch /tmp/0001-support-ninja-ppc64le.patch
COPY 0002-modify-the-gn-bin-path.patch /tmp/0002-modify-the-gn-bin-path.patch

RUN apt-get update && apt-get install --no-install-recommends -y pkg-config libglib2.0-dev clang-tools-9 vim libc6-dev make dpkg-dev python2.7 python3.8 git curl software-properties-common && \
update-alternatives --install /usr/bin/g++ c++ /usr/bin/clang++-9 1 && \
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 2 && \
update-alternatives --install /usr/bin/gcc gcc /usr/bin/clang-9 3 && \
update-alternatives --install /usr/bin/python python /usr/bin/python2.7 4 && \

echo "Fetch depot_tools" && \
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $DEPOT_TOOLS_PATH && \
export PATH="$PATH:$DEPOT_TOOLS_PATH" && \

echo "[CIPD] Missing https://chrome-infra-packages.appspot.com/p/infra/3pp/tools/cpython3/linux-ppc64le" && \
echo "[CPID] Fallback to host Python 3.8" && \  
ln -sf /usr/bin/python3.8 $DEPOT_TOOLS_PATH/python3 && \

echo "depot_tools does not offer ninja binary for ppc64le" && \
echo "Fall back to manually-built ninja" && \
cd /tmp && git clone https://github.com/ninja-build/ninja.git -b v1.8.2 && cd ninja && python3 ./configure.py --bootstrap && mv ./ninja $DEPOT_TOOLS_PATH/ninja-linux-ppc64le && \
# Amend depot_tools/ninja to pick up correct binary for ppc64le
cd $DEPOT_TOOLS_PATH && patch -p1 < /tmp/0001-support-ninja-ppc64le.patch && \


echo "[CIPD] Missing https://chrome-infra-packages.appspot.com/p/gn/gn/linux-ppc64le" && \
echo "[CIPD] Fallback to manually-built gn" && \
mv $DEPOT_TOOLS_PATH/gn $DEPOT_TOOLS_PATH/gn-linux-amd64
cd /tmp && git clone https://gn.googlesource.com/gn && cd gn && python3 build/gen.py && ninja -C out && \
cp -f out/gn $DEPOT_TOOLS_PATH/gn-linux-ppc64le && ln -sf $DEPOT_TOOLS_PATH/gn-linux-ppc64le $DEPOT_TOOLS_PATH/gn && \

echo "Fetch & build V8"
cd /tmp && fetch v8 && \
cd /tmp/v8 && git fetch origin && git checkout $V8_VERSION && gclient sync -D && \
cd /tmp/v8 && \
gn gen out.gn/libv8 --args='clang_use_chrome_plugins=false linux_use_bundled_binutils=false use_custom_libcxx=false use_sysroot=false is_debug=false symbol_level=0 is_component_build=false v8_monolithic=true v8_use_external_startup_data=false target_cpu="ppc64" v8_target_cpu="ppc64" treat_warnings_as_errors=false' && \
ninja -v -C out.gn/libv8 v8_monolith

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
