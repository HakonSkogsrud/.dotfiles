# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Oslo";
  console.keyMap = "no";

  users.users.haaksk = {
    isNormalUser = true;
    extraGroups = [ "wheel" ] ;
    initialPassword = "1234";
    shell = pkgs.zsh;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    config = {
      user.name = "Håkon Skogsrud";
      user.email = "haakon.skogsrud@pm.me";
    };
  };

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    '';
  };

  environment.sessionVariables = {
    EDITOR = "nvim";
  };

  security.sudo.wheelNeedsPassword = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

   environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    fzf
    fd
    bat
    ripgrep
    zoxide
    eza
    zsh-autosuggestions
    exiftool
    uv
    lazygit
    delta
    neovim
    gh
    stow
    gcc
    python3
    nixd
    nixfmt
    nix-direnv
    codex
    nodejs
    tmux
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  nix.settings.auto-optimise-store = true;

  system.stateVersion = "26.05"; # Did you read the comment?

}

