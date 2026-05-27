# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Oslo";
  
  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "no";
    variant = "nodeadkeys";
  };

  # Configure console keymap
  console.keyMap = "no";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "iHD"; 
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.haaksk = {
    isNormalUser = true;
    description = "Håkon Skogsrud";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  fonts.packages = with pkgs; [
    ibm-plex
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    cantarell-fonts # Clean native GNOME UI font fallback
  ];

  # Enable browsers and shells via native programs module
  programs.firefox = {
    enable = true;
    
    # Declarative Enterprise Policies
    policies = {
      # 1. Automatically install Extensions
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    rapidraw
    localsend
    adw-gtk3
    wget
    lazygit
    ghostty
    fzf
    emacs-pgtk
    vscode
    obsidian
    syncthing
    zoxide
    eza
    git
    gh
    uv
    stow
    brave
    onlyoffice-desktopeditors
    tailscale
    morewaita-icon-theme 
    gopls                   # Go LSP
    go                      # Go language compiler (for testing/compiling)
    basedpyright            # Python LSP
    ruff                    # Python formatter/linter
    python3                 # Python interpreter (for runtimes)
    ansible-language-server # Ansible LSP
    ansible-lint
    lua-language-server     # Lua LSP
    gnomeExtensions.legacy-gtk3-theme-scheme-auto-switcher
  ];

  # GNOME Declarative Settings
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
          speed = -0.5; 
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
  ];

  # Enable the Tailscale service daemon
  services.tailscale.enable = true;

  # Configure the firewall to allow Tailscale traffic
  networking.firewall = {
    enable = true;
    # Trust the virtual tailscale interface
    trustedInterfaces = [ "tailscale0" ];
    # Allow the Tailscale UDP port
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ config.services.tailscale.port 53317 ];
    checkReversePath = "loose"; 
  };
  # Force traffic to the local home network to bypass Tailscale policy rules
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

  # Enable Hardware Video Acceleration for your Intel GPU
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver  # Modern Intel VA-API driver
    ];
  };

  programs.neovim = {
    enable = true;
    withNodeJs = true; # Generates node-client host providers for Neovim
  };

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

  system.stateVersion = "25.11";
  services.fwupd.enable = true;
  nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };

    # Recommended: Automatically deduplicate files in your Nix store to save even more space
    nix.settings = {
      # Automatically deduplicate files in your Nix store
      auto-optimise-store = true;
    
      # Enable Flakes and the modern nix CLI tool
      experimental-features = [ "nix-command" "flakes" ];
    };

  system.autoUpgrade = {
    enable = true;
    dates = "04:00";
    channel = "https://nixos.org/channels/nixos-unstable";
    allowReboot = false; 
    
    # --- ADD THIS FOR LAPTOPS ---
    # If the laptop was off at 4:00 AM, run the update immediately on boot
    persistent = true; 

    # (Optional) Add a randomized delay so the update doesn't slam your 
    # internet connection the exact second you boot up and log in.
    randomizedDelaySec = "30min"; 
  };
 }
