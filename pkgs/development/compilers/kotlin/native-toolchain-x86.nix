{ lib
, stdenv
, autoPatchelfHook
, fetchurl
}:

stdenv.mkDerivation rec {
  pname = "kotlin-native-toolchain-x86";
  version = "2.0.0";
  
  srcs = [
    (fetchurl {
      url = "https://download.jetbrains.com/kotlin/native/x86_64-unknown-linux-gnu-gcc-8.3.0-glibc-2.19-kernel-4.9-2.tar.gz";
      sha256 = "0922kif8z28yvvzpdh3bwf8i21dym66hxj47q0vrhh7nbynqbii2";
      name = "x86_64-unknown-linux-gnu-gcc-8.3.0-glibc-2.19-kernel-4.9-2";
    })
    (fetchurl {
      url = "https://download.jetbrains.com/kotlin/native/lldb-4-linux.tar.gz";
      sha256 = "19r56d7h9zcdy0k6rksli1nvdwqxcpa0zy9akcxzxa6pba0ivw8x";
      name = "lldb-4-linux";
    })
    (fetchurl {
      url = "https://download.jetbrains.com/kotlin/native/llvm-11.1.0-linux-x64-essentials.tar.gz";
      sha256 = "1yr476d4l3wm7ggid6z77bzs4qsis56spvq0ksav8ygd6p5zxh2z";
      name = "llvm-11.1.0-linux-x64-essentials";
    })
    (fetchurl {
      url = "https://download.jetbrains.com/kotlin/native/libffi-3.2.1-2-linux-x86-64.tar.gz";
      sha256 = "0qp66pvka2mpnzcpg22bjcnlx7cpvircc4ha254xcclw5kvbw2fa";
      name = "libffi-3.2.1-2-linux-x86-64";
    })
  ];
  
  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];

  buildPhase = ''
    for s in $srcs
    do
      mkdir -p $out/$s
      tar -xzf $s -C $out/$s
    done
  '';

  #installPhase = ''
  #'';

  meta = {
    homepage = "https://kotlinlang.org/";
    description = "Modern programming language that makes developers happier";
    longDescription = ''
      Kotlin/Native is a technology for compiling Kotlin code to native
      binaries, which can run without a virtual machine. It is an LLVM based
      backend for the Kotlin compiler and native implementation of the Kotlin
      standard library.
    '';
    #license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
