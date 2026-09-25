{ pkgs, ... }:

{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  programs.firefox = {
    enable = true;
    policies = {
      Preferences = {
        "widget.gtk.libadwaita-colors.enabled" = {
          Value = false;
          Status = "user";
        };
        "toolkit.legacyUserProfileCustomizations.stylesheets" = {
          Value = true;
          Status = "user";
        };
      };
    };
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/wm/preferences" = {
            button-layout = ":minimize,maximize,close";
          };
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    adw-gtk3
  ];

  # Make adw-gtk3-dark the default for all GTK apps
  environment.sessionVariables = {
    GTK_THEME = "adw-gtk3-flat-dark";
  };
}
