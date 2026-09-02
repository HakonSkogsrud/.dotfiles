{ pkgs, ... }:

let
  papirus-palebrown = pkgs.runCommand "papirus-icon-theme-palebrown" {
    nativeBuildInputs = [ pkgs.papirus-folders ];
  } ''
    mkdir -p "$out/share/icons"
    cp -r ${pkgs.papirus-icon-theme}/share/icons/. "$out/share/icons/"
    chmod -R u+w "$out/share/icons"

    USER_HOME="$TMPDIR" DISABLE_UPDATE_ICON_CACHE=1 \
      papirus-folders --once --color palebrown \
        --theme "$out/share/icons/Papirus"
  '';
in
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    papirus-palebrown
    hicolor-icon-theme
    adwaita-icon-theme

    ghostty
    bella
    gitte

    gnomeExtensions.legacy-gtk3-theme-scheme-auto-switcher
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
          icon-theme = "Papirus";
          font-name = "Inter 11";
          document-font-name = "Inter 11";
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
          button-layout = "appmenu:close";
          titlebar-font = "Inter Bold 11";
        };
        "org/gnome/shell" = {
          enabled-extensions = [
            "legacyschemeautoswitcher@joshimukul29.gmail.com"
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
        "org/gnome/shell" = {
          favorite-apps = [
            "firefox.desktop"
            "com.mitchellh.ghostty.desktop"
            "emacs.desktop"
            "brave-cinhimbnkkaeohfgghhklpknlkffjgod-Default.desktop"
            "org.gnome.Nautilus.desktop"
            "md.obsidian.Obsidian.desktop"
            "org.onlyoffice.desktopeditors.desktop"
            "org.localsend.localsend_app.desktop"
            "de.wwwtech.gitte.desktop"
            "codium.desktop"
            "org.darktable.darktable.desktop"
          ];
        };
        "org/gnome/desktop/background" = {
          picture-uri = "file:///home/haaksk/Documents/wallpapers/gnome/flight_light.webp";
          picture-uri-dark = "file:///home/haaksk/Documents/wallpapers/gnome/flight_dark.webp";
          picture-options = "zoom";
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
    gnome-logs
    pkgs.gnome-connections
    gnome-weather
    gnome-clocks
    gnome-calendar
    gnome-calculator
    pkgs.nixos-render-docs
  ];

  environment.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
  };

  services.xserver.excludePackages = [ pkgs.xterm ];

}
