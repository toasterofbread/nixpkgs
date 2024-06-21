{ lib
, stdenv
, autoPatchelfHook
, kotlin-native-toolchain-x86
, x86 ? true
}:

stdenv.mkDerivation rec {
  pname = "kotlin-native-toolchain-env";
  version = "2.0.0";

  sourceRoot = ".";
  unpackPhase = "true";

  buildInputs =
    let
      toolchains = [
        (if x86 then kotlin-native-toolchain-x86 else null)
      ];
    in
      builtins.filter (x: x != null) toolchains;

  installPhase = ''
    runHook preInstall

    OUT_DIR=$out/dependencies
    mkdir -p $OUT_DIR

    for toolchain in $buildInputs
    do
      cp -asr $toolchain/* $OUT_DIR
    done

    touch $OUT_DIR/.extracted
    for file in $OUT_DIR/*; do
      if [ -d "$file" ]; then
        echo "$(basename $file)" >> $OUT_DIR/.extracted
      fi
    done

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
