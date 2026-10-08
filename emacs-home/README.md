# Emacs home configuration

Standalone Stow package based on the active Home Manager configuration.

```sh
stow --simulate --verbose --target="$HOME" emacs-home
stow --verbose --target="$HOME" emacs-home
```

Remove Home Manager's `home.file.".emacs"` declaration before installing.
Back up the existing `~/.emacs` symlink before stowing. Do not stow this
package together with `omarchy/emacs` or `not-in-use/emacs`.

Noctalia generates `~/.emacs.d/themes/noctalia-theme.el` through its enabled
built-in Emacs template. Generated colours, installed packages, Custom
settings and runtime state are not tracked here. Emacs loads the generated
theme on startup; run `M-x my/load-noctalia-theme` after changing the wallpaper
to reload its colours. Before the theme exists, Emacs uses built-in
`modus-vivendi` as a fallback.

The old Cosmic face overrides, Doom theme dependency and auto-dark theme
switching have been removed. Editor behaviour and keybindings are preserved.
