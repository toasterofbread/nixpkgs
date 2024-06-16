{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "kotlin-native-toolchain-x86";
  version = "2.0.0";
  
  src = "./";
  
  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = let
    gcc = fetchurl {
      url = "https://download.jetbrains.com/kotlin/native/x86_64-unknown-linux-gnu-gcc-8.3.0-glibc-2.19-kernel-4.9-2.tar.gz";
      sha256 = "a048397d50fb5a2bd6cc0f89d5a30e0b8ff0373ebff9c1d78ce1f1fb7f185a50";
    };

    lldb = fetchurl {
      url = "https://download.jetbrains.com/kotlin/native/lldb-4-linux.tar.gz";
      sha256 = "b1e145c859f44071f66231cfc98c8c16a480cbf47139fcd5dd2df4bf041fdfda";
    };

    llvm = fetchurl {
      url = "https://download.jetbrains.com/kotlin/native/llvm-11.1.0-linux-x64-essentials.tar.gz";
      sha256 = "e5d8d31282f1eeefff006da74f763ca18ee399782d077ccd92693b51feb17a21";
    };

    libffi = fetchurl {
      url = "https://download.jetbrains.com/kotlin/native/libffi-3.2.1-2-linux-x86-64.tar.gz";
      sha256 = "9d817bbca098a2fa0f1d5a8b9e57674c30d100bb4c6aeceff18d8acc5b9f382c";
    };
  in
    ''
      runHook preInstall

      mkdir -p $out/x86_64-unknown-linux-gnu-gcc-8.3.0-glibc-2.19-kernel-4.9-2
      mv $gcc/* $out/x86_64-unknown-linux-gnu-gcc-8.3.0-glibc-2.19-kernel-4.9-2

      mkdir -p $out/lldb-4-linux.tar.gz
      mv $lldb/* $out/lldb-4-linux.tar.gz

      mkdir -p $out/llvm-11.1.0-linux-x64-essentials.tar.gz
      mv $llvm/* $out/llvm-11.1.0-linux-x64-essentials.tar.gz

      mkdir -p $out/libffi-3.2.1-2-linux-x86-64.tar.gz
      mv $libffi/* $out/libffi-3.2.1-2-linux-x86-64.tar.gz

      runHook postInstall
    '';

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
