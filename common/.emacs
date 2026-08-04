;; ==========================================
;; 1. PERFORMANCE & FOUNDATION
;; ==========================================

(setq gc-cons-threshold 100000000   ; 100MB GC for LSP performance
      read-process-output-max (* 1024 1024) ; 1MB chunks
      eglot-events-buffer-size 0)           ; Disable LSP logging for speed

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Refresh package archives if stale (older than 1 day)
(unless (and package-archive-contents
             (let ((archive-time (nth 5 (file-attributes
                                         (expand-file-name "archives/melpa/archive-contents"
                                                           package-user-dir)))))
               (and archive-time
                    (< (float-time (time-subtract nil archive-time)) 86400))))
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t)

;; Locate Fish before exec-path-from-shell tries to use it
(when-let ((fish-path (executable-find "fish")))
  (setq shell-file-name fish-path
        explicit-shell-file-name fish-path))

(use-package exec-path-from-shell
  :if (memq window-system '(mac ns x pgtk))
  :config
  (dolist (var '("PATH" "GOPATH" "LC_ALL"))
    (exec-path-from-shell-copy-env var)))

;; NixOS / nix-shell / direnv integration
(use-package envrc
  :hook (after-init . envrc-global-mode))

;; ==========================================
;; 2. UI & UX
;; ==========================================

(use-package doom-themes)

(setq custom-safe-themes t)

(use-package auto-dark
  :init
  (setq auto-dark-themes           '((doom-badger) (modus-operandi))
        auto-dark-detection-method 'dbus)
  :config (auto-dark-mode t))

(cua-mode 1)
(add-to-list 'default-frame-alist
             `(font . ,(format "ComicShannsMono Nerd Font-%d"
                               (if (eq system-type 'darwin) 15 13))))

(setq select-active-regions nil
      mouse-drag-copy-region nil)

(setq inhibit-startup-screen t
      initial-scratch-message nil
      sentence-end-double-space nil
      ring-bell-function 'ignore
      scroll-conservatively 101
      scroll-margin 3
      fast-but-imprecise-scrolling nil
      mouse-wheel-scroll-amount '(2 ((shift) . 5))
      mouse-wheel-progressive-speed nil)

(setq-default indent-tabs-mode nil
              tab-width 4)

(defun my/underscore-is-word-constituent ()
  (modify-syntax-entry ?_ "w"))
(add-hook 'after-change-major-mode-hook #'my/underscore-is-word-constituent)

;; macOS: AltGr (arrives as right Cmd due to OS swap) — Norwegian keyboard bindings
(when (eq system-type 'darwin)
  (setq ns-right-command-modifier 'super)
  (global-set-key (kbd "s-7") (lambda () (interactive) (insert "{")))
  (global-set-key (kbd "s-8") (lambda () (interactive) (insert "[")))
  (global-set-key (kbd "s-9") (lambda () (interactive) (insert "]")))
  (global-set-key (kbd "s-0") (lambda () (interactive) (insert "}")))
  (global-set-key (kbd "§") (lambda () (interactive) (insert "|"))))

(tool-bar-mode -1)
(menu-bar-mode -1)
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

(defun my/find-file-home ()
  "Search for files under home directory with fd."
  (interactive)
  (consult-fd "~/"))

(use-package consult
  :bind (("C-c f" . project-find-file)
         ("C-c h" . my/find-file-home))
  :config
  (setq consult-fd-args '((if (executable-find "fdfind") "fdfind" "fd")
                          "--full-path --color=never --hidden --exclude .git")))

(use-package which-key
  :init (which-key-mode)
  :custom
  (which-key-idle-delay 0.4)
  (which-key-sort-order 'which-key-key-order-alpha))

(use-package treemacs
  :preface
  (defun my/treemacs-visible-p ()
    (seq-some (lambda (window)
                (with-current-buffer (window-buffer window)
                  (derived-mode-p 'treemacs-mode)))
              (window-list nil 'no-minibuffer)))
  (defun my/treemacs-toggle-current-project ()
    (interactive)
    (if (my/treemacs-visible-p)
        (treemacs)
      (treemacs-add-and-display-current-project-exclusively)))
  :bind (("C-c V" . treemacs)
         ("C-c v" . my/treemacs-toggle-current-project))
  :custom
  (treemacs-width 32)
  (treemacs-is-never-other-window t)
  :config
  (set-face-attribute 'treemacs-root-face nil
                      :height 0.9
                      :weight 'normal
                      :underline nil)
  (add-hook 'treemacs-mode-hook
            (lambda ()
              (face-remap-add-relative 'default :height 0.9))))

;; ==========================================
;; 4. TREESITTER & LSP
;; ==========================================

(setq treesit-font-lock-level 4)

(setq treesit-language-source-alist
      '((yaml   . ("https://github.com/ikatyang/tree-sitter-yaml"))
        (python . ("https://github.com/tree-sitter/tree-sitter-python"))
        (bash   . ("https://github.com/tree-sitter/tree-sitter-bash"))
        (json   . ("https://github.com/tree-sitter/tree-sitter-json"))
        (nix    . ("https://github.com/nix-community/tree-sitter-nix"))))

(dolist (lang (mapcar #'car treesit-language-source-alist))
  (unless (treesit-language-available-p lang)
    (treesit-install-language-grammar lang)))

(setq major-mode-remap-alist nil)
(dolist (entry '((python python-mode python-ts-mode)
                 (go     go-mode     go-ts-mode)
                 (yaml   yaml-mode   yaml-ts-mode)
                 (bash   bash-mode   bash-ts-mode)
                 (json   json-mode   json-ts-mode)
                 (nix    nix-mode    nix-ts-mode)))
  (when (treesit-language-available-p (nth 0 entry))
    (add-to-list 'major-mode-remap-alist
                 (cons (nth 1 entry) (nth 2 entry)))))

(add-to-list 'auto-mode-alist
             `("\\.ya?ml\\'" . ,(if (treesit-language-available-p 'yaml)
                                     'yaml-ts-mode
                                   'yaml-mode)))

(use-package nix-ts-mode
  :mode "\\.nix\\'")

;; Recognize .j2 files by the extension before it: foo.yml.j2 → yaml-ts-mode, etc.
;; The (nil t) form strips .j2 and re-checks auto-mode-alist on the remainder.
(add-to-list 'auto-mode-alist '("\\.j2\\'" nil t))

(use-package eglot
  :hook ((python-mode     . my/python-eglot-ensure)
         (python-ts-mode  . my/python-eglot-ensure)
         (go-ts-mode      . eglot-ensure)
         (ansible-ts-mode . eglot-ensure)
         (bash-ts-mode    . eglot-ensure)
         (nix-ts-mode     . eglot-ensure))
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)
              ("C-c a" . eglot-code-actions)
              ("C-c i" . eglot-inlay-hints-mode)
              ("M-."   . xref-find-definitions)
              ("M-?"   . xref-find-references))
  :config
  (add-hook 'eglot-managed-mode-hook
            (lambda () (eglot-inlay-hints-mode -1)))
  (add-to-list 'eglot-server-programs
               '(ansible-ts-mode . ("ansible-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("basedpyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(go-ts-mode . ("gopls")))
  (add-to-list 'eglot-server-programs
               '(nix-ts-mode . ("nixd"))))

(use-package apheleia
  :config (apheleia-global-mode +1))

;; ==========================================
;; 5. ANSIBLE / YAML
;; ==========================================
;; ansible-ts-mode derives from yaml-ts-mode so eglot can target it separately.

(define-derived-mode ansible-ts-mode yaml-ts-mode "Ansible"
  "Major mode for Ansible YAML files.")

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
                '(:basedpyright.analysis
                  (:typeCheckingMode "standard"
                   :diagnosticSeverityOverrides
                   (:reportAny "none"
                    :reportUnusedCallResult "none"
                    :reportUnknownVariableType "none"))
                  :ansible
                  (:ansible
                   (:path "ansible"
                    :useFullyQualifiedCollectionNames t)
                   :validation
                   (:enabled t
                    :lint (:enabled t
                           :path "ansible-lint"))
                   :completion
                   (:provideRedirectModules t
                    :provideModuleOptionAliases t)))))


;; ==========================================
;; 6. PYTHON
;; ==========================================

(defun my/python-project-find (directory)
  "Return the nearest pyproject.toml project containing DIRECTORY."
  ;; Prefer a nested Python project over an enclosing Git repository.
  (when-let ((root (locate-dominating-file directory "pyproject.toml")))
    (cons 'transient root)))

(defun my/python-venv ()
  "Return a local .venv, falling back to the current project root."
  ;; A venv beside the file is more specific than one at the project root.
  (let* ((local-directory (file-name-directory
                           (or (buffer-file-name) default-directory)))
         (local-venv (expand-file-name ".venv" local-directory)))
    (if (file-directory-p local-venv)
        local-venv
      (when-let* ((project (project-current))
                  (project-venv (expand-file-name ".venv"
                                                  (project-root project)))
                  ((file-directory-p project-venv)))
        project-venv))))

(defun my/python-eglot-ensure ()
  "Start Eglot using the current project's uv environment."
  ;; Eglot is lazy-loaded, so its configuration variables may not exist yet.
  (require 'eglot)
  (add-hook 'project-find-functions #'my/python-project-find nil t)
  (let* ((venv (my/python-venv))
         (venv-python (and venv (expand-file-name "bin/python" venv))))
    (when (and venv-python (file-executable-p venv-python))
      ;; Keep the selected environment local to this buffer and LSP process.
      (setq-local process-environment (copy-sequence process-environment))
      (setenv "VIRTUAL_ENV" venv)
      (setenv "PATH" (concat (expand-file-name "bin" venv)
                              path-separator
                              (getenv "PATH")))
      (setq-local eglot-workspace-configuration
                  (plist-put (copy-sequence eglot-workspace-configuration)
                             :python `(:pythonPath ,venv-python))))
    (eglot-ensure)))

(defun my/python-run ()
  "Run current file via uv or python3."
  (interactive)
  (when (buffer-modified-p) (save-buffer))
  (if (file-directory-p ".venv")
      (compile (format "uv run %S" (buffer-file-name)))
    (compile (format "python3 %S" (buffer-file-name)))))

(defun my/python-test-run ()
  "Run pytest via uv or pytest."
  (interactive)
  (when (buffer-modified-p) (save-buffer))
  (let ((cmd (if (file-directory-p ".venv") "uv run pytest" "pytest")))
    (compile cmd)))

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
  (define-key python-mode-map    (kbd "C-c C-c") #'my/python-run)
  (define-key python-mode-map    (kbd "C-c C-t") #'my/python-test-run)
  (define-key python-mode-map    (kbd "C-c C-d") #'dape)
  (define-key python-mode-map    (kbd "C-c b")   #'dape-breakpoint-toggle)
  (define-key python-ts-mode-map (kbd "C-c C-c") #'my/python-run)
  (define-key python-ts-mode-map (kbd "C-c C-t") #'my/python-test-run)
  (define-key python-ts-mode-map (kbd "C-c C-d") #'dape)
  (define-key python-ts-mode-map (kbd "C-c b")   #'dape-breakpoint-toggle))

;; ==========================================
;; 7. SHELL & GIT
;; ==========================================

(defun my/toggle-shell ()
  "Toggle a shell at project root."
  (interactive)
  (let ((shell-buf (get-buffer "*shell*")))
    (if (and shell-buf (get-buffer-window shell-buf))
        (delete-window (get-buffer-window shell-buf))
      (project-shell))))

(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)

(with-eval-after-load 'comint
  (define-key comint-mode-map (kbd "<up>") #'comint-previous-input)
  (define-key comint-mode-map (kbd "<down>") #'comint-next-input))

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
(global-set-key (kbd "C-c k") 'where-is)
(global-set-key (kbd "C-c s") (lambda () (interactive)
                                (project-find-regexp (thing-at-point 'symbol t))))

(global-set-key (kbd "C-/") 'undo-only)
(global-set-key (kbd "M-/") 'undo-redo)

(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
      select-enable-clipboard t)


(defun my-nixos-rebuild ()
  "Run nixos-rebuild switch for the local flake configuration."
  (interactive)
  (async-shell-command "sudo nixos-rebuild switch --flake ~/.dotfiles/nixos#nixos"))

;; Binds the function to 'C-c n' (Control-c followed by n)
(global-set-key (kbd "C-c n") 'my-nixos-rebuild)
