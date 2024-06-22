{ lib
, stdenv
, autoPatchelfHook
, kotlin-native-llvm
, x86_64 ? true
, aarch64 ? true
}:

stdenv.mkDerivation rec {
  pname = "kotlin-native-toolchain";
  version = "2.0.0";

  srcs =
  let
    deps = [
      (if x86_64 then
        (builtins.fetchTarball {
        url = "https://download.jetbrains.com/kotlin/native/x86_64-unknown-linux-gnu-gcc-8.3.0-glibc-2.19-kernel-4.9-2.tar.gz";
        sha256 = "0922kif8z28yvvzpdh3bwf8i21dym66hxj47q0vrhh7nbynqbii2";
        name = "x86_64-unknown-linux-gnu-gcc-8.3.0-glibc-2.19-kernel-4.9-2";
        })
      else null)

      (if aarch64 then
        (builtins.fetchTarball {
          url = "https://download.jetbrains.com/kotlin/native/aarch64-unknown-linux-gnu-gcc-8.3.0-glibc-2.25-kernel-4.9-2.tar.gz";
          sha256 = "1yvbn0k364yph0smlh7g0j34n3j0cg5gk10h9s3l0k8gn1jwy46p";
          name = "aarch64-unknown-linux-gnu-gcc-8.3.0-glibc-2.25-kernel-4.9-2";
        })
      else null)
    ];
  in
    (builtins.filter (x: x != null) deps) ++ [
      (builtins.fetchTarball {
        url = "https://download.jetbrains.com/kotlin/native/lldb-4-linux.tar.gz";
        sha256 = "19r56d7h9zcdy0k6rksli1nvdwqxcpa0zy9akcxzxa6pba0ivw8x";
        name = "lldb-4-linux";
      })
      (builtins.fetchTarball {
        url = "https://download.jetbrains.com/kotlin/native/libffi-3.2.1-2-linux-x86-64.tar.gz";
        sha256 = "0qp66pvka2mpnzcpg22bjcnlx7cpvircc4ha254xcclw5kvbw2fl";
        name = "libffi-3.2.1-2-linux-x86-64";
      })
    ];

  sourceRoot = ".";
  nativeBuildInputs = [
    autoPatchelfHook
    kotlin-native-llvm
  ];

  preBuild = ''
    addAutoPatchelfExcludePath $out/llvm-11.1.0-linux-x64-essentials/bin
  '';

  installPhase = ''
    mkdir -p $out

    for s in $srcs
    do
      name=$(basename $s)
      dest_file=$(echo "$name" | cut -c 34-)
      mkdir -p $out/$dest_file
      cp -R $s/* $out/$dest_file
    done

    cp -TR ${kotlin-native-llvm} $out/llvm-11.1.0-linux-x64-essentials
  '';

  meta = {
    homepage = "https://kotlinlang.org/";
    description = "Toolchain used by Kotlin/Native for C interoperability";
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
