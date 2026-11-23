;;; .emacs --- Emacs configuration for macOS -*- lexical-binding: t; -*-

;; Appearance
(setq inhibit-startup-screen t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(add-to-list 'default-frame-alist
             '(font . "FantasqueSansM Nerd Font Mono-15"))

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

(defun my/apply-system-theme (appearance)
  "Apply the theme matching the macOS APPEARANCE."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme (if (eq appearance 'dark)
                  'doom-sourcerer
                'modus-operandi)
              t))

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
 '(package-selected-packages '(doom-themes jinja2-mode yaml-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
