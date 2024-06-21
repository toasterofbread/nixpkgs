{ lib
, stdenv
, fetchFromGitHub
, cmake
, asciidoc
, pkg-config
, libsodium
, kotlin-native-toolchain-x86
, enableDrafts ? false
}:

stdenv.mkDerivation rec {
  pname = "zeromq-kotlin-native";
  version = "4.3.5";

  src = fetchFromGitHub {
    owner = "zeromq";
    repo = "libzmq";
    rev = "v${version}";
    sha256 = "sha256-q2h5y0Asad+fGB9haO4Vg7a1ffO2JSb7czzlhmT3VmI=";
  };

  nativeBuildInputs = [ cmake asciidoc pkg-config kotlin-native-toolchain-x86 ];
  buildInputs = [ libsodium ];

  doCheck = false; # fails all the tests (ctest)

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '$'{prefix}/'$'{CMAKE_INSTALL_LIBDIR} '$'{CMAKE_INSTALL_FULL_LIBDIR} \
      --replace '$'{prefix}/'$'{CMAKE_INSTALL_INCLUDEDIR} '$'{CMAKE_INSTALL_FULL_INCLUDEDIR}
  '';

  configurePhase = ''
    export TOOLCHAIN=${kotlin-native-toolchain-x86}/x86_64-unknown-linux-gnu-gcc-8.3.0-glibc-2.19-kernel-4.9-2
    export CC=$TOOLCHAIN/bin/x86_64-unknown-linux-gnu-gcc
    export CXX=$TOOLCHAIN/bin/x86_64-unknown-linux-gnu-g++
    export CMAKE_INSTALL_PREFIX=$out
    mkdir build
    cd build

    if [ "${lib.boolToString enableDrafts}" = true ]; then
      cmake .. -DENABLE_DRAFTS=ON
    else
      cmake .. -DENABLE_DRAFTS=OFF
    fi
  '';

  meta = with lib; {
    branch = "4";
    homepage = "http://www.zeromq.org";
    description = "Intelligent Transport Layer";
    license = licenses.mpl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ fpletz ];
  };
}
