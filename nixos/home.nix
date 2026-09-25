{ ... }:

{
  home.username = "haaksk";
  home.homeDirectory = "/home/haaksk";
  home.stateVersion = "26.05";

  # Install the existing dotfiles during nixos-rebuild.
  home.file.".zshrc".source = ./zshrc;
  home.file.".tmux.conf".source = ./tmux.conf;
  home.file.".config/ghostty/config".source = ./ghostty.conf;
  home.file.".config/lazygit/config.yml".source = ./lazygit.yml;
  home.file.".emacs".source = ./emacs.el;
  home.file.".codex/config.toml".source = ./codex-config.toml;
}
