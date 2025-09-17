;; Change alt key in MacOS to meta key.
(setq mac-command-modifier 'meta)

;; Basic UI cleanup
(setq package-check-signature nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(global-hl-line-mode 1)

;; font (adjust to taste)
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font Mono" :height 130)
(set-frame-font "JetBrainsMono Nerd Font Mono-13" t t)

;; Package system setup (use-package)
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Theme
(use-package doom-themes
  :config
  (load-theme 'doom-one t))

;; Modeline
(use-package powerline
  :ensure t
  :config
  (powerline-default-theme)
  
  ;; Show full file path in the mode line instead of just buffer name
  (setq-default
   mode-line-buffer-identification
   '(:eval (if buffer-file-name
               (abbreviate-file-name buffer-file-name)
             "%b"))))

(use-package all-the-icons)

(set-face-attribute 'line-number nil
  :foreground "#7f848e")

(use-package which-key
  :init (which-key-mode))

;; Completion UI
(use-package vertico
  :init (vertico-mode))

;; Better M-x and file finding
(use-package consult)
(use-package marginalia
  :init (marginalia-mode))

;; Project Management
(use-package projectile
  :init
  (projectile-mode +1)
  (setq projectile-project-search-path '("~/projects/" "~/org/"))
  (setq projectile-switch-project-action #'projectile-dired)
  :bind-keymap ("C-c p" . projectile-command-map))

;; Treemacs with projectile & icons
(use-package treemacs
  :ensure t
  :defer t
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-c t t"   . treemacs)
        ("C-c t d"   . treemacs-delete-other-windows))
  :config
  (setq treemacs-is-never-other-window t))

(use-package treemacs-projectile
  :after (treemacs projectile)
  :ensure t)

(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable))

(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)


;; Syntax checking
(use-package flycheck
  :init (global-flycheck-mode))

;; Git integration
(use-package magit
  :bind ("C-x g" . magit-status))

;; Make sure exec-path is correct (important for shell integration)
(use-package exec-path-from-shell
  :config
  (exec-path-from-shell-initialize))

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file))

