{ config, pkgs, ... }:

{
  # ============================================================================
  # IMPORTS
  # ============================================================================
  imports = [
    ./hardware-configuration.nix
  ];

  # ============================================================================
  # BOOT & SYSTEM CORE
  # ============================================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;  # Stock NixOS kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

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
    ZED_RENDERER = "gles"; # Force OpenGL ES to fix Zed editor Intel GPU lag/freezes
    XCURSOR_THEME = "Adwaita"; # Fix Wayland cursor spinning/fallback loading loops
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
    ibm-plex
    nerd-fonts.comic-shanns-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.commit-mono
    nerd-fonts.hack
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
    nix-direnv # Integrates nix-shell/flake loading seamlessly

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

    # Applications and Utilities
    bella
    ghostty
    gitte
    darktable
    syncthing
    (vscodium.override {
      commandLineArgs = "--enable-features=UseOzonePlatform,WaylandWindowDecorations --ozone-platform=wayland --enable-wayland-ime=true --wayland-text-input-version=3";
    })
    emacs-pgtk
    brave
    tailscale
    morewaita-icon-theme
    hicolor-icon-theme
    adwaita-icon-theme

    # Desktop and Theme Packages
    adw-gtk3
    gnomeExtensions.dash-to-dock
    gnomeExtensions.legacy-gtk3-theme-scheme-auto-switcher

    # Other Tools
    nodejs
  ];

  # ============================================================================
  # GNOME DESKTOP SETTINGS
  # ============================================================================

  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
    # ----------------------------------------------------
    # Database 1: Locked Settings
    # ----------------------------------------------------
    {
      lockAll = true;
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
          disable-while-typing = true;
        };
        "org/gnome/desktop/wm/preferences" = {
          button-layout = "appmenu:minimize,maximize,close";
        };
        "org/gnome/shell" = {
          enabled-extensions = [
            "dash-to-dock@micxgx.gmail.com"
            "legacyschemeautoswitcher@joshimukul29.gmail.com"
          ];
          favorite-apps = [
            "firefox.desktop"
            "com.mitchellh.ghostty.desktop"
            "emacs.desktop"
            "brave-cinhimbnkkaeohfgghhklpknlkffjgod-Default.desktop"
            "org.gnome.Nautilus.desktop"
            "md.obsidian.Obsidian.desktop"
            "org.onlyoffice.desktopeditors.desktop"
            "LocalSend.desktop"
            "de.wwwtech.gitte.desktop"
            "org.darktable.darktable.desktop"
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
        "org/gnome/desktop/background" = {
          picture-uri = "file:///home/haaksk/.local/share/backgrounds/wallhaven-x687ll.png";
          picture-uri-dark = "file:///home/haaksk/.local/share/backgrounds/nix-wallpaper-nineish-dark-gray.svg";
          picture-options = "zoom";
        };

        "org/gnome/shell/extensions/dash-to-dock" = {
          dock-position = "LEFT";
          extend-height = true;
          dock-fixed = false;
          autohide = true;
          intellihide-mode = "ALL_WINDOWS";
          show-mounts = false;
          show-trash = false;

          # --- Background & Transparency ---
          custom-background-color = true;
          background-color = "rgb(0,0,0)";
          transparency-mode = "FIXED";
          background-opacity = 0.75;
          customize-alphas = true;
          min-alpha = 0.75;
          max-alpha = 0.75;
          apply-custom-theme = false;

          # --- Compact / Shrink Options ---
          custom-theme-shrink = true;
          #height-fraction = 0.9;
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  networking.firewall = {
    enable = true;
    # Trust the virtual tailscale interface
    trustedInterfaces = [ "tailscale0" ];
    # Allow the Tailscale UDP port
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
          id = "ulv9z-dbglm"; # Must match the server's folder ID exactly
          label = "Sync"; # Keeps the user-friendly label "Sync" in your GUI
          path = "/home/haaksk/Documents"; # The local target directory on your laptop
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
