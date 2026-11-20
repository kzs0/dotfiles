{
  description = "kzs0 dotfiles — Linux packages via Home Manager (macOS uses the Brewfile)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Username/home come from the environment, so build with --impure
      # (the justfile does this). One flake works for every user/machine.
      user = let u = builtins.getEnv "USER"; in if u == "" then throw "USER is not set; build with --impure (just nix does this)" else u;
      home = let h = builtins.getEnv "HOME"; in if h == "" then "/home/${user}" else h;

      mkHome = system: gui:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
          modules = [
            ({ pkgs, ... }: {
              home.username = user;
              home.homeDirectory = home;
              home.stateVersion = "25.05";
              home.packages = import ./nix/packages.nix { inherit pkgs gui; };
              fonts.fontconfig.enable = true;
              # Configs are plain files symlinked by scripts/link.sh, not by Home
              # Manager, so they behave identically on macOS and Linux.
              programs.home-manager.enable = true;
              # XDG/fontconfig glue for non-NixOS distros (Ubuntu); off on NixOS
              targets.genericLinux.enable = !(builtins.pathExists /etc/NIXOS);
            })
          ];
        };
    in {
      homeConfigurations = {
        # headless / servers / Ubuntu (GUI apps from apt or upstream .deb)
        "cli-x86_64-linux" = mkHome "x86_64-linux" false;
        "cli-aarch64-linux" = mkHome "aarch64-linux" false;
        # NixOS desktops: also installs ghostty + zed from nixpkgs
        "desktop-x86_64-linux" = mkHome "x86_64-linux" true;
        "desktop-aarch64-linux" = mkHome "aarch64-linux" true;
      };
    };
}
