{ pkgs, inputs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  # environment.pathsToLink = [ "/share/fish" ];

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using zsh as our shell
  programs.fish.enable = true;
  programs.zsh.enable = true;

  users.users.rs = {
    isNormalUser = true;
    home = "/home/rs";
    extraGroups = [ "wheel" "docker" "dialout" "networkmanager" "cdrom" ]; # Enable ‘sudo’ for the user, docker, dialout for arduino
    shell = pkgs.zsh;
    initialPassword = "rs";
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    # (import ./vim.nix { inherit inputs; })
  ];
}

