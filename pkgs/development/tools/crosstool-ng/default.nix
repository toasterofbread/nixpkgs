{ lib
, stdenv
, fetchFromGitHub 
, git
, autoconf
, automake
, flex
, texinfo
, unzip
, help2man
, which
, libtool
, ncurses
, bison
}:

stdenv.mkDerivation rec {
  pname = "crosstool-ng";
  version = "b2151f1";

  src = fetchFromGitHub {
    owner  = "crosstool-ng";
    repo   = "crosstool-ng";
    rev    = version;
    sha256 = "sha256-FAQckjt5j+2o05gKWvuCuvsSD5Cf6VSLhgmZ4Ok64hI=";
  };

  nativeBuildInputs = [
    git
    autoconf
    automake
    flex
    texinfo
    unzip
    help2man
    which
    libtool
    ncurses
    bison
  ];

  buildPhase = ''
    ls

git apply << EOM
From 8ad4a8b83f3de8b7b283a845c5744147ba819c9d Mon Sep 17 00:00:00 2001
From: Chris Packham <judge.packham@gmail.com>
Date: Sat, 14 Sep 2019 22:17:28 +1200
Subject: [PATCH] build/internals.sh: Handle pie executables

Fixes: #887

On some systems the file command identifies a pie executable as a shared
object. Update do_finish() to handle this case so that they are stripped
as well.

Signed-off-by: Chris Packham <judge.packham@gmail.com>
---
scripts/build/internals.sh | 2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/build/internals.sh b/scripts/build/internals.sh
index 5d359979..821761c2 100644
--- a/scripts/build/internals.sh
+++ b/scripts/build/internals.sh
@@ -83,7 +83,7 @@ do_finish() {
                 case "\''${_type}" in
                     *script*executable*)
                         ;;
-                    *executable*)
+                    *executable*|*shared*object*)
                         CT_DoExecLog ALL \''${CT_HOST}-strip \''${strip_args} "\''${_t}"
                         ;;
                 esac
-- 
2.25.1
EOM

  bash ./bootstrap
  ./configure --prefix=$out
  make
  '';

  installPhase = ''
    make install
  '';

  meta = with lib; {
    description = "A versatile (cross-)toolchain generator";
    mainProgram = "ct-ng";
    homepage    = "https://github.com/crosstool-ng/crosstool-ng";
    #license     = licenses.asl20;
    maintainers = with maintainers; [];
    platforms   = platforms.linux;
  };
}
