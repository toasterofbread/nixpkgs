{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, python3
, ninja
, cmake
, libxcrypt
, gcc12
, zlib
}:

stdenv.mkDerivation rec {
  pname = "kotlin-native-llvm-x86";
  version = "2.0.0";

  srcs = [
    (fetchurl {
      url = "https://github.com/llvm/llvm-project/archive/refs/heads/release/11.x.tar.gz";
      sha256 = "sha256-uEb37eEDJM27jqgVr4K6uXpePThwlFWJ2jT7fW+dTT0=";
    })

    (fetchurl {
      url = "https://download.jetbrains.com/kotlin/native/llvm-11.1.0-linux-x64-essentials.tar.gz";
      sha256 = "sha256-5djTEoLx7u//AG2nT3Y8oY7jmXgtB3zNkmk7Uf6xeiE=";
    })
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    python3
    ninja
    cmake
    libxcrypt
    gcc12
    zlib
  ];

  sourceRoot = "llvm-project-release-11.x";
  dontUseCmakeConfigure = true;

  patches = [
    ./patches-native-llvm/fix-llvm-build.patch
  ];

  buildPhase = ''
    # https://bugs.gentoo.org/907895
    export CC=${gcc12}/bin/gcc
    export CXX=${gcc12}/bin/g++

    TOP_DIR=$(pwd)

    mkdir build
    pushd build

    cmake \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_ENABLE_ASSERTIONS=OFF \
      -DLLVM_ENABLE_TERMINFO=OFF \
      -DLLVM_INCLUDE_GO_TESTS=OFF \
      -DLLVM_ENABLE_Z3_SOLVER=OFF \
      -DCOMPILER_RT_BUILD_BUILTINS=ON \
      -DLLVM_ENABLE_THREADS=ON \
      -DLLVM_OPTIMIZED_TABLEGEN=ON \
      -DLLVM_ENABLE_IDE=OFF \
      -DLLVM_BUILD_UTILS=ON \
      -DLLVM_INSTALL_UTILS=ON \
      -DCMAKE_INSTALL_PREFIX=$TOP_DIR/INSTALL \
      -DLLVM_TARGETS_TO_BUILD=Native \
      -DLLVM_ENABLE_PROJECTS=clang \
      -DLLVM_BUILD_LLVM_DYLIB=OFF \
      -DLLVM_LINK_LLVM_DYLIB=OFF \
      $TOP_DIR/llvm

    ninja install-distribution install
  '';

  installPhase = ''
    mkdir -p $out
    cp -rT /build/llvm-11.1.0-linux-x64-essentials/lib $out/lib
    cp -rT /build/llvm-project-release-11.x/INSTALL/bin $out/bin
  '';

  meta = {
    homepage = "https://github.com/JetBrains/kotlin/tree/master/kotlin-native/tools/llvm_builder";
    description = "LLVM distribution used by Kotlin/Native";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
