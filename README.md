# Dotfiles

Each app is an independent Stow package. Package groups are organizational
directories, not packages:

```text
shared/                # Cross-platform apps: nvim, opencode, codex
mac-work/              # Work Mac: zsh, git, vscode, alacritty, ghostty, herdr, lazygit
linux-home/common/     # Home Linux: zsh, emacs, tmux, ghostty, lazygit, herdr, zed, ssh, vscode, obsidian, firefox
linux-home/gnome/      # GNOME: gtk, vscode, obsidian
linux-home/kde/        # KDE: vscode
not-in-use/            # Archived configurations
omarchy/               # Separate, optional Omarchy setup
```

Run the commands below from the repository root. The root `.stowrc` enables
`--no-folding`, keeping destination directories real and linking individual files.
Always specify `--target="$HOME"`: nested package groups would otherwise change
Stow's default target.

## Work Mac

Preview first; remove `--simulate` to install:

```sh
stow --dir=shared --target="$HOME" --simulate nvim opencode codex
stow --dir=mac-work --target="$HOME" --simulate zsh git vscode alacritty ghostty herdr lazygit
```

## Home Linux

Choose individual shared packages and Linux apps:

```sh
stow --dir=shared --target="$HOME" --simulate nvim opencode codex
stow --dir=linux-home/common --target="$HOME" --simulate zsh emacs tmux ghostty lazygit herdr zed ssh vscode obsidian
```

Then choose one desktop's packages:

```sh
# GNOME
stow --dir=linux-home/gnome --target="$HOME" --simulate gtk vscode obsidian

# KDE
stow --dir=linux-home/kde --target="$HOME" --simulate vscode
```

Linux's common VS Code package owns keybindings; the selected desktop's VS Code
package owns `settings.json`. The common Obsidian package owns plugin lists;
the GNOME package owns appearance and snippets. There is no active KDE Obsidian
appearance package yet; the old one remains in `not-in-use`.

Firefox is an exception to Stow: its chrome files belong inside a discovered
profile directory. Run `linux-home/common/firefox/install.sh` instead; see its
README. Do not stow that package into `$HOME`.

## Switching or removing packages

Use the same group and app name with `--delete`, then install the replacement:

```sh
stow --dir=linux-home/gnome --target="$HOME" --delete gtk vscode obsidian
stow --dir=linux-home/kde --target="$HOME" vscode
```

Each destination file must have one owner. Do not install Mac and Linux variants
of the same app together, or GNOME and KDE VS Code settings together. Stow reports
conflicts instead of overwriting existing files; back up unmanaged destination
files before installing.

Desktop packages manage files only. GNOME dconf settings and installed apps,
extensions, fonts and themes still need separate setup.

## Migrating an existing checkout

Old top-level packages have moved into the groups above. Existing symlinks on
other machines must be unstowed using the old layout **before** updating the
checkout, then installed using the new commands. This includes Firefox's profile
`chrome` link, which can be repaired by rerunning its installer.

The Noctalia desktop and the old standalone Noctalia Obsidian appearance are
archived in `not-in-use/niri-noctalia` and `not-in-use/obsidian-noctalia`.
