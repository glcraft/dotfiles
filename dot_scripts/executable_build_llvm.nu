#!/usr/bin/env nu
def main [] {
    # Définir ROOT comme le répertoire courant si non défini
    let root = ($env | get -i ROOT | default (pwd))
    let build_dir = ($root | path join build)
    let install_dir = ($root | path join install)
    
    # Créer un dossier build s'il n'existe pas déjà
    mkdir $build_dir
    
    # Aller dans le répertoire build
    enter $build_dir
    
    # Définir des variables en fonction du système d'exploitation
    let ismac = ((sys | get host.name) == 'Darwin')
    
    let args = [
        '-DCMAKE_BUILD_TYPE=Release',
        $'-DCMAKE_INSTALL_PREFIX=($install_dir)',
        '-DLIBCXX_ENABLE_INCOMPLETE_FEATURES=ON',
        '-DLIBCXX_ENABLE_STD_MODULES=ON',
        '-DLIBCXX_INSTALL_MODULES=ON',
        '-DLLVM_ENABLE_PROJECTS=clang;clang-tools-extra;lldb;lld',
        '-DLLVM_ENABLE_RUNTIMES=compiler-rt;libcxx;libcxxabi;libunwind',
        '-DLLVM_ENABLE_DOXYGEN=OFF',
        '-DLLVM_BUILD_TESTS=OFF',
        '-DLLVM_BUILD_LLVM_DYLIB=ON',
        '-DLLVM_LINK_LLVM_DYLIB=ON'
        ]
    if $ismac {
        $args += [
            '-DLLVM_CREATE_XCODE_TOOLCHAIN=ON',
            '-DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk',
            $'-DCMAKE_OSX_ARCHITECTURES=($nu.os-info.arch)'
        ]
    }
    
    # Exécuter CMake pour configurer et compiler LLVM
    cmake -G Ninja ...$args ($root | path join llvm) 
    cmake --build . --parallel
    
    # Installer LLVM, avec des étapes supplémentaires pour macOS
    if $ismac {
        cmake --build . --target install-xcode-toolchain
    } else {
        cmake --install .
    }
    
    # Retourner au répertoire précédent
    p
}

