if [[ ! -d "build" ]]; then
    mkdir build
fi
pushd build

cmake -G Ninja \
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PWD/../install \
    -DPYTHON_EXECUTABLE=/usr/bin/python3 \
    -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON \
    -DLLVM_CREATE_XCODE_TOOLCHAIN=ON \
    "-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lldb;lld" \
    "-DLLVM_ENABLE_RUNTIMES=compiler-rt;libcxx;libcxxabi;libunwind" \
    -DLIBCXXABI_USE_LLVM_UNWINDER=YES \
    -DLIBCXX_ENABLE_STD_MODULE=ON \
    -DLIBCXX_INSTALL_MODULES=ON \
    -DLLVM_ENABLE_DOXYGEN=OFF \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_BUILD_LLVM_DYLIB=ON \
    -DLLVM_LINK_LLVM_DYLIB=ON \
    -DLLVM_TARGETS_TO_BUILD="X86;ARM;AArch64" \
    -DCMAKE_OSX_ARCHITECTURES="arm64" \
    ../llvm \
&& ninja -j12 \
&& cmake --build . --target install-xcode-toolchain

popd