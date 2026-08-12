{ pkgs, ... }:

{
  # Adds COSMIC as a selectable session in GDM.
  services.desktopManager.cosmic.enable = true;

  # A separate home directory prevents GNOME/COSMIC configuration collisions.
  users.users.cosmic-test = {
    isNormalUser = true;
    description = "COSMIC test user";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };
}
