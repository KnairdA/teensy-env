{ pkgs, ... }:

let
  spi = pkgs.fetchFromGitHub {
    owner = "PaulStoffregen";
    repo = "SPI";
    rev = "574ab8c7a8a45ea21cc56dcc6b7361da90868e86";
    sha256 = "I3M7w9SNEXvPD0ynuZ38bnTaenGEORg72E5YC2x6ek4=";
  };

  wire = pkgs.fetchFromGitHub {
    owner = "PaulStoffregen";
    repo = "Wire";
    rev = "15018075857fa0176d8a5fc610fc564427282ca0";
    sha256 = "GTfqmQykFS4nXXPBhQHe2gpEUY2sH0ESHh28ZrIW/dE=";
  };

in pkgs.stdenvNoCC.mkDerivation rec {
  name = "teensy-core";
  version = "1.54";

  src = pkgs.fetchFromGitHub {
    owner = "PaulStoffregen";
    repo = "cores";
    rev = "${version}";
    sha256 = "6IXKPVc06WCjJDOnDFOOqjPZSt4UhRW7LHyblEaZ7fw=";
  };

  buildInputs = with pkgs; [
    binutils
    gcc-arm-embedded
  ];

  buildPhase = ''
    export CC=arm-none-eabi-gcc
    export CXX=arm-none-eabi-g++

    pushd teensy4
    rm main.cpp
    cp ${./Makefile.lib} Makefile
    substitute ${./flags.mk} flags.mk \
               --subst-var-by TEENSY_INCLUDE . \
               --subst-var-by TEENSY_LIB .
    cp ${./flags.mk} flags.mk

    cp ${spi}/*.{cpp,h} .
    cp ${wire}/*.{cpp,h} .

    make
    ar rvs libteensy-core.a *.o

    popd
  '';

  installPhase = ''
    mkdir -p $out/{include,lib}
    pushd teensy4
    cp -r *.h $out/include/
    cp -r avr $out/include/
    cp -r debug $out/include/
    cp -r util $out/include/
    cp libteensy-core.a $out/lib/
    substitute ${./flags.mk} $out/include/flags.mk \
               --subst-var-by TEENSY_INCLUDE $out/include \
               --subst-var-by TEENSY_LIB $out/lib
    cp imxrt1062.ld $out/include/IMXRT1062.ld
    popd
  '';
}
