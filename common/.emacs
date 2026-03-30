;;; init.el --- Modern Python Development Environment (Minimalist)

;; ==========================================
;; 1. PERFORMANCE & FOUNDATION
;; ==========================================

(setq gc-cons-threshold 100000000) ; 100MB GC for LSP performance
(setq read-process-output-max (* 1024 1024)) ; 1MB chunks
(setq eglot-events-buffer-size 0) ; Disable LSP logging for speed

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t)

;; Ensure Emacs matches your shell's $PATH (crucial for Mac/Linux)
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x pgtk))
  :config (exec-path-from-shell-initialize))

;; ==========================================
;; 2. MINIMALIST UI & UX
;; ==========================================

(setq inhibit-startup-screen t
      initial-scratch-message nil
      sentence-end-double-space nil
      ring-bell-function 'ignore)

(setq-default indent-tabs-mode nil
              tab-width 4)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 10)
(column-number-mode t)
(savehist-mode 1)
(recentf-mode 1)

;; High-quality built-in light theme
(load-theme 'modus-operandi t)

;; ==========================================
;; 3. SEARCH & COMPLETION (Vertico + Corfu)
;; ==========================================

;; Vertical completion for M-x and finding files
(use-package vertico
  :init (vertico-mode)
  :config (setq vertico-cycle t))

;; "Fuzzy" matching logic
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

;; Metadata in the margins (file sizes, docstrings)
(use-package marginalia
  :init (marginalia-mode))

;; In-buffer completion popups (IDE-like)
(use-package corfu
  :init (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.0)
  (corfu-auto-prefix 1)
  (corfu-preselect 'first)
  (corfu-quit-at-boundary t))

;; ==========================================
;; 4. TREESITTER & LSP (The Engine)
;; ==========================================

(setq treesit-font-lock-level 4)

;; Automatically use Treesitter modes for these languages
(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (go-mode . go-ts-mode)
        (yaml-mode . yaml-ts-mode)
        (bash-mode . bash-ts-mode)
        (json-mode . json-ts-mode)))

(use-package eglot
  :hook ((python-ts-mode . eglot-ensure)
         (go-ts-mode . eglot-ensure)
         (yaml-ts-mode . eglot-ensure)
         (bash-ts-mode . eglot-ensure))
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)
              ("C-c a" . eglot-code-actions)
              ("M-." . xref-find-definitions)
              ("M-?" . xref-find-references))
  :config
  (add-to-list 'eglot-server-programs
               '(yaml-ts-mode . ("ansible-language-server" "--stdio"))))

;; Auto-formatting on save
(use-package apheleia
  :config (apheleia-global-mode +1))

;; ==========================================
;; 5. PYTHON SPECIFIC (Venv, Run, Test, Debug)
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

;; Debugging (Dape is the modern, faster DAP client)
(use-package dape
  :preface
  (setq dape-buffer-window-arrangement 'right)
  :config
  (setq dape-python-client "python3") ; Uses the pyvenv active python
  :bind (:map python-ts-mode-map
              ("C-c C-d" . dape)
              ("C-c b" . dape-breakpoint-toggle)))

;; ==========================================
;; 6. SHELL & TERMINAL
;; ==========================================

(setq shell-file-name "/usr/bin/fish")
(setq explicit-shell-file-name "/usr/bin/fish")

(defun my/toggle-shell ()
  "Toggle a shell at project root."
  (interactive)
  (let ((shell-buf (get-buffer "*shell*")))
    (if (and shell-buf (get-buffer-window shell-buf))
        (delete-window (get-buffer-window shell-buf))
      (project-shell))))

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)

;; ==========================================
;; 7. GLOBAL KEYBINDINGS & HOUSEKEEPING
;; ==========================================

;; Navigation
(global-set-key (kbd "M-h") 'windmove-left)
(global-set-key (kbd "M-j") 'windmove-down)
(global-set-key (kbd "M-k") 'windmove-up)
(global-set-key (kbd "M-l") 'windmove-right)

;; Project & Files
(global-set-key (kbd "C-c t") 'my/toggle-shell)
(global-set-key (kbd "C-c p") 'project-switch-project)
(global-set-key (kbd "C-c e") 'dired-jump)
(global-set-key (kbd "C-c s") (lambda () (interactive) (project-find-regexp (thing-at-point 'symbol t))))

;; Undo/Redo
(global-set-key (kbd "C-/") 'undo-only)
(global-set-key (kbd "M-/") 'undo-redo)

;; Backups
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups"))))
(setq select-enable-clipboard t)

;;; init.el ends here

;; =============================================================================
;; QUICK REFERENCE: KEYBINDINGS & SHORTCUTS
;; =============================================================================

;; --- PROJECTS (Built-in project.el) ---
;; C-x p f      -> Find file in project (Fuzzy via Vertico)
;; C-x p p      -> Switch project (Choose from known project roots)
;; C-x p d      -> Open Dired (File Manager) at project root
;; C-x p g      -> Search for regexp string in project (grep/ripgrep)
;; C-c p        -> Switch project (Custom shortcut)

;; --- SEARCHING & NAVIGATION ---
;; C-x C-f      -> Open/Find file (Fuzzy via Vertico)
;; C-x b        -> Switch buffer (Fuzzy via Vertico)
;; M-x          -> Run command (Fuzzy with Orderless filtering)
;; C-s / C-r    -> Search forward/backward in current buffer
;; M-g i        -> "Imenu": Jump to any function/class/variable in buffer
;; C-c s        -> Search for word-under-cursor across whole project
;; C-c e        -> "Explore": Open Dired in the current file's directory

;; --- PYTHON DEVELOPMENT ---
;; C-c C-c      -> Run current file (uv run or python3)
;; C-c C-t      -> Run pytest (uv run pytest or pytest)
;; M-x pyvenv-workon -> Manually switch/select a virtual environment
;; Files are auto-formatted on save via Apheleia (Black/Ruff)

;; --- LSP & INTELLISENSE (Eglot) ---
;; M-.          -> Go to Definition
;; M-?          -> Find References (Usage of symbol)
;; M-,          -> Jump back from definition
;; C-c r        -> Rename symbol (Refactor)
;; C-c a        -> Code Actions (Quick fixes/Imports)
;; K            -> Show documentation at point (Eldoc)
;; C-M-i        -> Trigger completion manually (if Corfu isn't open)

;; --- DEBUGGING (Dape) ---
;; C-c b        -> Toggle Breakpoint
;; C-c C-d      -> Start/Select Debugging session
;; Inside Debugging:
;;   n -> Next line (Step over)
;;   i -> Step In
;;   o -> Step Out (Return)
;;   c -> Continue to next breakpoint
;;   q -> Stop/Quit debugger
;;   r -> Restart session

;; --- TERMINAL & SHELL ---
;; C-c t        -> Toggle Fish Shell (opens at project root)
;; M-!          -> Run a single shell command
;; In Shell:
;;   C-c C-c    -> Interrupt process (Standard Ctrl-C)
;;   C-d        -> Exit shell

;; --- WINDOWS & INTERFACE ---
;; M-h/j/k/l    -> Move focus Left/Down/Up/Right
;; C-x 2        -> Split window horizontally (Top/Bottom)
;; C-x 3        -> Split window vertically (Left/Right)
;; C-x 0        -> Close current window
;; C-x 1        -> Close all other windows (Maximize current)
;; C-/          -> Undo
;; M-/          -> Redo (Custom)

;; =============================================================================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
