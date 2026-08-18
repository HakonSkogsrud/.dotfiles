{ config, pkgs, ... }:

{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ./hardware-configuration.nix
    ./cosmic.nix
  ];

  # ============================================================================
  # BOOT & SYSTEM CORE
  # ============================================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest; # Stock NixOS kernel
  #boot.kernelPackages = pkgs.linuxPackages_zen;

  # ============================================================================
  # NETWORKING & HOSTNAME
  # ============================================================================

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ============================================================================
  # LOCALE & TIMEZONE
  # ============================================================================

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nb_NO.UTF-8";
    LC_IDENTIFICATION = "nb_NO.UTF-8";
    LC_MEASUREMENT = "nb_NO.UTF-8";
    LC_MONETARY = "nb_NO.UTF-8";
    LC_NAME = "nb_NO.UTF-8";
    LC_NUMERIC = "nb_NO.UTF-8";
    LC_PAPER = "nb_NO.UTF-8";
    LC_TELEPHONE = "nb_NO.UTF-8";
    LC_TIME = "nb_NO.UTF-8";
  };

  # ============================================================================
  # DISPLAY & DESKTOP ENVIRONMENT (X11 + GNOME)
  # ============================================================================

  # Keyboard configuration
  services.xserver.xkb = {
    layout = "no";
    variant = "nodeadkeys";
  };
  console.keyMap = "no";

  # ============================================================================
  # AUDIO & SOUND (PipeWire)
  # ============================================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ============================================================================
  # ENVIRONMENT & SESSION VARIABLES
  # ============================================================================

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD";
    ZED_RENDERER = "gles"; # Force OpenGL ES to fix Zed editor Intel GPU lag/freezes
  };

  # ============================================================================
  # USERS
  # ============================================================================

  users.users.haaksk = {
    isNormalUser = true;
    description = "Håkon Skogsrud";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # ============================================================================
  # FONTS
  # ============================================================================

  fonts.packages = with pkgs; [
    nerd-fonts.comic-shanns-mono
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.commit-mono
  ];

  # ============================================================================
  # PROGRAMS & APPLICATIONS
  # ============================================================================

  # Firefox with declarative enterprise policies
  programs.firefox = {
    enable = true;

    policies = {
      Preferences = {
        "media.ffmpeg.vaapi.enabled" = {
          Value = true;
          Status = "user";
        };
        "widget.wayland-dmabuf-vaapi.enabled" = {
          Value = true;
          Status = "user";
        };
      };

      # Automatically install extensions
      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };

    };
  };

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    config = {
      user.name = "Håkon Skogsrud";
      user.email = "haakon.skogsrud@pm.me";
    };
  };

  # ============================================================================
  # PACKAGE MANAGEMENT
  # ============================================================================

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    # Add any other common libs if needed, but the defaults usually cover node/python agents
  ];

  programs.nh = {
    enable = true;
    flake = "/home/haaksk/.dotfiles/nixos";
  };

  services.flatpak = {
    enable = true;
    packages = [
      "org.onlyoffice.desktopeditors"
      "md.obsidian.Obsidian"
    ];
  };

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================

  environment.systemPackages = with pkgs; [
    # Development Tools and Editors
    localsend
    lazygit
    neovim
    gh
    stow
    gcc
    python3
    lua-language-server
    nixd
    nixfmt
    nix-direnv

    # Terminal and Shell Utilities
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

    adw-gtk3
    # Applications and Utilities
    loupe
    darktable
    syncthing
    (vscodium.override {
      commandLineArgs = "--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3";
    })
    emacs-pgtk
    brave
    tailscale

    # Other Tools
    nodejs
  ];

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================

  services.tailscale.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [
      config.services.tailscale.port
      53317
    ];
    checkReversePath = "loose";
  };

  # ============================================================================
  # INPUT DEVICES
  # ============================================================================

  # Scale down mouse speed at driver level (before GNOME settings)
  # Higher DPI value = libinput scales movement DOWN
  services.udev.extraHwdb = ''
    mouse:bluetooth:v1915p0040:name:*:
     MOUSE_DPI=2000@1000

    mouse:bluetooth:v046Dp0B020:name:*:
     MOUSE_DPI=1800@1000
  '';

  # ============================================================================
  # HARDWARE
  # ============================================================================

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # ============================================================================
  # SERVICES
  # ============================================================================

  services.power-profiles-daemon.enable = true;

  services.syncthing = {
    enable = true;

    user = "haaksk";

    # The default directory where new synced folders will be created
    dataDir = "/home/haaksk";

    # Where Syncthing will store its settings, certificates, and database
    configDir = "/home/haaksk/.config/syncthing";

    # Automatically open ports (22000/TCP, 22000/UDP, 21027/UDP) in the firewall
    openDefaultPorts = true;

    # Declarative enforcement: Force NixOS settings to override GUI manual changes
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      # 1. Register the remote server device
      devices = {
        "services" = {
          id = "M7IMWFU-66PMZO3-WVVK2S7-NJDOZT3-XUIMWGU-3QMAX3B-5PMYWR5-LDA4MQV";
          # Since 10.0.0.44 is a local/Tailscale IP, specifying it directly
          # allows instant connection without relying on global discovery relays.
          addresses = [ "tcp://10.0.0.44:22000" ];
        };
      };

      # 2. Map the shared folder to your local Documents directory
      folders = {
        "Documents" = {
          id = "ulv9z-dbglm"; # Must match the server's folder ID exactly
          label = "Sync"; # Keeps the user-friendly label "Sync" in your GUI
          path = "/home/haaksk/Documents"; # The local target directory on your laptop
          devices = [ "services" ]; # Tell Syncthing to sync this folder with the server
        };
        "2026" = {
          id = "c2xpa-nhtgu"; # Must match the server's folder ID exactly
          label = "2026"; # Keeps the user-friendly label "Sync" in your GUI
          path = "/home/haaksk/Pictures/2026"; # The local target directory on your laptop
          devices = [ "services" ]; # Tell Syncthing to sync this folder with the server
        };
      };
    };
  };

  # Enable systemd-resolved to fix Tailscale suspend/reboot DNS hangs
  services.resolved = {
    enable = true;
    # Ensures a global fallback is used if Tailscale's DNS drops
    settings.Resolve.Domains = [ "~." ];
  };

  services.fwupd.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ============================================================================
  # NIX PACKAGE MANAGER
  # ============================================================================

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  nix.settings.auto-optimise-store = true;

  # ============================================================================
  # SYSTEM UPDATES & STATE
  # ============================================================================

  # Disabled auto-upgrade to avoid frequent kernel recompilations
  # Run 'sudo nixos-rebuild switch' manually when you want to apply updates
  system.autoUpgrade = {
    enable = false;
    dates = "04:00";
    channel = "https://nixos.org/channels/nixos-unstable";
    allowReboot = false;
    persistent = true;
    randomizedDelaySec = "30min";
  };

  # DO NOT change this value. It does NOT track your current NixOS version.
  # It records which version you originally installed on (for backwards compatibility).
  system.stateVersion = "25.11";
}
