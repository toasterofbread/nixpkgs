{ lib
, stdenv
, fetchFromGitHub
, emptyDirectory
, writeText
, makeBinaryWrapper
, gradle
, jdk22
, llvmPackages
}:

let
  gradleInit = writeText "init.gradle" ''
    logger.lifecycle 'Replacing Maven repositories with empty directory...'
    gradle.projectsLoaded {
      rootProject.allprojects {
        buildscript {
          repositories {
            clear()
            maven { url '${emptyDirectory}' }
          }
        }
        repositories {
          clear()
          maven { url '${emptyDirectory}' }
        }
      }
    }
    settingsEvaluated { settings ->
      settings.pluginManagement {
        repositories {
          maven { url '${emptyDirectory}' }
        }
      }
    }
  '';
in

stdenv.mkDerivation {
  pname = "jextract";
  version = "unstable-2024-05-28";

  src = fetchFromGitHub {
    owner = "openjdk";
    repo = "jextract";
    rev = "926070f9eea83a0cee916240052bf04d5f2312a6";
    hash = "sha256-XZq7zbEuDVsuf1GVSxfmRPJNjJwhM0tMQg2g8IBGQyE=";
  };

  nativeBuildInputs = [
    gradle
    makeBinaryWrapper
  ];

  env = {
    ORG_GRADLE_PROJECT_llvm_home = llvmPackages.libclang.lib;
    ORG_GRADLE_PROJECT_jdk22_home = jdk22;
  };

  buildPhase = ''
    runHook preBuild

    export GRADLE_USER_HOME=$(mktemp -d)
    gradle --console plain --init-script "${gradleInit}" assemble

    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    gradle --console plain --init-script "${gradleInit}" verify
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/
    cp -r ./build/jextract $out/opt/jextract
    makeBinaryWrapper "$out/opt/jextract/bin/jextract" "$out/bin/jextract"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Tool which mechanically generates Java bindings from a native library headers";
    mainProgram = "jextract";
    homepage = "https://github.com/openjdk/jextract";
    platforms = jdk22.meta.platforms;
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ jlesquembre sharzy ];
  };
}
