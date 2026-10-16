# Herdr

Linux Herdr configuration. Uses the terminal theme without a generated custom
palette, plus pane layout and keyboard settings without platform-specific paths.
macOS uses a separate copy in `mac-work/herdr/.config/herdr/config.toml`.

From the dotfiles repository root:

```sh
stow --dir=linux-home/common --simulate --verbose --target="$HOME" herdr
stow --dir=linux-home/common --verbose --target="$HOME" herdr
```

Do not stow the Linux and Mac Herdr packages together: both provide the same
config path. To switch from the Linux package to its independent Mac copy:

```sh
stow --dir=linux-home/common --delete --target="$HOME" herdr
stow --dir=mac-work --restow --target="$HOME" herdr
```

For a running Herdr session, apply the settings with:

```sh
herdr server reload-config
```
