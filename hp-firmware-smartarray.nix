{pkgs, lib, ...}: 

  pkgs.stdenv.mkDerivation rec {
    pname = "hp-firmware-smartarray";
    version = "46a4d957a7-8.32-1.1";

    src = pkgs.fetchurl {
      urls = [
        "https://downloads.hpe.com/pub/softlib2/software1/sc-linux-fw-array/p2102220776/v140762/rpm/RPMS/x86_64/${pname}-${version}.x86_64.rpm"
      ];
      # hash = lib.fakeHash;
      hash = "sha256-z5vPrLX9q5zMV3xWEqMc4k+Yy5bEIYVxfHLtxQB3y6Q=";
    };

    nativeBuildInputs = [ pkgs.rpmextract ];
    unpackPhase = "rpmextract $src";
    installPhase = ''
      mkdir -p $out/lib $out/bin ## $out/share/firmware
      mv usr/lib/x86_64-linux-gnu/${pname}-${version}/{hpsetup,.hpsetup} $out/bin
      mv usr/lib/x86_64-linux-gnu/${pname}-${version}/libhpsetup.so $out/lib
      # mv usr/lib/x86_64-linux-gnu/${pname}-${version}/*.{fw,xml}  $out/share/firmware ## Needed in same bin dir ?
      mv usr/lib/x86_64-linux-gnu/${pname}-${version}/*.{fw,xml}  $out/bin/

      for file in .hpsetup; do
        chmod +w $out/bin/$file
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                 --set-rpath "${lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}:../lib" \
                 $out/bin/$file
      done
    '';
    postFixup = ''
      substituteInPlace $out/bin/hpsetup \
        --replace-warn "/var/" "/tmp/" \
	--replace-warn "/bin/mkdir" "mkdir" \
	--replace-warn "./.hpsetup" "./.hpsetup --log-dir /tmp/cpq"
    '';

    dontStrip = true;

    meta = with lib; {
      description = "HP Smart Array Firmware updater";
      homepage = "https://downloads.hpe.com/pub/softlib2/software1/sc-linux-fw-array/p2102220776/v140762";
      license = licenses.unfreeRedistributable;
      platforms = [ "x86_64-linux" ];
      maintainers = [ ];
    };
  }