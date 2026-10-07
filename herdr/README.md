# Herdr

Shared Herdr configuration for macOS and Linux. Includes theme, pane layout,
and keyboard settings without platform-specific paths.

From the dotfiles repository root:

```sh
stow --simulate --verbose --target="$HOME" herdr
stow --verbose --target="$HOME" herdr
```

If `mac-work` is already installed, run `stow --restow --target="$HOME" mac-work`
first to remove its old Herdr link, then install `herdr`.

For a running Herdr session, apply the settings with:

```sh
herdr server reload-config
```

With Noctalia, enable the `herdr` community template and reapply templates
after installing this package. Its hook updates `[theme.custom]` in this config
and reloads a running Herdr server. The generated palette is shared when this
package is used on macOS; Noctalia is not required there.
