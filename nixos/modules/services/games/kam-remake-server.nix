{ config, lib, pkgs, ... }:

with lib;

let
  cfg        = config.services.kam-remake-server;
  configFile = pkgs.writeText "KaM_Remake_Server_Settings.ini" ''
    [Server]
    ServerName=${cfg.name}
    WelcomeMessage=${cfg.welcomeMessage}
    ServerPort=${cfg.port}
    AnnounceDedicatedServer=1
    MaxRooms=${cfg.maxRooms}
    HTMLStatusFile=/tmp/kam-remake-status.html
    MasterServerAnnounceInterval=180
    MasterServerAddressNew=http://kam.hodgman.id.au/
    AutoKickTimeout=20
    PingMeasurementInterval=1000
  '';
in
{
  options = {
    services.kam-remake-server = {
      enable = mkOption {
        type        = types.bool;
        default     = false;
        description = "If enabled, starts a KaM Remake Server.";
      };

      name = mkOption {
        type        = types.string;
        default     = "KaM Server";
        description = ''
          Name visible in server list
        '';
      };
      welcomeMessage = mkOption {
        type        = types.string;
        default     = "";
        description = ''
          Welcome message
        '';
      };
      port = mkOption {
        type        = types.nullOr types.int;
        default     = 56789;
        description = ''
          Port number to bind to.

          If set to null, the default 56789 will be used.
        '';
      };
      maxRooms = mkOption {
        type        = types.nullOr types.int;
        default     = 16;
        description = ''
          Maximum number of rooms that the server can host.

          If set to null, the default 16 will be used.
        '';
      
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.kam-remake-server = {
      description     = "KaM Remake Server Service user";
      home            = "/var/lib/kam-remake-server";
      createHome      = true;
      uid             = config.ids.uids.kam-remake-server;
      group           = "kam-remake-server";
    };

    environment.systemPackages = [ pkgs.kam-remake-server ];

    networking.firewall.allowedTCPPorts = [ config.services.kam-remake-server.port ];

    users.groups.kam-remake-server.gid = config.ids.gids.kam-remake-server;

    systemd.services.kam-remake-server = {
      description   = "KaM Remake Server Service";
      wantedBy      = [ "multi-user.target" ];
      after         = [ "network.target" ];

      serviceConfig = {
        Restart   = "always";
        User      = "kam-remake-server";
        Group     = "kam-remake-server";
        ExecStart = "${pkgs.kam-remake-server}/bin/kam-server";
      };

      preStart = ''
        ln -sf ${configFile} /tmp/kam-settings.ini
      '';

    };
  };
}
