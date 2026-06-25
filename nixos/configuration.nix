# ============================================================================
# MANUAL WORK REQUIRED AFTER FRESH INSTALL
# ============================================================================
# 1. Run `nixos-generate-config` to generate hardware-configuration.nix
# 2. Update the Brave PWA .desktop ID in the GNOME favorite-apps list
#    (the ID is generated from the installed PWA and profile name)
# ============================================================================
# TO REVERT TO STOCK NIXOS KERNEL:
# ============================================================================
# Search for "CACHYOS" comments in this file and:
# 1. Delete/comment the let...in block near the top of this file
# 2. Uncomment boot.kernelPackages = pkgs.linuxPackages_latest
# 3. Delete/comment boot.kernelPackages = pkgs.cachyosKernels...
# 4. Delete/comment nixpkgs.overlays = [ cachyos-overlay... ]
# Then run: sudo nixos-rebuild switch && systemctl reboot
# ============================================================================
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

# ============================================================================
# CACHYOS KERNEL CONFIGURATION - START
# ============================================================================
# To revert to stock NixOS kernel:
# 1. Delete or comment out this entire let...in block
# 2. Search for "CACHYOS" comments in this file and revert those sections
# ============================================================================
let
  cachyos-kernel = builtins.fetchTarball {
    url = "https://github.com/xddxdd/nix-cachyos-kernel/archive/3ea1942599d8d0a124bdb9ec1304b3e6f63e8b1f.tar.gz";
    sha256 = "0824ax6fa28jqqaj9xkldly4afmkwn4j6njmasbj7bdvp6y9llsi";
  };
  cachyos-overlay = import "${cachyos-kernel}/default.nix";
in
# ============================================================================
# CACHYOS KERNEL CONFIGURATION - END
# ============================================================================

