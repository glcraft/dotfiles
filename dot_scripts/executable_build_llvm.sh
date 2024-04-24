if [[ -z ${ROOT+x} ]]; then
	ROOT=$PWD
fi

if [[ ! -d "build" ]]; then
	mkdir build
fi
pushd build

[[ "$(uname)" == "Darwin" ]] && ISMAC=Y || ISMAC=N

ARGS=$(
	cat <<EOF
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$ROOT/install 
    -DPYTHON_EXECUTABLE=/usr/bin/python3 
    -DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON 
    -DLIBCXX_ENABLE_STD_MODULES=ON 
    -DLIBCXX_INSTALL_MODULES=ON 
    -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra;lldb;lld' 
    -DLLVM_ENABLE_RUNTIMES='compiler-rt;libcxx;libcxxabi;libunwind' 
    -DLLVM_ENABLE_DOXYGEN=OFF 
    -DLLVM_BUILD_TESTS=OFF 
    -DLLVM_BUILD_LLVM_DYLIB=ON 
    -DLLVM_LINK_LLVM_DYLIB=ON
EOF
)
if [[ $ISMAC == "Y" ]]; then
	ARGS+=$(
		cat <<EOF
    -DLLVM_CREATE_XCODE_TOOLCHAIN=ON 
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
    -DCMAKE_OSX_ARCHITECTURES="$(arch)"
EOF
	)
fi

cmake -G Ninja $ARGS "$ROOT/llvm" && cmake --build . --parallel

if [[ $ISMAC == "Y" ]]; then
	cmake --build . --target install-xcode-toolchain
else
	cmake --install .
fi

popd