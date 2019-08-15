{ stdenv, fetchzip, autoPatchelfHook }:
stdenv.mkDerivation rec {
  name = "kam-remake-server-${version}";
  version = "r6720";

  src = fetchzip {
    url       = "https://lewin.hodgman.id.au/kam/downloads/kam_remake_server_${version}.zip";
    stripRoot = false;
    sha256    = "1r222sn3aqznw4apmj8a1vzkrcplyabfqmw1fd88bz3cw89s9r6p";
  };

  dontStrip = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -v $src/KaM_Remake_Server_x86_64 $out/bin/kam-server
    chmod +x $out/bin/kam-server
    mkdir -p /tmp/kam-remake-server
    cd $out/bin/
    ln -s /tmp/kam-remake-server Logs
    ln -s /tmp/kam-settings.ini KaM_Remake_Settings.ini
    ln -s /dev/null KaM_Remake_Server_Status.html
  '';

  nativeBuildInputs = [ autoPatchelfHook ];

  meta = {
    description = "KaM Remake Server";
    homepage    = "https://kamremake.com";
    license     = stdenv.lib.licenses.unfreeRedistributable;
    platforms   = [ "x86_64-linux" ];
  };
}