{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  # ============================================================================
  # BOOT & SYSTEM CORE
  # ============================================================================
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # ──────────────────────────────────────────────────────────────────────────
  # CACHYOS: Kernel selection
  # To revert to stock: uncomment next line, comment/delete the cachyos line
  # ──────────────────────────────────────────────────────────────────────────
  # boot.kernelPackages = pkgs.linuxPackages_latest;  # Stock NixOS kernel
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-x86_64-v4;  # CachyOS optimized

  # ==================================================  ==========================
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
  
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
  };

  # ============================================================================
  # USERS
  # ============================================================================
  
  users.users.haaksk = {
    isNormalUser = true;
    description = "Håkon Skogsrud";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  # ============================================================================
  # FONTS
  # ============================================================================
  
  fonts.packages = with pkgs; [
    ibm-plex
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    cantarell-fonts # Clean native GNOME UI font fallback
  ];

  # ============================================================================
  # PROGRAMS & APPLICATIONS
  # ============================================================================
  
  # Firefox with declarative enterprise policies
  programs.firefox = {
    enable = true;
    
    policies = {
      Preferences = {
        # Persist the Firefox VA-API preferences that were consistently useful.
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
        # uBlock Origin
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        # Privacy Badger
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
        "{d04b0b40-3dab-4f0b-97a6-04ec3eddbfb0}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ecosia-the-green-search/latest.xpi";
          installation_mode = "force_installed";
        };
      };

    };
  };

  programs.fish.enable = true;

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
  
  # ──────────────────────────────────────────────────────────────────────────
  # CACHYOS: Overlay to expose pkgs.cachyosKernels.*
  # To revert to stock: delete or comment out the nixpkgs.overlays block below
  # ──────────────────────────────────────────────────────────────────────────
  nixpkgs.overlays = [
    cachyos-overlay.overlays.default
  ];

  # ============================================================================
  # SYSTEM PACKAGES
  # ============================================================================
  
  environment.systemPackages = with pkgs; [
    localsend
    adw-gtk3
    wget
    bella
    lazygit
    ghostty
    fzf
    fd
    bat
    ripgrep
    emacs-pgtk
    (vscode.override {
      commandLineArgs = "--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland";
    })
    obsidian
    syncthing
    darktable
    zoxide
    eza
    git
    exiftool
    gh
    neovim
    uv
    stow
    gcc
    brave
    onlyoffice-desktopeditors
    freeoffice
    tailscale
    morewaita-icon-theme 
    gopls
    go
    basedpyright
    ruff
    python3
    ansible-language-server 
    ansible-lint
    ansible
    lua-language-server  
    gnomeExtensions.legacy-gtk3-theme-scheme-auto-switcher
  ];

  # ============================================================================
  # GNOME DESKTOP SETTINGS
  # ============================================================================
  
  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    # ----------------------------------------------------
    # Database 1: Locked Settings (User cannot change in GUI)
    # ----------------------------------------------------
    {
      lockAll = true; # Forces these to remain locked and immutable
      settings = {
        "org/gnome/desktop/interface" = {
          accent-color = "blue";
          show-battery-percentage = true;
          icon-theme = "MoreWaita"; 
        };
        "org/gnome/desktop/input-sources" = {
          xkb-options = [ "ctrl:nocaps" ];
        };
        "org/gnome/system/locale" = {
          region = "nb_NO.UTF-8";
        };
        "org/gnome/desktop/peripherals/mouse" = {
          speed = -0.2; 
        };
        "org/gnome/desktop/peripherals/touchpad" = {
          tap-and-drag = false;
        };
        "org/gnome/desktop/background" = {
          picture-uri = "file:///home/haaksk/.local/share/backgrounds/wallhaven-x687ll.png";
          picture-uri-dark = "file:///home/haaksk/.local/share/backgrounds/nix-wallpaper-nineish-dark-gray.svg";
          picture-options = "zoom";
        };
        "org/gnome/desktop/wm/preferences" = {
          button-layout = "appmenu:minimize,maximize,close";
        };
        "org/gnome/shell" = {
          favorite-apps = [
            "firefox.desktop"
            "com.mitchellh.ghostty.desktop"
            "brave-cinhimbnkkaeohfgghhklpknlkffjgod-Default.desktop"
            "org.gnome.Nautilus.desktop"
            "obsidian.desktop"
            "emacs.desktop"
            "code.desktop"
            "onlyoffice-desktopeditors.desktop"
          ];
        };
      };
    }

    # ----------------------------------------------------
    # Database 2: Unlocked Settings (Allows extension overrides)
    # ----------------------------------------------------
    {
      lockAll = false; # Set to false so background extensions can modify these
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "adw-gtk3"; 
        };
      };
    }
  ];

  environment.gnome.excludePackages = with pkgs; [
    showtime
    simple-scan
    snapshot
    yelp
    gnome-tecla
    gnome-music
    gnome-contacts
    decibels
    epiphany
    gnome-tour
  ];

  services.xserver.excludePackages = [ pkgs.xterm ];

  # ============================================================================
  # NETWORKING & FIREWALL
  # ============================================================================
  
  services.tailscale.enable = true;

  networking.firewall = {
    enable = true;
    # Trust the virtual tailscale interface
    trustedInterfaces = [ "tailscale0" ];
    # Allow the Tailscale UDP port
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ config.services.tailscale.port 53317 ];
    checkReversePath = "loose"; 
  };

  # Policy routing to prioritize local LAN traffic over Tailscale
  systemd.services.tailscale-local-route-override = {
    description = "Add policy routing rule to prioritize local LAN traffic over Tailscale";
    after = [ "tailscaled.service" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip rule add to 10.0.0.0/24 priority 2500 lookup main";
      ExecStop = "${pkgs.iproute2}/bin/ip rule del to 10.0.0.0/24 priority 2500 lookup main";
    };
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
  
  services.syncthing = {
    enable = true;

    # Run the service under your local user account
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
          id = "ulv9z-dbglm";              # Must match the server's folder ID exactly
          label = "Sync";                  # Keeps the user-friendly label "Sync" in your GUI
          path = "/home/haaksk/Documents"; # The local target directory on your laptop
          devices = [ "services" ];        # Tell Syncthing to sync this folder with the server
        };
      };
    };
  };

  # Enable systemd-resolved to fix Tailscale suspend/reboot DNS hangs
  services.resolved = {
    enable = true;
    # Ensures a global fallback is used if Tailscale's DNS drops
    domains = [ "~." ];
  };

  services.fwupd.enable = true;

  # ============================================================================
  # NIX PACKAGE MANAGER
  # ============================================================================
  
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

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
