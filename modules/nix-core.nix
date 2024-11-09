{ pkgs, lib, ... }:

  # *--- core del funzionamento di nix (gestione dei pacchetti e dello store) ---*

{
  # abilitazione globale dei flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # abilitazione dei pacchetti non open source
  nixpkgs.config.allowUnfree = true;

  # auto upgrade dei pacchetti e del demone
  services.nix-daemon.enable = true;
  # quest'altra configurazione è più generica e non sfrutta gli automatismi di darwin
  # nix.useDaemon = true;

  nix.package = pkgs.nix;

  # garbage collection di generations più vecchie di una settimana (ottimizza l'utilizzo del disco)
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # disabilitazione di auto-optimise-store (de-duplica files nello store) a causa di un bug:
  #   https://github.com/NixOS/nix/issues/7273
  # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
  nix.settings = {
    auto-optimise-store = false;
  };
}