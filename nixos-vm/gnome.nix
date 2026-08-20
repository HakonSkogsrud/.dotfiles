{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    morewaita-icon-theme
    hicolor-icon-theme
    adwaita-icon-theme
    ghostty
    bella
    gitte
    adw-gtk3
    gnomeExtensions.legacy-gtk3-theme-scheme-auto-switcher
  ];

  programs.dconf.enable = true;
  programs.dconf.profiles.user.databases = [
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
          button-layout = "appmenu:close";
        };
        "org/gnome/shell" = {
          enabled-extensions = [
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
            "codium.desktop"
            "org.darktable.darktable.desktop"
          ];
        };
      };
    }
    {
      lockAll = false;
      settings = {
        "org/gnome/desktop/interface" = {
          gtk-theme = "adw-gtk3";
        };
        "org/gnome/desktop/background" = {
          picture-uri = "file:///home/haaksk/.dotfiles/gnome/.local/share/backgrounds/nixos-wallpaper-mist.png";
          picture-uri-dark = "file:///home/haaksk/.dotfiles/gnome/.local/share/backgrounds/3440x1440-dark-grey.png";
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
