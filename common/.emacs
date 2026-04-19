                                        ; .emacs --- Modern Python Development Environment

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
  :config
  (dolist (var '("PATH" "GOPATH" "LC_ALL"))
    (exec-path-from-shell-copy-env var)))

;; ==========================================
;; 2. UI & UX
;; ==========================================

(use-package doom-themes)

(setq custom-safe-themes t)

(use-package auto-dark
  :init
  (setq auto-dark-themes           '((doom-tomorrow-night) (modus-operandi))
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

(use-package consult
  :bind (("C-c f" . project-find-file)
         ("C-c F" . consult-fd))
  :config
  (setq consult-fd-args '((if (executable-find "fdfind") "fdfind" "fd")
                          "--full-path --color=never --hidden --exclude .git")))

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
      '((go-mode     . go-ts-mode)
        (yaml-mode   . yaml-ts-mode)
        (bash-mode   . bash-ts-mode)
        (json-mode   . json-ts-mode)))

(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))

;; Recognize .j2 files by the extension before it: foo.yml.j2 → yaml-ts-mode, etc.
;; The (nil t) form strips .j2 and re-checks auto-mode-alist on the remainder.
(add-to-list 'auto-mode-alist '("\\.j2\\'" nil t))

(use-package eglot
  :hook ((python-mode    . eglot-ensure)
         (go-ts-mode     . eglot-ensure)
         (ansible-ts-mode . eglot-ensure)
         (bash-ts-mode   . eglot-ensure))
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)
              ("C-c a" . eglot-code-actions)
              ("M-."   . xref-find-definitions)
              ("M-?"   . xref-find-references))
  :config
  (add-to-list 'eglot-server-programs
               '(ansible-ts-mode . ("ansible-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("basedpyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(go-ts-mode . ("gopls"))))

(use-package apheleia
  :config (apheleia-global-mode +1))

;; ==========================================
;; 4b. ANSIBLE / YAML
;; ==========================================

;; Define ansible-ts-mode as a yaml-ts-mode derivative so eglot can
;; target it separately from plain yaml files.
(define-derived-mode ansible-ts-mode yaml-ts-mode "Ansible"
  "Major mode for Ansible YAML files.")

;; Auto-activate ansible-ts-mode when the file lives in an Ansible project
;; (detected by ansible.cfg anywhere up the directory tree).
(defun my/ansible-maybe-activate ()
  (unless (derived-mode-p 'ansible-ts-mode)
    (when (locate-dominating-file default-directory "ansible.cfg")
      (ansible-ts-mode))))
(add-hook 'yaml-ts-mode-hook #'my/ansible-maybe-activate)

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

(define-key ansible-ts-mode-map (kbd "C-c v") #'my/ansible-find-variable)

(with-eval-after-load 'eglot
  (setq-default eglot-workspace-configuration
                (append (bound-and-true-p eglot-workspace-configuration)
                        '((:basedpyright
                           . ((typeCheckingMode . "standard")
                              (reportUnknownVariableType . "none")
                              ;;(reportUnknownMemberType . "none")
                              ;;(reportUnknownParameterType . "none")
                              ;;(reportUnknownArgumentType . "none")
                              ;;(reportMissingTypeArgument . "none")
                              ))
                          (:ansible . ((ansible . ((path . "ansible")
                                                   (useFullyQualifiedCollectionNames . t)))
                                       (validation . ((enabled . t)
                                                      (lint . ((enabled . t)
                                                               (path . "ansible-lint")))))
                                       (completion . ((provideRedirectModules . t)
                                                      (provideModuleOptionAliases . t)))))))))

;; ==========================================
;; 5. GO
;; ==========================================

;; Help eglot find the Go module root (nearest go.mod)
(require 'project)

(defun project-find-go-module (dir)
  (when-let ((root (locate-dominating-file dir "go.mod")))
    (cons 'go-module root)))

(cl-defmethod project-root ((project (head go-module)))
  (cdr project))

(add-hook 'project-find-functions #'project-find-go-module)

;; Organize imports before save in Go buffers
(defun my/go-organize-imports-before-save ()
  (add-hook 'before-save-hook
            (lambda ()
              (call-interactively 'eglot-code-action-organize-imports))
            nil t))
(add-hook 'go-ts-mode-hook #'my/go-organize-imports-before-save)

;; ==========================================
;; 6. PYTHON
;; ==========================================

(defun my/python-uv-venv-activate ()
  "Activate .venv if created by uv in project root."
  (interactive)
  (when-let ((project (project-current)))
    (let ((venv-path (expand-file-name ".venv" (project-root project))))
      (when (file-directory-p venv-path)
        (pyvenv-activate venv-path)
        ;; Check if eglot is loaded and a server is actually running
        (when (and (fboundp 'eglot-current-server) 
                   (eglot-current-server))
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

(use-package pyvenv
  :hook (python-mode . my/python-uv-venv-activate)
  :bind (:map python-mode-map
              ("C-c C-c" . my/python-run)
              ("C-c C-t" . my/python-test-run)))

(use-package dape
  :preface (setq dape-buffer-window-arrangement 'right)
  :config
  (defun my/dape-python-command ()
    "Return .venv python if in project, else python3."
    (let ((venv-python
           (expand-file-name
            ".venv/bin/python"
            (or (when-let ((project (project-current)))
                  (project-root project))
                default-directory))))
      (if (file-executable-p venv-python) venv-python "python3")))

  ;; Add a brand new, bulletproof configuration specifically for uv projects 
  ;; instead of mutating the built-in lists, which can fail silently.
  (add-to-list 'dape-configs
               `(uv-python
                 modes (python-mode python-ts-mode)
                 command my/dape-python-command
                 command-args ("-m" "debugpy.adapter" "--host" "127.0.0.1" "--port" :autoport)
                 port :autoport
                 :request "launch"
                 :type "python"
                 :cwd dape-cwd
                 :program dape-buffer-default))

  (add-to-list 'dape-configs
               `(uv-pytest
                 modes (python-mode python-ts-mode)
                 command my/dape-python-command
                 command-args ("-m" "debugpy.adapter" "--host" "127.0.0.1" "--port" :autoport)
                 port :autoport
                 :request "launch"
                 :type "python"
                 :module "pytest"
                 :cwd dape-cwd
                 :args my/dape-pytest-args))

  (defun my/dape-pytest-args ()
    "Return pytest args for the test function at point."
    (let* ((file (file-relative-name (buffer-file-name)
                                     (funcall dape-cwd-fn)))
           (func (save-excursion
                   (end-of-line)
                   (when (re-search-backward "^\\s-*def \\(test[a-zA-Z0-9_]*\\)" nil t)
                     (match-string-no-properties 1))))
           (node (if func (format "%s::%s" file func) file)))
      (vector "-x" "-s" "--no-header" node))))

(with-eval-after-load 'python
  (define-key python-mode-map    (kbd "C-c C-d") #'dape)
  (define-key python-mode-map    (kbd "C-c b")   #'dape-breakpoint-toggle)
  (define-key python-ts-mode-map (kbd "C-c C-d") #'dape)
  (define-key python-ts-mode-map (kbd "C-c b")   #'dape-breakpoint-toggle))

;; ==========================================
;; 7. SHELL & GIT
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
;; 8. KEYBINDINGS & HOUSEKEEPING
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
   '("dd4582661a1c6b865a33b89312c97a13a3885dc95992e2e5fc57456b4c545176"
     "be0d9f0e72a4ebc4a59c382168921b082b4dc15844bdaf1353c08157806b3321"
     "3061706fa92759264751c64950df09b285e3a2d3a9db771e99bcbb2f9b470037"
     "921f165deb8030167d44eaa82e85fcef0254b212439b550a9b6c924f281b5695"
     "b5fd9c7429d52190235f2383e47d340d7ff769f141cd8f9e7a4629a81abc6b19"
     "720838034f1dd3b3da66f6bd4d053ee67c93a747b219d1c546c41c4e425daf93"
     "77fff78cc13a2ff41ad0a8ba2f09e8efd3c7e16be20725606c095f9a19c24d3d"
     "5c7720c63b729140ed88cf35413f36c728ab7c70f8cd8422d9ee1cedeb618de5"
     "0325a6b5eea7e5febae709dab35ec8648908af12cf2d2b569bedc8da0a3a81c1"
     default))
 '(package-selected-packages
   '(ansible ansible-doc apheleia auto-dark consult corfu dape
             doom-themes exec-path-from-shell fzf magit marginalia
             orderless pyvenv vertico)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
