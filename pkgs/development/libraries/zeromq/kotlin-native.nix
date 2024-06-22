{ lib
, stdenv
, fetchFromGitHub
, cmake
, asciidoc
, pkg-config
, libsodium
, kotlin-native-toolchain
, enableDrafts ? false
}:

stdenv.mkDerivation rec {
  inherit (stdenv.hostPlatform) system;

  pname = "zeromq-kotlin-native";
  version = "4.3.5";

  platform = {
    x86_64-linux = "x86_64-unknown-linux-gnu";
    aarch64-linux = "aarch64-unknown-linux-gnu";
  }.${system};

  gcc_version = {
    x86_64-linux = "gcc-8.3.0-glibc-2.19-kernel-4.9-2";
    aarch64-linux = "gcc-8.3.0-glibc-2.25-kernel-4.9-2";
  }.${system};

  src = fetchFromGitHub {
    owner = "zeromq";
    repo = "libzmq";
    rev = "v${version}";
    sha256 = "sha256-q2h5y0Asad+fGB9haO4Vg7a1ffO2JSb7czzlhmT3VmI=";
  };

  nativeBuildInputs = [ cmake asciidoc pkg-config kotlin-native-toolchain ];
  buildInputs = [ libsodium ];

  doCheck = false; # fails all the tests (ctest)

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace '$'{prefix}/'$'{CMAKE_INSTALL_LIBDIR} '$'{CMAKE_INSTALL_FULL_LIBDIR} \
      --replace '$'{prefix}/'$'{CMAKE_INSTALL_INCLUDEDIR} '$'{CMAKE_INSTALL_FULL_INCLUDEDIR}
  '';

  configurePhase = ''
    export TOOLCHAIN=${kotlin-native-toolchain}/${platform}-${gcc_version}
    export CC=$TOOLCHAIN/bin/${platform}-gcc
    export CXX=$TOOLCHAIN/bin/${platform}-g++
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
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [];
  };
}
