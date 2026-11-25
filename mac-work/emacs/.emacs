;;; .emacs --- Emacs configuration for macOS -*- lexical-binding: t; -*-

;; Appearance
(setq inhibit-startup-screen t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(add-to-list 'default-frame-alist
             '(font . "FantasqueSansM Nerd Font Mono-16"))

;; Comfortable editing
(cua-mode -1)
(setq delete-selection-save-to-register nil)
(setq-default indent-tabs-mode nil)
(setq ring-bell-function 'ignore)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(save-place-mode 1)
(require 'savehist)
(add-to-list 'savehist-additional-variables 'compile-command)
(add-to-list 'savehist-additional-variables 'compile-history)
(savehist-mode 1)

;; Built-in completion and key discovery
(fido-vertical-mode 1)
(keymap-set icomplete-fido-mode-map
            "TAB" #'icomplete-fido-ret)
(which-key-mode 1)

(keymap-global-unset "C-d")

;; macOS: symbol shortcuts for a Norwegian Windows keyboard.
(when (eq system-type 'darwin)
  (setq ns-right-command-modifier 'super)
  (keymap-set key-translation-map "M-7" (kbd "|"))
  (keymap-set key-translation-map "M-8" (kbd "["))
  (keymap-set key-translation-map "M-9" (kbd "]"))
  (keymap-set key-translation-map "M-S-8" (kbd "{"))
  (keymap-set key-translation-map "M-S-9" (kbd "}"))
  ;; Shift+8/9 can arrive as parentheses rather than shifted digits.
  (keymap-set key-translation-map "M-(" (kbd "{"))
  (keymap-set key-translation-map "M-)" (kbd "}")))

;; Show matching parentheses
(show-paren-mode 1)

;; Line and column in the mode line
(column-number-mode 1)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(setq shell-file-name "/bin/zsh")

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))

(use-package doom-themes
  :ensure t)

(defun my/apply-system-theme (appearance)
  "Apply the theme matching the macOS APPEARANCE."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme (if (eq appearance 'dark)
                  'doom-sourcerer
                'modus-operandi)
              t)
  (set-face-attribute 'fringe nil
                      :background (face-background 'default)))

(add-hook 'ns-system-appearance-change-functions #'my/apply-system-theme)
(my/apply-system-theme (if (boundp 'ns-system-appearance)
                           ns-system-appearance
                         'light))

(add-hook 'python-mode-hook #'eglot-ensure)
(add-hook 'c-mode-hook #'eglot-ensure)

(use-package yaml-mode
  :ensure t
  :mode "\\.ya?ml\\'"
  :custom (yaml-indent-offset 2))

(use-package jinja2-mode
  :ensure t
  :mode "\\.j2\\'")

(use-package jsonnet-mode
  :ensure t
  :mode "\\.\\(jsonnet\\|libsonnet\\)\\'"
  :config
  (add-hook 'jsonnet-mode-hook #'eglot-ensure))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               `((jsonnet-mode)
                 . ,(list (or (executable-find "jsonnet-language-server")
                              (expand-file-name
                               "~/go/bin/jsonnet-language-server"))
                          "--eval-diags" "--lint"))))

(setq eldoc-echo-area-use-multiline-p nil)

(add-hook 'prog-mode-hook #'completion-preview-mode)
(global-set-key (kbd "C-<tab>") #'completion-at-point)

(keymap-global-set "<f5>" #'compile)

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(doom-themes exec-path-from-shell jinja2-mode jsonnet-mode yaml-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
