{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, crosstool-ng
, git
, bintools
, which
, glibc
, wget
, cacert
, m4
, autoconf

, nix-ld
, buildFHSUserEnv
}:

stdenv.mkDerivation rec {
  pname = "kotlin-native-gcc-x86";
  version = "2.0.0";

  srcs = [
    (fetchFromGitHub {
      owner = "jetbrains";
      repo = "kotlin";
      rev = "v${version}";
      sha256 = "sha256-js+I20OmUJQk3sI4pJZLGiWrsshSm9W2jyhqWSQkSgY=";
      name = "kotlin";
    })

    #(fetchurl {
      #url = "http://www.kernel.org/pub/linux/kernel/v4.x/linux-4.9.156.tar.xz";
      #sha256 = "sha256-aLd1L9c3eHvm4tcCfW+oN5Y1gFw1oscwxzePKvjSPUk=";
      #name = "linux-4.9.156.noextract";
    #})
  ];

  nativeBuildInputs = [
    crosstool-ng
    git
    bintools
    which
    glibc.static
    wget
    cacert
    m4
    autoconf
    autoPatchelfHook

    nix-ld
    (buildFHSUserEnv {
      name = "fhs";
    })
  ];

  sourceRoot = "kotlin";

  unpackCmd = ''
    if [[ "$curSrc" == "${builtins.elemAt srcs 0}" ]]; then
      cp -r $curSrc kotlin
    else
      echo "Unknown src '$curSrc'"
      exit 1
    fi
  '';

  buildPhase = ''
    BUILD_DIR=$(pwd)/kotlin-native/tools/toolchain_builder/build-x86_64-unknown-linux-gnu/.build/
    PATCH_DIR=$(pwd)/nix-patch

git apply << EOM
diff --git a/kotlin-native/tools/toolchain_builder/build_toolchain.sh b/kotlin-native/tools/toolchain_builder/build_toolchain.sh
index 42416d363..bc12451d8 100644
--- a/kotlin-native/tools/toolchain_builder/build_toolchain.sh
+++ b/kotlin-native/tools/toolchain_builder/build_toolchain.sh
@@ -5,11 +5,11 @@ set -eou pipefail
 TARGET=\$1
 VERSION=\$2
 TOOLCHAIN_VERSION_SUFFIX=\$3
-HOME=/home/ct
+HOME=\$(pwd)
 ZLIB_VERSION=1.2.11

 build_toolchain() {
-  mkdir \$HOME/build-"\$TARGET"
+  mkdir -p \$HOME/build-"\$TARGET"
   cd \$HOME/build-"\$TARGET"
   cp \$HOME/toolchains/"\$TARGET"/"\$VERSION".config .config
   ct-ng build
@@ -51,5 +51,5 @@ build_archive() {
 echo "building toolchain for \$TARGET"

 build_toolchain
-build_zlib
-build_archive
\ No newline at end of file
+#build_zlib
+#build_archive
diff --git a/kotlin-native/tools/toolchain_builder/toolchains/x86_64-unknown-linux-gnu/gcc-8.3.0-glibc-2.19-kernel-4.9.config b/kotlin-native/tools/toolchain_builder/toolchains/x86_64-unknown-linux-gnu/gcc-8.3.0-glibc-2.19-kernel-4.9.config
index b7c25cd02..de1179de1 100644
--- a/kotlin-native/tools/toolchain_builder/toolchains/x86_64-unknown-linux-gnu/gcc-8.3.0-glibc-2.19-kernel-4.9.config
+++ b/kotlin-native/tools/toolchain_builder/toolchains/x86_64-unknown-linux-gnu/gcc-8.3.0-glibc-2.19-kernel-4.9.config
@@ -107,6 +107,7 @@ CT_CONFIG_SHELL="\''${bash}"
 # CT_LOG_WARN is not set
 # CT_LOG_INFO is not set
 CT_LOG_EXTRA=y
+CT_LOG_ALL=y
 # CT_LOG_ALL is not set
 # CT_LOG_DEBUG is not set
 CT_LOG_LEVEL_MAX="EXTRA"
@@ -606,7 +607,7 @@ CT_ISL_V_0_20=y
 # CT_ISL_V_0_15 is not set
 # CT_ISL_NO_VERSIONS is not set
 CT_ISL_VERSION="0.20"
-CT_ISL_MIRRORS="http://isl.gforge.inria.fr"
+CT_ISL_MIRRORS="https://sources.easybuild.io/i/ISL"
 CT_ISL_ARCHIVE_FILENAME="@{pkg_name}-@{version}"
 CT_ISL_ARCHIVE_DIRNAME="@{pkg_name}-@{version}"
 CT_ISL_ARCHIVE_FORMATS=".tar.xz .tar.bz2 .tar.gz"
@@ -741,3 +742,24 @@ CT_ZLIB=y
 # CT_COMP_TOOLS_M4 is not set
 # CT_COMP_TOOLS_MAKE is not set
 CT_ALL_COMP_TOOLS_CHOICES="AUTOCONF AUTOMAKE BISON DTC LIBTOOL M4 MAKE"
+
+# Nix
+
+CT_PATCH_USE_LOCAL=true
+CT_LOCAL_PATCH_DIR="$PATCH_DIR"
+
+CT_COMP_TOOLS_MAKE=y
+CT_COMP_TOOLS_MAKE_PKG_KSYM="MAKE"
+CT_MAKE_DIR_NAME="make"
+CT_MAKE_PKG_NAME="make"
+CT_MAKE_SRC_RELEASE=y
+# CT_MAKE_SRC_DEVEL is not set
+CT_MAKE_PATCH_ORDER="global"
+CT_MAKE_V_4_3=y
+# CT_MAKE_V_4_2 is not set
+CT_MAKE_VERSION="4.3"
+CT_MAKE_MIRRORS="\$(CT_Mirrors GNU make)"
+CT_MAKE_ARCHIVE_FILENAME="@{pkg_name}-@{version}"
+CT_MAKE_ARCHIVE_DIRNAME="@{pkg_name}-@{version}"
+CT_MAKE_ARCHIVE_FORMATS=".tar.lz .tar.gz"
+CT_MAKE_SIGNATURE_FORMAT="packed/.sig"
EOM

    mkdir -p $PATCH_DIR/gcc/8.3.0
    mkdir -p $PATCH_DIR/binutils/2.32

cat >$PATCH_DIR/binutils/2.32/include_string.patch <<EOL
diff --git a/gold/errors.h b/gold/errors.h
index c26b558..ac681e9 100644
--- a/gold/errors.h
+++ b/gold/errors.h
@@ -24,6 +24,7 @@
 #define GOLD_ERRORS_H

 #include <cstdarg>
+#include <string>

 #include "gold-threads.h"

EOM

cat >$PATCH_DIR/gcc/8.3.0/fix_wformat_security.patch <<EOL
diff --git a/libcpp/expr.c b/libcpp/expr.c
index 36c3fc4..4766a14 100644
--- a/libcpp/expr.c
+++ b/libcpp/expr.c
@@ -794,10 +794,10 @@ cpp_classify_number (cpp_reader *pfile, const cpp_token *token,

 	  if (CPP_OPTION (pfile, c99))
             cpp_warning_with_line (pfile, CPP_W_LONG_LONG, virtual_location,
-				   0, message);
+				   0, "%s", message);
           else
             cpp_pedwarning_with_line (pfile, CPP_W_LONG_LONG,
-				      virtual_location, 0, message);
+				      virtual_location, 0, "%s", message);
         }

       result |= CPP_N_INTEGER;
diff --git a/libcpp/macro.c b/libcpp/macro.c
index 776af7b..580d3a9 100644
--- a/libcpp/macro.c
+++ b/libcpp/macro.c
@@ -160,7 +160,7 @@ class vaopt_state {
 	if (m_state == 2 && token->type == CPP_PASTE)
 	  {
 	    cpp_error_at (m_pfile, CPP_DL_ERROR, token->src_loc,
-			  vaopt_paste_error);
+			  "%s", vaopt_paste_error);
 	    return ERROR;
 	  }
 	/* Advance states before further considering this token, in
@@ -189,7 +189,7 @@ class vaopt_state {
 		if (was_paste)
 		  {
 		    cpp_error_at (m_pfile, CPP_DL_ERROR, token->src_loc,
-				  vaopt_paste_error);
+				  "%s", vaopt_paste_error);
 		    return ERROR;
 		  }

@@ -3361,7 +3361,7 @@ create_iso_definition (cpp_reader *pfile, cpp_macro *macro)
 	     function-like macros, but not at the end.  */
 	  if (following_paste_op)
 	    {
-	      cpp_error (pfile, CPP_DL_ERROR, paste_op_error_msg);
+	      cpp_error (pfile, CPP_DL_ERROR, "%s", paste_op_error_msg);
 	      return false;
 	    }
 	  break;
@@ -3374,7 +3374,7 @@ create_iso_definition (cpp_reader *pfile, cpp_macro *macro)
 	     function-like macros, but not at the beginning.  */
 	  if (macro->count == 1)
 	    {
-	      cpp_error (pfile, CPP_DL_ERROR, paste_op_error_msg);
+	      cpp_error (pfile, CPP_DL_ERROR, "%s", paste_op_error_msg);
 	      return false;
 	    }

EOL
    fhs
    AR=$(which ar)
    unset CC CXX LD_LIBRARY_PATH

    mkdir bin
    WGET=$(which wget)
    export PATH="$(pwd)/bin:$PATH"
    cat >bin/wget <<EOL
#!$(which bash)
url=\''${9/http:\/\//https:\/\/}
$WGET \$1 \$2 \$3 \$4 \$5 \$6 \$7 \$8 \$url
EOL
    chmod +x bin/wget

    cd kotlin-native/tools/toolchain_builder
    bash ./build_toolchain.sh x86_64-unknown-linux-gnu gcc-8.3.0-glibc-2.19-kernel-4.9 "" || echo "FAILURE"

    cat ./build-x86_64-unknown-linux-gnu/build.log
    exit 1
  '';

  installPhase = ''
    runHook preInstall

    #for s in $srcs
    #do
      #name=$(basename $s)
      #dest_file=$(echo "$name" | cut -c 34-)
      #mkdir -p $out/$dest_file
      #cp -R $s/* $out/$dest_file
    #done

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/JetBrains/kotlin/tree/master/kotlin-native/tools/toolchain_builder";
    description = "GCC toolchain used by Kotlin/Native";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "sha256-4SePc3yGlBTGCoCeZtVL9A1NK5vv2CM8EnoRCinhPA0=";
}
