;; Appearance
(setq inhibit-startup-screen t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(add-to-list 'default-frame-alist
             '(font . "FantasqueSansM Nerd Font Mono-14"))

;; Comfortable editing
(cua-mode 1)
(setq-default indent-tabs-mode nil)
(setq ring-bell-function 'ignore)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(save-place-mode 1)
(savehist-mode 1)

;; Built-in completion and key discovery
(fido-vertical-mode 1)
(keymap-set icomplete-fido-mode-map
            "TAB" #'icomplete-fido-ret)
(which-key-mode 1)

(keymap-global-unset "C-d")

;; Show matching parentheses
(show-paren-mode 1)

;; Line and column in the mode line
(column-number-mode 1)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(use-package doom-themes
  :ensure t)

(use-package gnome-dark-style
  :ensure t
  :custom
  (gnome-light-theme 'modus-operandi)
  (gnome-dark-theme 'doom-sourcerer)
  :config
  (setopt gnome-dark-style-sync t))

(use-package envrc
  :ensure t
  :hook (after-init . envrc-global-mode))

(defun my/nix-compile-command ()
  (setq-local compile-command
              "sudo nixos-rebuild switch --flake /home/haaksk/nixos#nixos"))

(use-package nix-mode
  :ensure t
  :pin melpa
  :custom (nix-nixfmt-args '("-"))
  :mode "\\.nix\\'"
  :hook ((nix-mode . eglot-ensure)
         (nix-mode . my/nix-compile-command)))

(add-hook 'python-mode-hook #'eglot-ensure)
(add-hook 'c-mode-hook #'eglot-ensure)

(add-hook 'prog-mode-hook #'completion-preview-mode)
(global-set-key (kbd "C-<tab>") #'completion-at-point)

(keymap-global-set "<f5>" #'compile)

;;; init.el ends here
