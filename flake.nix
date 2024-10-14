{
  description = "Flake solo mac: modularizzate le configurazioni del sistema e dei pacchetti - 1.0";

/*
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

/*
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
*/
    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      #url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs-darwin";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
      #inputs.nixpkgs.follows = "nixpkgs";
    };    
};
  outputs = inputs@{ self, nixpkgs, darwin, home-manager, ... }:
  let
    username = "emoriver";
    useremail = "emoriver@live.it";
    system = "x86_64-darwin"; # aarch64-darwin or x86_64-darwin
    hostname = "macpremo";

    specialArgs =
      inputs
      // {
        inherit username useremail hostname;
      };

/*      
    configuration = {pkgs, ... }: {

      services.nix-daemon.enable = true;
      # Necessary for using flakes on this system
      nix.settings.experimental-features = "nix-command flakes";

      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility. please read the changelog
      # before changing: `darwin-rebuild changelog`
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      # Declare the user that will be running `nix-darwin`
      users.users.emoriver = {
          name = "emoriver";
          home = "/Users/emoriver";
      };

      # Create /etc/zshrc that loads the nix-darwin environment
      programs.zsh.enable = true;

      environment.systemPackages = with pkgs;[ 
        neofetch
        git
        vscodium
        stats
        #karabiner-elements
        alacritty
      ];

      homebrew = {
        enable = true;
        onActivation.cleanup = "uninstall";

        taps = [ ];

        brews = [ 
          #"cowsay"
        ];

        casks = [
          "keepassxc"
          "tunnelblick"
          "logseq"
          "microsoft-edge"
          "royal-tsx"
          "foobar2000"
          "spotify"
        ];
      };
    };     
  in {
    darwinConfigurations."macpremo" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration

        # qui vanno messi i riferimenti ai moduli esterni sotto /modules (sistema??)
        # e quindi non in /home (utente??)

        home-manager.darwinModules.home-manager  {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.emoriver = import ./home;
        }         
      ];
    };
  };
*/

  in {
    darwinConfigurations."${hostname}" = darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        #./modules/apps.nix
        ./modules/host-users.nix

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username} = import ./home;
        }
      ];
    };

    # nix code formatter
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}