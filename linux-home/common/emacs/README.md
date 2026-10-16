# Emacs home configuration

Standalone Stow package based on the active Home Manager configuration.

```sh
stow --dir=linux-home/common --simulate --verbose --target="$HOME" emacs
stow --dir=linux-home/common --verbose --target="$HOME" emacs
```

Remove Home Manager's `home.file.".emacs"` declaration before installing.
Back up the existing `~/.emacs` symlink before stowing. Do not stow this
package together with `omarchy/emacs` or `not-in-use/emacs`.

Uses `doom-sourcerer` from `doom-themes`, restored from the earlier configuration.
The theme is independent of desktop-generated palettes and does not switch
automatically. Installed packages, Custom settings and runtime state are not
tracked here. Editor behaviour and keybindings are preserved.
