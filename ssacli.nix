{pkgs, lib, ...}: 

  pkgs.stdenv.mkDerivation rec {
    pname = "ssacli";
    version = "6.40-6.0";

    src = pkgs.fetchurl {
      urls = [
        "https://downloads.linux.hpe.com/SDR/downloads/MCP/Ubuntu/pool/non-free/${pname}-${version}_amd64.deb"
        "http://apt.netangels.net/pool/main/h/hpssacli/${pname}-${version}_amd64.deb"
      ];
      hash = "sha256-17eraLtcaCESr35yhwFkoxj+3IgDtxEk8mYRredP60w=";
    };

    nativeBuildInputs = [ pkgs.dpkg ];

    unpackPhase = "dpkg -x $src ./";

    installPhase = ''
      mkdir -p $out/bin $out/share/doc $out/share/man
      mv opt/smartstorageadmin/ssacli/bin/{ssascripting,rmstr,ssacli} $out/bin/
      mv opt/smartstorageadmin/ssacli/bin/*.{license,txt}                   $out/share/doc/
      mv usr/man                                               $out/share/

      for file in $out/bin/*; do
        chmod +w $file
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                 --set-rpath ${lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]} \
                 $file
      done
    '';

    dontStrip = true;

    meta = with lib; {
      description = "HP Smart Array CLI";
      homepage = "https://downloads.linux.hpe.com/SDR/downloads/MCP/Ubuntu/pool/non-free/";
      license = licenses.unfreeRedistributable;
      platforms = [ "x86_64-linux" ];
      maintainers = [ ];
    };
  }