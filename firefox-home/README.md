# Firefox chrome

Run `firefox-home/install.sh` from the dotfiles repository. The script
finds Firefox's default profile in `profiles.ini` and links this package's
`chrome` directory into it. An existing `chrome` directory is saved alongside
the link as `chrome.backup-YYYYMMDD-HHMMSS`.

Restart Firefox to load changes to `userChrome.css`. The profile must have
`toolkit.legacyUserProfileCustomizations.stylesheets` set to `true` in
`about:config`.
