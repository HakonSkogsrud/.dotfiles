;; --- 1. Package Management & Installation ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Automatically install all required packages
(setq my-packages '(adwaita-dark-theme kaolin-themes swiper treemacs vertico orderless vterm yaml-mode jinja2-mode ansible ansible-doc magit rg company flycheck python-pytest python-isort))
(dolist (pkg my-packages)
  (unless (package-installed-p pkg)
    (package-refresh-contents)
    (package-install pkg)))


(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(global-set-key (kbd "C-f") 'swiper)  ; Ctrl-F now opens a list of all matches

;; --- Magit (Git Interface) ---
(global-set-key (kbd "C-x g") 'magit-status)  ; Main Git status buffer
(global-set-key (kbd "C-x M-g") 'magit-dispatch)  ; Magit command menu

;; --- Ripgrep (Fast Search) ---
(require 'rg)
(rg-enable-default-bindings)  ; Enables C-c s prefix for rg commands
(global-set-key (kbd "C-S-f") 'rg-project)  ; Search in project with ripgrep

;; --- 2. GNOME Look & Feel ---
(setq inhibit-startup-message t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(setq frame-resize-pixelwise t)
(setq frame-title-format '("")) ; Clean title bar

(set-face-attribute 'default nil :font "Hack Nerd Font-12")
(load-theme 'modus-operandi-tinted t)
(setq ring-bell-function 'ignore)

;; Make Treemacs use the same font size as editor
(with-eval-after-load 'treemacs
  (set-face-attribute 'treemacs-root-face nil :height 1.0)
  (set-face-attribute 'treemacs-git-unmodified-face nil :height 1.0)
  (set-face-attribute 'treemacs-directory-face nil :height 1.0)
  (set-face-attribute 'treemacs-file-face nil :height 1.0))

;; --- 3. Standard Behavior (CUA & Search) ---
(cua-mode t)                 ; Standard Ctrl-C, Ctrl-V, Ctrl-X, Ctrl-Z
(vertico-mode t)             ; Clean vertical search list
(setq completion-styles '(orderless basic)) ; Fuzzy search logic

;; --- 4. Navigation Shortcuts (GNOME Style) ---
(global-set-key (kbd "C-p") 'project-find-file)          ; Search project (VS Code style)
(global-set-key (kbd "C-w") 'kill-current-buffer)       ; Close file
(global-set-key (kbd "<C-tab>") 'next-buffer)           ; Next tab
(global-set-key (kbd "<C-S-iso-lefttab>") 'previous-buffer) ; Previous tab
(global-set-key (kbd "<f8>") 'treemacs)                 ; File tree sidebar
(windmove-default-keybindings 'meta)                    ; Alt + Arrows move between splits

;; --- 5. Terminal (vterm) with Fish ---
(require 'vterm)
(setq vterm-shell (or (executable-find "fish") (executable-find "bash")))

(defun my/toggle-terminal ()
  "Toggle vterm at the bottom of the screen."
  (interactive)
  (let ((vterm-buffer (get-buffer "*vterm*")))
    (if (and vterm-buffer (get-buffer-window vterm-buffer))
        (if (eq (current-buffer) vterm-buffer)
            (delete-window (get-buffer-window vterm-buffer))
          (select-window (get-buffer-window vterm-buffer)))
      (progn
        (split-window-below -12)
        (other-window 1)
        (if (and vterm-buffer (buffer-live-p vterm-buffer))
            (switch-to-buffer vterm-buffer)
          (vterm))))))

(global-set-key (kbd "<f12>") 'my/toggle-terminal)
(global-set-key (kbd "C-S-W") 'kill-current-buffer) ; Kill terminal process

(with-eval-after-load 'vterm
  (define-key vterm-mode-map (kbd "<f12>") nil)
  (define-key vterm-mode-map (kbd "C-S-W") nil)
  (define-key vterm-mode-map (kbd "M-<up>") nil)
  (define-key vterm-mode-map (kbd "M-<down>") nil)
  (define-key vterm-mode-map (kbd "M-<left>") nil)
  (define-key vterm-mode-map (kbd "M-<right>") nil))


;; --- Programming & Syntax Highlighting ---

;; 1. Python, Shell & YAML (Tree-Sitter)
;; Emacs 29+ remapping. Ensure you ran: sudo dnf install tree-sitter-yaml
(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (yaml-mode . yaml-ts-mode)
        (bash-mode . bash-ts-mode)))

;; 2. Enable Global Font Lock (Critical for syntax highlighting)
(global-font-lock-mode t)

;; --- Python Development Setup ---

;; Company-mode (Auto-completion)
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(setq company-idle-delay 0.2)
(setq company-minimum-prefix-length 1)
(global-set-key (kbd "C-SPC") 'company-complete)

;; Eglot (LSP client) - Auto-enable for Python
(require 'eglot)
(add-hook 'python-ts-mode-hook 'eglot-ensure)
(add-hook 'python-mode-hook 'eglot-ensure)

;; Flycheck (Real-time syntax checking)
(require 'flycheck)
(add-hook 'python-ts-mode-hook 'flycheck-mode)
(add-hook 'python-mode-hook 'flycheck-mode)
(global-set-key (kbd "C-c ! l") 'flycheck-list-errors)

;; Python-pytest (Test runner)
(require 'python-pytest)
(global-set-key (kbd "C-c t t") 'python-pytest-dispatch)  ; Test menu
(global-set-key (kbd "C-c t f") 'python-pytest-file)       ; Test current file
(global-set-key (kbd "C-c t a") 'python-pytest)            ; Run all tests

;; Python-isort (Import sorting)
(require 'python-isort)
(add-hook 'python-ts-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'python-isort-buffer nil t)))

;; Ruff formatter (Format on save)
(defun my/ruff-format-buffer ()
  "Format the current buffer using ruff."
  (interactive)
  (when (and (executable-find "ruff")
             (or (eq major-mode 'python-ts-mode)
                 (eq major-mode 'python-mode)))
    (let ((line (line-number-at-pos))
          (col (current-column)))
      (shell-command-on-region
       (point-min) (point-max)
       "ruff format --stdin-filename=file.py -"
       (current-buffer) t
       "*ruff-error*" t)
      (goto-char (point-min))
      (forward-line (1- line))
      (move-to-column col))))

(add-hook 'python-ts-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'my/ruff-format-buffer nil t)))
(global-set-key (kbd "C-c f") 'my/ruff-format-buffer)

;; 3. Ansible Integration
;; We need to ensure ansible-mode activates even when using yaml-ts-mode
(defun my/enable-ansible ()
  "Enable Ansible minor mode."
  (ansible 1))

(add-hook 'yaml-mode-hook 'my/enable-ansible)
(add-hook 'yaml-ts-mode-hook 'my/enable-ansible)

;; Force specific folders/files to be treated as Ansible
;; This is crucial. If a file is just "samba.yml", Emacs just sees YAML.
;; We tell it: "If it's in a 'playbook' or 'roles' folder, it's Ansible."
(add-to-list 'auto-mode-alist '("/playbooks/.*\\.yml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("/roles/.*\\.yml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("/group_vars/.*" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("/host_vars/.*" . yaml-ts-mode))

;; 4. Jinja2 & Templates
(require 'jinja2-mode)
(add-to-list 'auto-mode-alist '("\\.j2\\'" . jinja2-mode))
(add-to-list 'auto-mode-alist '("\\.sh\\.j2\\'" . jinja2-mode))
(add-to-list 'auto-mode-alist '("\\.yml\\.j2\\'" . jinja2-mode))

;; 5. Indentation Guides
(unless (package-installed-p 'highlight-indent-guides)
  (package-install 'highlight-indent-guides))
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(add-hook 'yaml-ts-mode-hook 'highlight-indent-guides-mode) ;; Force it on Tree-sitter YAML
(setq highlight-indent-guides-method 'character)


;; --- 6. Keep init.el clean ---
;; This moves the "custom-set-variables" block to a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))


;; --- PGTK GNOME Integration ---
(add-to-list 'default-frame-alist '(undecorated . nil)) ;; Keep decorations but...
(setq frame-resize-pixelwise t)      ; Prevents white gaps at the bottom
(setq window-divider-default-bottom-width 0)
(setq window-divider-default-right-width 0)
(window-divider-mode 1)              ; Removes ugly internal borders
