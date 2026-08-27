{ lib, ... }:

{
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasma";


  environment.systemPackages = with pkgs; [
    kate
  ];

  # Work around nixpkgs#126590: Plasma's Qt wrapper creates a very large,
  # duplicated XDG_DATA_DIRS value that slows every KDE application launch.
  nixpkgs.overlays = lib.singleton (
    final: prev:
    {
      kdePackages = prev.kdePackages.overrideScope (
        kdeFinal: kdePrev:
        {
          plasma-workspace =
            let
              basePackage = kdePrev.plasma-workspace;

              mergedShare = prev.stdenv.mkDerivation {
                name = "${basePackage.name}-xdgdata";
                buildInputs = [ basePackage ];
                dontUnpack = true;
                dontFixup = true;
                dontWrapQtApps = true;
                installPhase = ''
                  mkdir -p $out/share
                  for directory in $XDG_DATA_DIRS; do
                    if [[ -d "$directory" ]]; then
                      ${prev.lib.getExe prev.lndir} -silent "$directory" $out
                    fi
                  done
                '';
              };
            in
            basePackage.overrideAttrs (oldAttrs: {
              preFixup = (oldAttrs.preFixup or "") + ''
                for index in "''${!qtWrapperArgs[@]}"; do
                  if [[ ''${qtWrapperArgs[$((index+0))]} == "--prefix" ]] \
                    && [[ ''${qtWrapperArgs[$((index+1))]} == "XDG_DATA_DIRS" ]]; then
                    unset -v "qtWrapperArgs[$((index+0))]"
                    unset -v "qtWrapperArgs[$((index+1))]"
                    unset -v "qtWrapperArgs[$((index+2))]"
                    unset -v "qtWrapperArgs[$((index+3))]"
                  fi
                done
                qtWrapperArgs=("''${qtWrapperArgs[@]}")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "${mergedShare}/share")
                qtWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
              '';
            });
        }
      );
    }
  );
}
