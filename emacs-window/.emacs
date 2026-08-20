;; Windows Emacs configuration

;; ==========================================
;; 1. FOUNDATION
;; ==========================================

(setq gc-cons-threshold 100000000
      read-process-output-max (* 4 1024 1024)
      redisplay-skip-fontification-on-input t
      bidi-inhibit-bpa t)

(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right
              indent-tabs-mode nil
              tab-width 4)

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t)

;; ==========================================
;; 2. EDITING & NAVIGATION
;; ==========================================

(cua-mode 1)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      confirm-kill-processes nil
      sentence-end-double-space nil
      ring-bell-function 'ignore
      scroll-conservatively 101
      mouse-wheel-scroll-amount '(2 ((shift) . 5))
      mouse-wheel-progressive-speed nil
      select-active-regions nil
      mouse-drag-copy-region nil)

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode t)
(savehist-mode 1)
(recentf-mode 1)
(pixel-scroll-precision-mode 1)

(defun my/underscore-is-word-constituent ()
  (modify-syntax-entry ?_ "w"))
(add-hook 'after-change-major-mode-hook #'my/underscore-is-word-constituent)

(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(setq dired-kill-when-opening-new-dired-buffer t
      dired-auto-revert-buffer t)

;; ==========================================
;; 3. SEARCH & COMPLETION
;; ==========================================

(setq xref-search-program 'ripgrep)

(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init (marginalia-mode))

(use-package corfu
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.0)
  (corfu-auto-prefix 1)
  (corfu-preselect 'first)
  (corfu-quit-at-boundary t))

(defun my/find-file-home ()
  "Search for files under the home directory with fd."
  (interactive)
  (consult-fd "~/"))

(use-package consult
  :bind (("C-c f" . project-find-file)
         ("C-c h" . my/find-file-home))
  :config
  (setq consult-fd-args
        '("fd" "--full-path" "--color=never" "--hidden" "--exclude" ".git")))

(use-package which-key
  :init (which-key-mode)
  :custom
  (which-key-idle-delay 0.4)
  (which-key-sort-order 'which-key-key-order-alpha))

;; ==========================================
;; 4. ANSIBLE & YAML SYNTAX
;; ==========================================

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(define-derived-mode ansible-yaml-mode yaml-mode "Ansible"
  "Major mode for Ansible YAML files."
  (setq-local indent-tabs-mode nil
              tab-width 2))

(defun my/ansible-maybe-activate ()
  "Use Ansible YAML syntax for files in an Ansible project."
  (when (locate-dominating-file default-directory "ansible.cfg")
    (ansible-yaml-mode)))
(add-hook 'yaml-mode-hook #'my/ansible-maybe-activate)

;; Recheck the preceding extension, so playbook.yml.j2 gets YAML syntax.
(add-to-list 'auto-mode-alist '("\\.j2\\'" nil t))

(defun my/ansible-find-variable ()
  "Search the current project for the Ansible variable at point."
  (interactive)
  (let* ((start (save-excursion (search-backward "{{" nil t) (+ (point) 2)))
         (end (save-excursion (search-forward "}}" nil t) (- (point) 2)))
         (raw (when (and start end (< start end))
                (string-trim (buffer-substring-no-properties start end))))
         (root (when raw (car (split-string raw "\\."))))
         (variable (read-string "Find variable: " (concat (or root "") ":"))))
    (project-find-regexp (regexp-quote variable))))

(define-key ansible-yaml-mode-map (kbd "C-c v") #'my/ansible-find-variable)

;; ==========================================
;; 5. PYTHON
;; ==========================================

(use-package eglot
  :hook (python-mode . eglot-ensure)
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)
              ("C-c a" . eglot-code-actions)
              ("M-." . xref-find-definitions)
              ("M-?" . xref-find-references))
  :config
  (add-to-list 'eglot-server-programs
               '(python-mode . ("uvx" "--from" "basedpyright"
                                "basedpyright-langserver" "--stdio"))))

;; ==========================================
;; 6. KEYBINDINGS & HOUSEKEEPING
;; ==========================================

(global-unset-key (kbd "C-d"))

(global-set-key (kbd "M-h") #'windmove-left)
(global-set-key (kbd "M-j") #'windmove-down)
(global-set-key (kbd "M-k") #'windmove-up)
(global-set-key (kbd "M-l") #'windmove-right)

(global-set-key (kbd "C-c p") #'project-switch-project)
(global-set-key (kbd "C-c e") #'dired-jump)
(global-set-key (kbd "C-c k") #'where-is)
(global-set-key (kbd "C-c s")
                (lambda ()
                  (interactive)
                  (project-find-regexp (thing-at-point 'symbol t))))

(global-set-key (kbd "C-/") #'undo-only)
(global-set-key (kbd "M-/") #'undo-redo)

(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups" user-emacs-directory)))
      select-enable-clipboard t
      save-interprogram-paste-before-kill t
      kill-do-not-save-duplicates t)

(setq window-combination-resize t)
(winner-mode 1)

(defun my/toggle-delete-other-windows ()
  "Delete other windows, or restore the previous window configuration."
  (interactive)
  (if (and winner-mode
           (equal (selected-window) (next-window)))
      (winner-undo)
    (delete-other-windows)))

(global-set-key (kbd "C-x 1") #'my/toggle-delete-other-windows)