(global-set-key (kbd "<f5>") #'reload-init-file)

(use-package pdf-tools
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-view-midnight-colors '("#ffffff" . "#000000")))

(setq pdf-annot-activate-created-annotations t)

;; ORG-MODE

(use-package org
  :config
  (add-to-list 'org-modules 'org-habit)
  (require 'org-habit)
  (setq org-log-done t
        org-agenda-files '("~/org/tasks.org")
        org-deadline-warning-days 3
        org-habit-show-habits-only-for-today nil))

(use-package alert
  :commands (alert)
  :config
  (setq alert-default-style 'osx-notifier))

(use-package org-modern
  :hook (org-mode . org-modern-mode))

(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  :init
  (org-roam-db-autosync-mode))

;; Quickly preview LaTex with ctrl + ; 
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-;") #'org-latex-preview))

(add-hook 'org-mode-hook #'org-latex-preview)

;; Org clock, tasks, log.

(setq org-todo-keywords
      '((sequence "TODO" "IN-PROGRESS" "WAITING" "|" "DONE" "CANCELLED")))

(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)

(setq org-log-into-drawer t)
(setq org-clock-into-drawer t) 
(setq org-log-state-notes-insert-after-drawers t)
(setq org-log-repeat 'note)  ;; For repeated tasks, if you use those
;; Log a timestamp when you mark a task DONE
(setq org-log-done 'time)

;; Log timestamps on every TODO state change, not just DONE
(setq org-log-todo 'time)


(setq org-todo-state-tags-triggers
      (quote (("DONE" ("DONE" . t))
              ("CANCELLED" ("CANCELLED" . t))
              ("TODO" ("TODO" . t))
              ("IN-PROGRESS" ("IN-PROGRESS" . t))
              ("WAITING" ("WAITING" . t)))))


(setq org-structure-template-alist
      '(("py" . "src python")
        ("c"  . "src C")
        ("cc" . "src C++")
        ("go" . "src go")
        ("rs" . "src rust")
        ("hs" . "src haskell")
        ("sw" . "src swift")
        ("sh" . "src shell")))

(use-package ob-go
  :ensure t)

(use-package ob-rust
  :ensure t)

(use-package jupyter
  :ensure t)

(defun my/org-insert-jupyter-python-block ()
  "Insert a jupyter-python src block with default header args."
  (interactive)
  (insert "#+begin_src jupyter-python :session py :exports both\n")
  (save-excursion (insert "\n#+end_src")))


(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (jupyter . t)
   (C . t)
   (emacs-lisp . t)       ;; optional, usually enabled by default
   (haskell . t)
   (go . t)
   (rust . t)
   (shell . t)))          ;; useful for shell scripts, optional


;;(setq org-babel-python-command "python3")

(defun my/org-refresh-inline-images-on-execute (&rest _)
  "Refresh inline images after executing org source blocks."
  (when (derived-mode-p 'org-mode)
    (org-redisplay-inline-images)))
(advice-add 'org-babel-execute-src-block :after #'my/org-refresh-inline-images-on-execute)

;; Disable unnecessary prompt.
(setq org-confirm-babel-evaluate nil)



;; LSPs

(use-package lsp-mode
  :commands lsp
  :hook ((python-mode . lsp)
         (c-mode . lsp)
         (c++-mode . lsp)
         (go-mode . lsp)
         (rust-mode . lsp)
         (haskell-mode . lsp)
         (swift-mode . lsp))
  :init
  (setq lsp-keymap-prefix "C-c l"))

(use-package lsp-ui
  :commands lsp-ui-mode)

(use-package company
  :init (global-company-mode))

;; TERMINAL

(use-package vterm
  :commands vterm
  :config
  (setq vterm-shell "/bin/zsh")) ;; or /opt/homebrew/bin/fish, etc.


;; EVIL

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; LEADER KEY

(use-package general
  :after evil
  :config
  (general-evil-setup t)
  ;; Leader key: SPC
  (general-create-definer my/leader-keys
    :states '(normal visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  (my/leader-keys
    "o"   '(nil :which-key "org")
    "o a"  '(org-agenda :which-key "Agenda")
    "o c"  '(org-capture :which-key "Capture")
    "o t"  '(org-todo :which-key "Toggle TODO")
    "o e"  '(org-export-dispatch :which-key "Export menu")
    "o i"  '(org-insert-heading-respect-content :which-key "Insert heading")
    "o I"  '(org-insert-subheading :which-key "Insert subheading")
    "o x"  '(org-toggle-checkbox :which-key "Toggle checkbox")
    "o ."  '(org-time-stamp :which-key "Insert timestamp")
    "o s n" '(org-babel-next-src-block :which-key "Next src block")
    "o s p" '(org-babel-previous-src-block :which-key "Prev src block")
    "o s e" '(org-edit-special :which-key "Edit source block")
    "o s t" '(org-babel-tangle :which-key "Tangle blocks")
    "o s r" '(org-babel-remove-result :which-key "Remove results")
    "o s h" '(org-shiftleft :which-key "Outdent heading")
    "o s l" '(org-shiftright :which-key "Indent heading")
    "o s u" '(org-shiftup :which-key "Move up")
    "o s d" '(org-shiftdown :which-key "Move down")
    "o m"   '(org-ctrl-c-ctrl-c :which-key "Update metadata")
    "o n"    '(nil :which-key "Notes")
    "o n f"  '(org-roam-node-find :which-key "Find note")
    "o n i"  '(org-roam-node-insert :which-key "Insert link to note")
    "o n c"  '(org-roam-capture :which-key "Capture note")
    "o n g"  '(org-roam-graph :which-key "Roam graph")
    "o C"  '(org-clock-in :which-key "Clock in")
    "o c"  '(org-clock-out :which-key "Clock out")
    "o R"  '(org-clock-report :which-key "Clock report")
    "o d"  '(org-deadline :which-key "Set deadline")
    "o s"  '(org-schedule :which-key "Schedule task")

    "o s" '(nil :which-key "org source block")
    "o s j" '(my/org-insert-jupyter-python-block :which-key "Insert Jupyter block")
    "o s c" '(org-babel-execute-src-block :which-key "Compile source block")
    "o l p" '(org-latex-preview :which-key "Preview LaTex in current line")

    "SPC" '(vterm-other-window :which-key "Terminal on other window.")

    "t n" '(tab-new :which-key "Tab: new.")
    "t x" '(tab-close :which-key "Tab: close.")
    "t s" '(tab-switch :which-key "Tab: switch by name.")
    "t e" '(tab-next :which-key "Tab: next.")
    "t r" '(tab-previous :which-key "Tab: previous.")
   
    "t m" '(treemacs :which-key "Treemacs.")

    "w r" '(split-window-right :which-key "Window: split right.")
    "w b" '(split-window-below :which-key "Window: split below.")
    "w x" '(delete-window :which-key "Window: kill current.")
    "w X" '(delete-other-windows :which-key "Window: kill others.")
    "w o" '(other-window :which-key "Window: other.")

    "w h" '(windmove-left :which-key "Window left")
    "w l" '(windmove-right :which-key "Window right")
    "w k" '(windmove-up :which-key "Window up")
    "w j" '(windmove-down :which-key "Window down")

    "b l" '(list-buffers :which-key "Buffers: list.")
    "b s" '(switch-to-buffer :which-key "Buffers: switch to.")
    "b t" '(switch-to-buffer-other-tab :which-key "Buffers: switch to tab.")

    "f s"  '(find-file :which-key "Find file")
    "g m"  '(magit-status :which-key "Magit")

    "p"   '(projectile-command-map :which-key "Projectile")

    "e l" '(eval-last-sexp :which-key "Eval: Last sexp.")

    "?" '(which-key-show-top-level :which-key "which-key help")
    )
 )

(when (fboundp 'windmove-default-keybindings)
  (windmove-default-keybindings 'control))  ;; ctrl + arrows


(setq org-todo-state-tags-triggers nil)
