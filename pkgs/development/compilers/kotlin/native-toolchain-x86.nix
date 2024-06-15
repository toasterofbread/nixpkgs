{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "kotlin-native-toolchain";
  version = "2.0.0";

  src = let
    getArch = {
      "x86_64-linux" = "linux-x86_64";
    }.${stdenv.system} or (throw "${pname}-${version}: ${stdenv.system} is unsupported.");

    getUrl = arch: {
      "linux-x86_64" = "https://download.jetbrains.com/kotlin/native/x86_64-unknown-linux-gnu-gcc-8.3.0-glibc-2.19-kernel-4.9-2.tar.gz";
    }.${arch};

    getHash = arch: {
      "linux-x86_64" = "a048397d50fb5a2bd6cc0f89d5a30e0b8ff0373ebff9c1d78ce1f1fb7f185a50";
    }.${arch};
  in
    fetchurl {
      url = getUrl version getArch;
      sha256 = getHash getArch;
    };

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv * $out

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
