;;; init.el --- Minimal home Emacs

;; Appearance
(setq inhibit-startup-screen t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(cua-mode 1)
(add-to-list 'default-frame-alist
             '(font . "FantasqueSansM Nerd Font Mono-13"))

;; Use Emacs' built-in light theme
(load-theme 'modus-operandi t)

;; Comfortable editing
(setq-default indent-tabs-mode nil)
(setq ring-bell-function 'ignore)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(save-place-mode 1)
(savehist-mode 1)

;; Built-in completion and key discovery
(fido-vertical-mode 1)
(which-key-mode 1)

;; Show matching parentheses
(show-paren-mode 1)

;; Line and column in the mode line
(column-number-mode 1)


(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))


(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'"
  :hook (nix-mode . eglot-ensure)
  :config
  (add-hook 'nix-mode-hook
            (lambda ()
              (setq-local compile-command "TERM=dumb NO_COLOR=1 nh os switch"))))


(add-hook 'prog-mode-hook #'completion-preview-mode)
(global-set-key (kbd "C-<tab>") #'completion-at-point)

(keymap-global-set "<f5>" #'compile)
;;; init.el ends here
