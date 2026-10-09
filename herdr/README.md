# Herdr

Linux/Noctalia Herdr configuration. Includes theme, pane layout, and keyboard
settings without platform-specific paths. macOS uses a separate copy in
`mac-work/.config/herdr/config.toml` so Noctalia palette updates do not affect it.

From the dotfiles repository root:

```sh
stow --simulate --verbose --target="$HOME" herdr
stow --verbose --target="$HOME" herdr
```

Do not stow `herdr` and `mac-work` together: both provide the same config path.
To switch an existing Mac installation from `herdr` to its independent copy:

```sh
stow --delete --target="$HOME" herdr
stow --restow --target="$HOME" mac-work
```

For a running Herdr session, apply the settings with:

```sh
herdr server reload-config
```

With Noctalia, enable the `herdr` community template and reapply templates
after installing this package. Its hook updates `[theme.custom]` in this config
and reloads a running Herdr server. Only the Linux package receives the generated
palette; the Mac copy is maintained independently.
