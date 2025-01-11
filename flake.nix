{
  description = "Flake solo mac: modularizzate le configurazioni del sistema e dei pacchetti - 1.0";
  /*
    roadmap:
    - 1.1: commentare e comprendere tutto quanto ***
      - 1.2: fare upgrade e downgrade dei pacchetti ***
      - 1.3: usare i dotfiles per personalizzare i pacchetti (plug in vs code, zsh, ecc.)
      - 1.4: usare i dotfiles per personalizzare mac os
    - 2.0: uso avanzato di nix (overlays, installare pacchetti custom - es. karabiner per Monterey -)
    - 3.0: gestire diversi hosts e diversi OS
      - 3.1: gestire diversi utenti
    - 4.0: impermanence
    - 5.0: shell e devenv per diversi ambienti "effimeri" di sviluppo
      - 5.1: nix store e binary cache
  */

/*
  da capire! 

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    substituters = [
      # Query the mirror of USTC first, and then the official cache.
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };
*/

  inputs = {
    # unstable punta chiaramente a ultima release di nix
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";

    # su un esempio puntava a nixpkgs senza darwin (così pare vada bene... rimuovere se tutto ok)
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # home-manager installato come modulo e non stand-alone
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";

      # questo esempio omette proprio la versione: punterà di default unstable? (chiarire poi rimuovere)
      #url = "github:nix-community/home-manager";

      # la parola chiave `follows` negli inputs è usata per ereditarietà
      # qui `inputs.nixpkgs` di home-manager è consistente con `inputs.nixpkgs` del flake per evitare 
      # problemi con dipendenze di differenti versioni di nixpkgs
      inputs.nixpkgs.follows = "nixpkgs-darwin";

      # su un esempio puntava a nixpkgs senza darwin (idem come sopra... rimuovere se tutto ok)
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";

      # su un esempio puntava a nixpkgs senza darwin (idem come sopra... rimuovere se tutto ok)
      #inputs.nixpkgs.follows = "nixpkgs";
    };    
};
  outputs = inputs@{ self, nixpkgs, darwin, home-manager, ... }:
  let
    user = "Andrea Riva";
    username = "emoriver";
    useremail = "emoriver@live.it";
    system = "x86_64-darwin"; # aarch64-darwin or x86_64-darwin
    hostname = "macpremo";

    # raggruppa le variabile e le passa a home-manager
    specialArgs =
      inputs
      // {
        inherit user username useremail hostname;
      };
  in {
    darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true; # valutare se rimuovere una volta capito di più
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username} = import ./home;
        }
      ];
    };
  };
}