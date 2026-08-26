{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware-configuration.nix
    ./gnome.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    enable = true;
    xkb.layout = "no";
    xkb.variant = "nodeadkeys";
  };
  console.keyMap = "no";

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.users.haaksk = {
    isNormalUser = true;
    description = "Håkon Skogsrud";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.comic-shanns-mono
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.commit-mono
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    curl
    lazygit
    delta
    neovim
    gh
    stow
    gcc
    python3
    lua-language-server
    nixd
    nixfmt
    nix-direnv
    wget
    fzf
    fd
    bat
    ripgrep
    zoxide
    eza
    zsh-autosuggestions
    uv
    loupe
    (vscodium.override {
      commandLineArgs = "--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3";
    })
    emacs-pgtk
    nodejs
  ];

  services.openssh.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      3389
    ];
    allowedUDPPorts = [ 3389 ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  nix.settings.auto-optimise-store = true;

  system.stateVersion = "25.11";
}
