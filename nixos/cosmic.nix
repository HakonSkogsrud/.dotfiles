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
  
}

