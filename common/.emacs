;;; .emacs --- Modern Python Development Environment

;; ==========================================
;; 1. PERFORMANCE & FOUNDATION
;; ==========================================

(setq gc-cons-threshold 100000000   ; 100MB GC for LSP performance
      read-process-output-max (* 1024 1024) ; 1MB chunks
      eglot-events-buffer-size 0)           ; Disable LSP logging for speed

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t)

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x pgtk))
  :config (exec-path-from-shell-initialize))

;; ==========================================
;; 2. UI & UX
;; ==========================================

(use-package doom-themes)

(setq custom-safe-themes
      '("0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
        "5c7720c63b729140ed88cf35413f36c728ab7c70f8cd8422d9ee1cedeb618de5"
        default))

(use-package auto-dark
  :init
  (setq auto-dark-themes           '((doom-one) (doom-one-light))
        auto-dark-detection-method 'dbus)
  :config (auto-dark-mode t))

(cua-mode 1)
(set-face-attribute 'default nil :font "NotoMono Nerd Font-11")

(setq inhibit-startup-screen t
      initial-scratch-message nil
      sentence-end-double-space nil
      ring-bell-function 'ignore)

(setq-default indent-tabs-mode nil
              tab-width 4)

;;(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 0)
(column-number-mode t)
(savehist-mode 1)
(recentf-mode 1)

(add-hook 'dired-mode-hook 'dired-hide-details-mode)
(setq dired-kill-when-opening-new-dired-buffer t
      dired-auto-revert-buffer t)

;; ==========================================
;; 3. SEARCH & COMPLETION
;; ==========================================

(use-package vertico
  :init (vertico-mode)
  :config (setq vertico-cycle t))

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

;; ==========================================
;; 4. TREESITTER & LSP
;; ==========================================

(setq treesit-font-lock-level 4)

(setq treesit-language-source-alist
      '((yaml   . ("https://github.com/ikatyang/tree-sitter-yaml"))
        (python . ("https://github.com/tree-sitter/tree-sitter-python"))
        (go     . ("https://github.com/tree-sitter/tree-sitter-go"))
        (bash   . ("https://github.com/tree-sitter/tree-sitter-bash"))
        (json   . ("https://github.com/tree-sitter/tree-sitter-json"))))

(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (go-mode     . go-ts-mode)
        (yaml-mode   . yaml-ts-mode)
        (bash-mode   . bash-ts-mode)
        (json-mode   . json-ts-mode)))

(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))

(use-package eglot
  :hook ((python-ts-mode . eglot-ensure)
         (go-ts-mode     . eglot-ensure)
         (yaml-ts-mode   . eglot-ensure)
         (bash-ts-mode   . eglot-ensure))
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)
              ("C-c a" . eglot-code-actions)
              ("M-."   . xref-find-definitions)
              ("M-?"   . xref-find-references))
  :config
  (add-to-list 'eglot-server-programs
               '(yaml-ts-mode . ("ansible-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(python-ts-mode . ("basedpyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(go-ts-mode . ("gopls"))))

(use-package apheleia
  :config (apheleia-global-mode +1))

;; ==========================================
;; 4b. ANSIBLE / YAML
;; ==========================================

(defun my/ansible-find-variable ()
  "Search project for the Ansible variable definition around point.
Extracts content between {{ and }}, takes the root key (before first dot),
and searches for 'root_key:' — the YAML definition form."
  (interactive)
  (let* ((start (save-excursion (search-backward "{{" nil t) (+ (point) 2)))
         (end   (save-excursion (search-forward  "}}" nil t) (- (point) 2)))
         (raw   (when (and start end (< start end))
                  (string-trim (buffer-substring-no-properties start end))))
         (root  (when raw (car (split-string raw "\\."))))
         (var   (read-string "Find variable: " (concat (or root "") ":"))))
    (project-find-regexp (regexp-quote var))))

(with-eval-after-load 'yaml-ts-mode
  (define-key yaml-ts-mode-map (kbd "C-c v") 'my/ansible-find-variable))

;; ==========================================
;; 5. PYTHON
;; ==========================================

(use-package pyvenv
  :config
  (defun my/python-uv-venv-activate ()
    "Activate .venv if created by uv in project root."
    (interactive)
    (when-let ((project (project-current)))
      (let ((venv-path (expand-file-name ".venv" (project-root project))))
        (when (file-directory-p venv-path)
          (pyvenv-activate venv-path)
          (when (eglot-current-server)
            (eglot-reconnect (eglot-current-server)))))))

  (defun my/python-run ()
    "Run current file via uv or python3."
    (interactive)
    (when (buffer-modified-p) (save-buffer))
    (let ((cmd (if (file-directory-p ".venv") "uv run python" "python3")))
      (compile (format "%s %S" cmd (buffer-file-name)))))

  (defun my/python-test-run ()
    "Run pytest via uv or pytest."
    (interactive)
    (when (buffer-modified-p) (save-buffer))
    (let ((cmd (if (file-directory-p ".venv") "uv run pytest" "pytest")))
      (compile cmd)))

  :hook (python-ts-mode . my/python-uv-venv-activate)
  :bind (:map python-ts-mode-map
              ("C-c C-c" . my/python-run)
              ("C-c C-t" . my/python-test-run)))

(use-package dape
  :preface (setq dape-buffer-window-arrangement 'right)
  :config  (setq dape-python-client "python3")
  :bind (:map python-ts-mode-map
              ("C-c C-d" . dape)
              ("C-c b"   . dape-breakpoint-toggle)))

;; ==========================================
;; 6. SHELL & GIT
;; ==========================================

(setq shell-file-name "/usr/bin/fish"
      explicit-shell-file-name "/usr/bin/fish")

(defun my/toggle-shell ()
  "Toggle a shell at project root."
  (interactive)
  (let ((shell-buf (get-buffer "*shell*")))
    (if (and shell-buf (get-buffer-window shell-buf))
        (delete-window (get-buffer-window shell-buf))
      (project-shell))))

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)

(use-package magit
  :bind ("C-x g" . magit-status))

;; ==========================================
;; 7. KEYBINDINGS & HOUSEKEEPING
;; ==========================================

(global-set-key (kbd "M-h") 'windmove-left)
(global-set-key (kbd "M-j") 'windmove-down)
(global-set-key (kbd "M-k") 'windmove-up)
(global-set-key (kbd "M-l") 'windmove-right)

(global-set-key (kbd "C-c t") 'my/toggle-shell)
(global-set-key (kbd "C-c p") 'project-switch-project)
(global-set-key (kbd "C-c e") 'dired-jump)
(global-set-key (kbd "C-c s") (lambda () (interactive)
                                (project-find-regexp (thing-at-point 'symbol t))))

(global-set-key (kbd "C-/") 'undo-only)
(global-set-key (kbd "M-/") 'undo-redo)

(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      select-enable-clipboard t)

(defun my/newline-below ()
  "Insert a newline below the current line and jump to it."
  (interactive)
  (end-of-line)
  (newline-and-indent))

(defun my/newline-above ()
  "Insert a newline above the current line and jump to it."
  (interactive)
  (beginning-of-line)
  (newline)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "S-<return>")   'my/newline-below)
(global-set-key (kbd "M-S-<return>") 'my/newline-above)

;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("5c7720c63b729140ed88cf35413f36c728ab7c70f8cd8422d9ee1cedeb618de5"
     "0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     default))
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
