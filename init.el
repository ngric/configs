;;==== Package System Setup ======

(setq straight-use-package-by-default t)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

;;==== Evil ======

(use-package undo-tree
  :diminish undo-tree-mode
  :after evil
  :init
  (global-undo-tree-mode 1))

(use-package evil
  :init
  (setq evil-want-C-u-scroll t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-w-delete nil)
  (setq evil-want-C-w-in-emacs-state t)
  (setq evil-want-fine-undo t)
  (setq evil-want-minibuffer t)
  (setq evil-search-module 'evil-search)
  (setq evil-symbol-word-search t)
  :config
  (evil-mode 1)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-set-undo-system 'undo-tree))

;; Remap the universal argument (prefix) key, since we gave C-u to evil
(global-set-key (kbd "C-x C-u") 'universal-argument)

;; Since we're using evil in the minibuffer, and I'd like to press C-g less
;; make esc send an esc when already in normal mode
(add-hook 'minibuffer-setup-hook
          (lambda ()
            (evil-local-set-key 'normal (kbd "<escape>") 'abort-recursive-edit)))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-nerd-commenter
  :config
  (global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Number increment/decrement
(use-package evil-numbers)
(define-key evil-normal-state-map (kbd "C-c a") 'evil-numbers/inc-at-pt)
(define-key evil-normal-state-map (kbd "C-c x") 'evil-numbers/dec-at-pt)

;; Stop stupid tab stealing behavior
;; (with-eval-after-load 'evil-maps (define-key evil-motion-state-map (kbd "TAB") nil))

;;==== Org-mode ======

(setq org-startup-with-inline-images t)

(setq org-modules '(ol-doi ol-w3m ol-bbdb ol-bibtex ol-docview ol-gnus ol-info ol-irc ol-mhe ol-rmail ol-eww org-habit))

;; So that I can use pandoc to export org files to pdf
(use-package ox-pandoc
  :straight (ox-pandoc :type git :host github :repo "emacsorphanage/ox-pandoc")
  :defer t)
(require 'ox-pandoc)
(setq org-pandoc-options '((pdf-engine . "xelatex")))

(use-package ob-rust)
(use-package ob-go)

(setq ispell-dictionary "en")
(defun kalea/org-mode-setup ()
  (org-indent-mode)
  (flyspell-mode 1)
  (visual-line-mode 1))

(use-package org
  :demand t
  :hook (org-mode . kalea/org-mode-setup)
  :config 
  (setq org-agenda-files (list "~/org/todo.org" "~/org/public/inbox.org"))
  (setq org-extend-today-until 1)
  (setq org-ellipsis "⏷"))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (shell . t)
   (sqlite . t)
   (rust . t)
   (go . t)
   (python . t)))

(setq org-confirm-babel-evaluate nil)

(require 'org-tempo)
(dolist (temp '(("el" . "src elisp")
                ("ru" . "src rust")
                ("sh" . "src bash")
                ("go" . "src go")
                ("py" . "src python :results output")))
  (add-to-list 'org-structure-template-alist temp))

;; (defun directory-files-sorted-by-name-descending (directory)
;;   "Return a list of DIRECTORY's file paths, sorted by name in descending order."
;;   (let ((all-files (directory-files directory t "\\`[^.].*\\.org\\'")))
;;     (reverse (sort (copy-sequence all-files) 'string<))))

;; (defun update-org-agenda-files ()
;;   (let* ((daily-dir "~/org/daily/")
;;          (all-files (directory-files daily-dir t "\\.org$"))
;;          (sorted-files (directory-files-sorted-by-name-descending daily-dir))
;;          (recent-files (seq-take sorted-files 7))
;;          ;; Keep non-daily files in `org-agenda-files'
;;          (non-daily-files (cl-set-difference org-agenda-files all-files :test 'equal)))

;;     ;; Set `org-agenda-files' to non-daily files and most recent daily files
;;     (setq org-agenda-files (append recent-files non-daily-files))))

;; (add-hook 'org-agenda-mode-hook 'update-org-agenda-files)

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; Image insertion
(use-package org-download
  ;; Drag-and-drop to `dired`
  :hook (dired-mode . org-download-enable))

;; Attempt to make src blocks handle tabs like anywhere else in emacs
(setq org-src-tab-acts-natively t)

;; Web clipping? General shit-sending?
;; As of putting this here, I really just want this for anki backlinks (not working)
(add-to-list 'load-path "~/.local/share/applications/org-protocol.desktop")
(require 'org-protocol)

;; Increase latex preview size
(setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))

;; Hide emphasis markers in org-mode files when the cursor isn't on them
(setq org-hide-emphasis-markers t)
(use-package org-appear
  :config (add-hook 'org-mode-hook 'org-appear-mode))

(use-package evil-org
  :diminish
  :demand t
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  (setf evil-org-key-theme '(return textobjects insert navigation additional shift todo calendar))
  (evil-org-agenda-set-keys))

(use-package alert
  :commands (alert)
  :config
  (setq alert-default-style 'libnotify))

(use-package org-pomodoro
  :after org
  :custom
  (org-pomodoro-manual-break t)
  (org-pomodoro-audio-player "mpv --volume=70")
  (org-pomodoro-start-sound-p t)
  (org-pomodoro-keep-killed-pomodoro-time t)
  :config
  (alert-add-rule :category "org-pomodoro"
                  :style 'libnotify
                  :persistent nil))

(defun kalea/org-pomodoro-time ()
  "Return the remaining pomodoro time"
  (if (org-pomodoro-active-p)
      (let* ((total (abs (org-pomodoro-remaining-seconds)))
             (minutes (/ total 60))
             (seconds (% (floor total) 60))
             (remaining (format "%02d:%02d" minutes seconds)))
        (cl-case org-pomodoro-state
          (:pomodoro
           (format "【 作業中: %s - %s 】" remaining org-clock-heading))
          (:short-break
           (format "【 小憩: %s 】" remaining ))
          (:long-break
           (format "【 長憩: %s 】" remaining ))
          (:overtime
           (format "【 オーバー: %s 】" remaining ))))
    ""))

(use-package org-roam
  :custom
  (org-roam-completion-everywhere t)
  (org-roam-directory "~/org")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))

;; Have roam daily entries schedule their own processing in the agenda
;; (setq org-roam-dailies-capture-templates
;;       '(("d" "default" entry "* %?" :target
;;          (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n
;; * Dailies
;; ** TODO Process %<%Y-%m-%d>
;; SCHEDULED: <%<%Y-%m-%d>>
;; ** TODO Run
;; SCHEDULED: <%<%Y-%m-%d>>
;; ** TODO Lift
;; SCHEDULED: <%<%Y-%m-%d>>
;; ** TODO Stretch/Skills
;; SCHEDULED: <%<%Y-%m-%d>>
;; ** TODO Anki
;; SCHEDULED: <%<%Y-%m-%d>>
;; \n"))))

;; Let enter open links if I'm in normal mode, and tab do completions in insert mode
(defun kalea/org-completion-at-point ()
  (interactive)
  (if (org-at-table-p)
      (org-table-next-field)
    (unless (org-tempo-complete-tag)
      (completion-at-point))))

(with-eval-after-load 'evil
  ;; Bind RET to org-open-at-point in Evil normal mode within Org mode buffers
  (evil-define-key 'normal org-mode-map (kbd "RET") #'org-open-at-point)
  ;; Bind TAB to my-org-completion-at-point in Evil insert mode within Org mode buffers
  (evil-define-key 'insert org-mode-map (kbd "TAB") #'kalea/org-completion-at-point))

;; Make all org buffers save regularly. Only necessary to keep syncing/orgzly/agenda working well together
(add-hook 'auto-save-hook 'org-save-all-org-buffers)

(global-set-key (kbd "C-c l") 'org-store-link)

;;==== Completions ======

(use-package vertico
  :config
  (setq vertico-cycle t)
  :init
  (vertico-mode))

;; Keep recent entries at top of list
(use-package savehist
  :init
  (savehist-mode))

;; Fuzzy completions - config from vertico github
(use-package orderless
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

;; add file/command/whatever information to minibuffer
(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

;;==== Keybindings ======

(use-package general
  :config
  (general-evil-setup t)
  (general-create-definer kalea/leader-keys
    :states '(normal insert visual motion emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")
  (kalea/leader-keys
    "/" '(evil-ex-nohighlight :which-key "clear search hl")
    "m" '(counsel-bookmark :which-key "bookmarks")
    "g" '(magit :which-key "magit")
    "s" '(projectile-ripgrep :which-key "search project")
    "t" '(open-eshell-in-split :which-key "eshell")
    "v" '(open-vterm-in-split :which-key "vterm")
    "r" '(dired :which-key "dired")

    "d"  '(:ignore t :which-key "dired")
    "dp" '(peep-dired :which-key "toggle previews")
    "dj" '(dired-jump :which-key "show file in dir")
    "dw" '(wdired-change-to-wdired-mode :which-key "show file in dir")

    "n"  '(:ignore t :which-key "roam")
    "nl" '(org-roam-buffer-toggle :which-key "roam buffer toggle")
    "nf" '(org-roam-node-find :which-key "find node")
    "ng" '(org-roam-graph :which-key "graph")
    "ni" '(org-roam-node-insert :which-key "insert node")
    "nc" '(org-roam-capture :which-key "org-roam-capture")
    "nj" '(org-roam-dailies-capture-today :which-key "journal")
    "nJ" '(org-roam-dailies-goto-today :which-key "journal")

    "a"  '(:ignore t :which-key "anki")
    "aa" '(anki-editor-insert-default-note :which-key "insert basic note")
    "az" '((lambda() (interactive) (anki-editor-insert-note nil "Cloze")):which-key "insert basic note")
    "aA" '(anki-editor-insert-note :which-key "insert note")
    "ac" '(anki-editor-cloze-dwim :which-key "cloze selection")
    "ap" '(anki-editor-push-new-notes :which-key "push new notes")
    "aP" '(anki-editor-push-notes :which-key "push all notes")
    "au" '(anki-editor-push-note-at-point :which-key "push this note")

    "w"  '(:ignore t :which-key "window")
    "wr" '(enter-window-management-mode :which-key "window mode")
    "ws" '(evil-window-split :which-key "split")
    "wv" '(evil-window-vsplit :which-key "vsplit")
    "wp" '(pop-current-window-to-frame :which-key "pop to frame")
    "ww" '(switch-to-visible-window-buffer :which-key "switch window")
    ;; "wq" '((lambda () (interactive) (progn (kill-buffer) (delete-frame))) :which-key "delete frame")
    ;; "wh" '(evil-window-left :which-key "left")
    ;; "wj" '(evil-window-down :which-key "down")
    ;; "wk" '(evil-window-up :which-key "up")
    ;; "wl" '(evil-window-right :which-key "right")

    "h"  '(:ignore t :which-key "help")
    "hf" '(helpful-function :which-key "function")
    "hk" '(helpful-key :which-key "key")
    "hv" '(helpful-variable :which-key "variable")

    "p"  '(projectile-command-map :which-key "projectile")

    "l"  '((lambda () (general-simulate-key "C-c l")) :which-key "lsp")
    ;; "l"  '(general-key "C-c l" :which-key "lsp")

    ;; "p"  '(:ignore t :which-key "python")
    ;; "pp" '(run-python :which-key "run python")
    ;; "pb" '((lambda () (interactive) (python-shell-send-buffer 1)) :which-key "run buffer")
    "y" '(run-python :which-key "python")

    "e"  '(:ignore t :which-key "edit")
    "ef" '(find-file :which-key "find file")
    "ec" '((lambda () (interactive) (find-file "~/.config/emacs/init.el")) :which-key "emacs")
    "er" '((lambda () (interactive) (find-file "~/.config/river/init")) :which-key "river")
    "et" '((lambda () (interactive) (find-file "~/org/todo.org")) :which-key "todo")
    "ek" '((lambda () (interactive) (find-file "~/src/qmk/keyboards/ergodox_ez/keymaps/kalea/keymap.c")) :which-key "kb")

    "b" '(counsel-switch-buffer :which-key "switch buffer")
    "B"  '(:ignore t :which-key "buffers")
    "Bk" '(kill-buffer :which-key "kill buffer")

    "o"  '(:ignore t :which-key "org")
    "oa" '(org-agenda-list :which-key "agenda")
    "oA" '(org-agenda :which-key "agenda")
    "op" '(org-pandoc-export-to-latex-pdf :which-key "export to pdf")
    "oi" '(org-download-clipboard :which-key "paste clipboard image")
    ;; "on" '(org-noter-insert-note :which-key "insert noter note")
    "ol" '(org-latex-preview :which-key "preview latex")
    "ot" '(org-pomodoro :which-key "pomodoro")
    "of" '(org-footnote-action :which-key "footnote")))

;;==== Study/Anki ======

(use-package anki-editor  
  :diminish anki-editor-mode
  :config (setq anki-editor-latex-style 'mathjax)
  :straight (:fork "orgtre"))

(add-hook 'org-mode-hook (lambda () (ignore-errors (anki-editor-mode))))

;; attach org notes to pdfs
(use-package org-noter
  :after (:any org pdf-view)
  :config
  (setq
   org-noter-notes-window-location 'other-frame
   org-noter-always-create-frame nil))

;; automaticaly render latex in org
(use-package org-fragtog
  :config
  (add-hook 'org-mode-hook 'org-fragtog-mode))

(use-package pdf-tools
  :hook (pdf-view-mode . (lambda () (blink-cursor-mode -1)))
  :config
  (pdf-loader-install))

;; epub reader
(use-package nov)
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
(defun my-nov-font-setup ()
  (face-remap-add-relative 'variable-pitch :family "Liberation Sans" :height 1.5))
(add-hook 'nov-mode-hook 'my-nov-font-setup)

;;==== Rice ======

;; Remove default chrome
(setq inhibit-startup-message t)
(scroll-bar-mode -1) ; disable scrollbar
(tool-bar-mode -1) ; disable toolbar
(set-fringe-mode 5)
(menu-bar-mode -1) ; disable menu bar
(global-hl-line-mode 1)

(setq modus-themes-mode-line (quote (moody)))
(setq modus-themes-org-blocks 'gray-background)
(setq modus-themes-italic-constructs t)
(setq modus-themes-headings
      '((1 . (rainbow overline 1.6))
        (t . (rainbow))))
(setq modus-themes-scale-headings t)
(setq modus-themes-paren-match '(bold intense))
(setq modus-themes-prompts '(bold intense))
(setq modus-themes-hl-line '(intense))
;; make fringe (side padding) invisible
(setq modus-themes-common-palette-overrides
      '((fringe unspecified)))

(load-theme 'modus-operandi t)

(use-package all-the-icons)
  ;:if (display-graphic-p))

(column-number-mode)
(global-display-line-numbers-mode t)
(global-auto-revert-mode 1) ; auto update files changed outside emacs

(dolist (mode '(org-mode-hook
                org-agenda-mode-hook
                term-mode-hook
                vterm-mode-hook
                shell-mode-hook
                elfeed-show-mode-hook
                eshell-mode-hook
                help-mode-hook
                helpful-mode-hook
                nov-mode-hook
                notmuch-show-hook
                image-mode-hook
                pdf-view-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; modeline
(use-package moody
  :config
  (setq moody-mode-line-height 24)
  (setq x-underline-at-descent-line t)
  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode)
  (moody-replace-eldoc-minibuffer-message-function))

;; Hide diminished modes from modeline
(use-package diminish) ; hide certain minor modes from modeline
(diminish 'evil-collection-unimpaired-mode)
(diminish 'eldoc-mode)
(diminish 'flyspell-mode)

;; vim-like tab behavior
(setq tab-bar-show 1) ;; only show tab bar when frame has more than 1
(setq tab-bar-new-button-show nil)
(setq tab-bar-close-button-show nil)

;; Show indication guides/lines in code buffers
(use-package highlight-indent-guides
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'top)
  :config
  (add-hook 'prog-mode-hook 'highlight-indent-guides-mode))

;;==== Custom Functions ======

(defun pop-current-window-to-frame ()
  (interactive)
  (let ((buffer (current-buffer)))
    (unless (one-window-p)
      (delete-window))
    (display-buffer-pop-up-frame buffer nil)))

(defun switch-to-visible-window-buffer ()
  "Switch to a buffer visible in another window of the current frame."
  (interactive)
  (let* ((visible-windows (window-list))
         (visible-buffers (mapcar 'window-buffer visible-windows))
         (visible-buffer-names (mapcar 'buffer-name visible-buffers)))
    (ivy-read "Switch to visible buffer: " visible-buffer-names
              :action (lambda (buffer-name)
                        (let ((target-window (get-buffer-window buffer-name)))
                          (when target-window
                            (select-window target-window)))))))

;; Window management mode. hjkl to select buffer/window, HJKL to resize.
;; Thanks gpt-4!
(defvar window-management-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "h") 'windmove-left)
    (define-key map (kbd "j") 'windmove-down)
    (define-key map (kbd "k") 'windmove-up)
    (define-key map (kbd "l") 'windmove-right)
    (define-key map (kbd "H") (lambda () (interactive) (evil-window-decrease-width 5)))
    (define-key map (kbd "J") (lambda () (interactive) (evil-window-increase-height 5)))
    (define-key map (kbd "K") (lambda () (interactive) (evil-window-decrease-height 5)))
    (define-key map (kbd "L") (lambda () (interactive) (evil-window-increase-width 5)))
    ;; These don't work
    (define-key map (kbd "M-h") 'buf-move-left)
    (define-key map (kbd "M-j") 'buf-move-down)
    (define-key map (kbd "M-k") 'buf-move-up)
    (define-key map (kbd "M-l") 'buf-move-right)
    map)
  "Keymap for `window-management-mode'.")

(define-minor-mode window-management-mode
  "Minor mode for temporary window management keybindings."
  :init-value nil
  :lighter " WinMgmt"
  :keymap window-management-mode-map
  (if window-management-mode
       (add-to-ordered-list 'emulation-mode-map-alists
                           `((window-management-mode . ,window-management-mode-map))
                           0)
    (setq emulation-mode-map-alists
          (delq (assq 'window-management-mode emulation-mode-map-alists)
                emulation-mode-map-alists))))

(defun set-window-management-mode-all (val)
  (walk-windows (lambda (window)
                  (with-selected-window window (progn (window-management-mode val)
                                                      nil nil)))))


(defun enter-window-management-mode ()
  "Toggle `window-management-mode'."
  (interactive)
  (progn
    (set-window-management-mode-all 1)
    (run-with-idle-timer 2 nil 'set-window-management-mode-all -1)))

(global-set-key (kbd "C-c w") 'enter-window-management-mode)

;; ==== Documentation/Discovery ======

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idel-delay 0.3))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; ==== Markdown ======

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "pandoc"))

;; ==== Software Development ======

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/src")
    (setq projectile-project-search-path '("~/src")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package workgroups2
  :config (workgroups-mode))

(use-package magit)

(use-package sqlite3)

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (c++-mode . lsp-deferred)
         (rust-mode . lsp-deferred)
         (go-mode . lsp-deferred)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :config
  (setq lsp-headerline-breadcrumb-enable nil)
  :commands (lsp lsp-deferred))

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)

;; optionally if you want to use debugger
(use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language
(require 'dap-gdb-lldb)

(use-package flycheck
  :diminish)

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets)

;; M-x lsp-doctor recommendations
;; (setq gc-cons-threshold 100000000)
;; using gcmh instead
(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; Sets a high gc memory threshold to avoid interruption by gc, then drops the threshold and runs gc when things are idle
(use-package gcmh
  :diminish
  :hook
  (emacs-startup . gcmh-mode))

(use-package lsp-pyright
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp))))  ; or lsp-deferred

(lsp-register-client
 (make-lsp-client :new-connection (lsp-tramp-connection "pyright")
                  :major-modes '(python-mode)
                  :remote? t
                  :server-id 'pyright-remote))

(use-package company
  :diminish
  :after lsp-mode
  :hook (eshell-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection)
         ("<return>" . nil)
         ("<RET>" . nil))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0)) ;; Change value to have completion box automatically pop up after a delay

(use-package company-box
  :diminish
  :hook (company-mode . company-box-mode))

;; ==== Shell ======

;; Make eshell close close with "x", so that you don't end up with a million unused eshell buffers
;; https://old.reddit.com/r/emacs/comments/1zkj2d/advanced_usage_of_eshell/
(defun delete-single-window (&optional window)
  "Remove WINDOW from the display.  Default is `selected-window'.
If WINDOW is the only one in its frame, then `delete-frame' too."
  (interactive)
  (save-current-buffer
    (setq window (or window (selected-window)))
    (select-window window)
    (kill-buffer)
    (if (one-window-p t)
        (delete-frame)
        (delete-window (selected-window)))))

(defun eshell/x (&rest args)
  (delete-single-window))

;; I'm used to using C-r to search shell history. This overwrites the vim-esque c-r paste functionality, but I rarely use it in actual code/text buffers even.
;; Also, make C-d do what I would expect it to do in a terminal emulator, and kill the window
(use-package eshell
  :straight nil
  :config
  (evil-collection-define-key 'insert 'eshell-mode-map
    "\C-r" 'counsel-esh-history)
  (evil-collection-define-key 'insert 'eshell-mode-map
    "\C-d" 'delete-single-window)
  (setq eshell-expand-input-functions 'eshell-expand-history-references))

(defun open-eshell-in-split ()
  "Open a new eshell in a split window with the current buffer's working directory."
  (interactive)
  (split-window)
  (other-window 1)
  (let ((current-prefix-arg t))
    (eshell t)))

(global-set-key (kbd "C-c t") 'open-eshell-in-split)

(defun open-vterm-in-split ()
  "Open a new eshell in a split window with the current buffer's working directory."
  (interactive)
  (split-window)
  (other-window 1)
  (let ((current-prefix-arg t))
    (vterm t)))

(global-set-key (kbd "C-c v") 'open-vterm-in-split)

;; Make history append instead of overwrite
;; From https://emacs.stackexchange.com/a/18569/15023.
(setq eshell-save-history-on-exit nil)
(defun eshell-append-history ()
  "Call `eshell-write-history' with the `append' parameter set to `t'."
  (when eshell-history-ring
    (let ((newest-cmd-ring (make-ring 1)))
      (ring-insert newest-cmd-ring (car (ring-elements eshell-history-ring)))
      (let ((eshell-history-ring newest-cmd-ring))
        (eshell-write-history eshell-history-file-name t)))))
(add-hook 'eshell-pre-command-hook #'eshell-append-history)
(add-hook 'eshell-mode-hook #'(lambda () (setq eshell-exit-hook nil)))

(use-package eshell-prompt-extras)
(with-eval-after-load "esh-opt"
  (autoload 'epe-theme-lambda "eshell-prompt-extras")
  (setq eshell-highlight-prompt nil
        eshell-prompt-function 'epe-theme-lambda))

(use-package fish-completion
  :hook (eshell-mode . fish-completion-mode)
  :init (setq fish-completion-fallback-on-bash-p t))

(use-package eshell-syntax-highlighting
  :hook (eshell-mode . eshell-syntax-highlighting-mode))

(use-package vterm
  :init
  (setq vterm-max-scrollback 100000)
  (add-hook 'vterm-exit-functions (lambda (_ _) (delete-single-window)))
  :config
  (setq vterm-buffer-name-string "vterm %s"))

(setq evil-collection-mode-list (remove 'vterm evil-collection-mode-list))
(add-hook 'vterm-mode-hook 'evil-emacs-state)
(add-hook 'vterm-mode-hook 'evil-local-mode)

;; ==== Dired ======

(use-package dired
  :straight nil
  :custom
  (dired-listing-switches "-agho --group-directories-first")
  (dired-auto-revert-buffer t)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-alternate-file)
  (setq dired-dwim-target t)
  (require 'dired-x)
  (setq dired-guess-shell-alist-user
        '(("\\.*" "xdg-open"))))

(put 'dired-find-alternate-file 'disabled nil)

(use-package emacs-async
  ;; Drag-and-drop to `dired`
  :hook (dired-mode . dired-async-mode))

(use-package dired-open
  :config
  (setq dired-open-extensions '(("mkv" . "mpv")
                                ("mp4" . "mpv")
                                ("mov" . "mpv")
                                ("webm" . "mpv --loop=inf")
                                ("torrent" . "deluge-gtk")
                                ("mp3" . "mpv --player-operation-mode=pseudo-gui"))))

(use-package dired-du
  :config
  (setq dired-du-size-format t))

;; (use-package all-the-icons-dired
;;   :hook (dired-mode . all-the-icons-dired-mode))

(use-package peep-dired
  :custom
  (large-file-warning-threshold 1000000000)
  :config
  (setq peep-dired-cleanup-on-disable t)
  (evil-define-key 'normal peep-dired-mode-map
    (kbd "<SPC>") 'peep-dired-scroll-page-down
    (kbd "C-<SPC>") 'peep-dired-scroll-page-up
    (kbd "<backspace>") 'peep-dired-scroll-page-up
    (kbd "j") 'peep-dired-next-file
    (kbd "k") 'peep-dired-prev-file
    (kbd "h") 'dired-up-directory)
  :hook (peep-dired . evil-normalize-keymaps))

;; ==== Directory Cleanup ======
;; Keep backup and undo files from cluttering up my entire filesystem

(setq backup-directory-alist '(("." . "~/.config/emacs/backup")))
(setq undo-tree-history-directory-alist '((".*" . "~/.config/emacs/undo")))
(setq create-lockfiles nil)
(setq auto-save-file-name-transforms `((".*" "~/.config/emacs/auto-save/" t)))

;; ==== Mail ======

(use-package notmuch
  :custom
  (notmuch-search-oldest-first nil)
  (mm-text-html-renderer 'gnus-w3m)
  :config
  (evil-collection-define-key 'normal 'notmuch-search-mode-map
    "q" 'delete-single-window
    "l" 'notmuch-search-show-thread)
  (evil-collection-define-key 'normal 'notmuch-show-mode-map
    "V" 'org-next-link
    "h" 'notmuch-bury-or-kill-this-buffer)
  (setq gnus-inhibit-images nil))

(setq send-mail-function 'sendmail-send-it
      sendmail-program "/usr/bin/msmtp"
      mail-specify-envelope-from t
      message-sendmail-envelope-from 'header
      mail-envelope-from 'header)

(use-package ol-notmuch)

(use-package kbd-mode
  :straight (kbd-mode :type git :host github
           :repo "kmonad/kbd-mode"))

(use-package password-store)

(use-package elfeed
  :config
  (setq elfeed-use-curl t)
  (elfeed-set-timeout 36000)
  :config
  (evil-collection-define-key 'normal 'elfeed-search-mode-map
    "q" 'delete-single-window
    "l" 'elfeed-search-show-entry)
  (evil-collection-define-key 'normal 'elfeed-show-mode-map
    "h" 'elfeed-kill-buffer))


(use-package elfeed-protocol
  :config
  (setq elfeed-protocol-owncloud-maxsize 1000)
  (setq elfeed-protocol-owncloud-update-with-modified-time t)
  (elfeed-protocol-enable))

(setq elfeed-feeds '(("owncloud+http://nomen@radch"
                         :password (password-store-get "nextcloud"))))

;; Pretty rss entries for youtube videos
(use-package elfeed-tube
  :after elfeed
  :demand t
  :config
  ;; (setq elfeed-tube-auto-save-p nil) ; default value
  ;; (setq elfeed-tube-auto-fetch-p t)  ; default value
  (elfeed-tube-setup)

  :bind (:map elfeed-show-mode-map
         ("F" . elfeed-tube-fetch)
         ([remap save-buffer] . elfeed-tube-save)
         :map elfeed-search-mode-map
         ("F" . elfeed-tube-fetch)
         ([remap save-buffer] . elfeed-tube-save)))

;;==== FCITX ======
;; automatically disable jp input anywhere it would cause issues (e.g., evil normal mode)
;; dbus settings from https://kisaragi-hiu.com/why-fcitx5.html

(use-package fcitx
  :config
  (setq fcitx-use-dbus nil fcitx-remote-command "fcitx5-remote")
  (fcitx-default-setup))

(use-package chatgpt-shell
  :straight `(chatgtp-shell :type git
                            :host github :repo "xenodium/chatgpt-shell")
  :config (setq chatgpt-shell-openai-key
                (lambda ()
                  (nth 1 (process-lines "pass" "openai")))))

(setq use-short-answers t)

(use-package sudo-edit)

(winner-mode 1)
;; Bind C-w ESC to winner-undo in normal mode
(evil-define-key 'normal 'global (kbd "C-w <escape>") 'winner-undo)

(define-key evil-window-map (kbd "C-w") 'ace-window)

(use-package ws-butler
  :hook (on-first-buffer . ws-butler-global-mode)
  :diminish)

(use-package bookmark
  :custom
  (bookmark-save-flag 1))

(use-package autorevert
  :diminish auto-revert-mode
  :hook (on-first-buffer . global-auto-revert-mode)
  :custom
  (global-auto-revert-non-file-buffers t))

(use-package comp
  :straight nil
  :custom
  (native-comp-async-report-warnings-errors 'silent))

;; this likely makes the above redundant
(setq warning-minimum-level :error)

(use-package rustic
  :config
  (setq rustic-format-trigger 'on-save))

(use-package go-mode)

(use-package yaml-mode)

(use-package ada-mode
  :custom
  (ada-auto-case nil))

;; (setq-default indent-tabs-mode nil)
(setq-default tab-width 4) ;; how large to tabs appear
;; (setq tab-stop-list (number-sequence 4 120 4)) ;; how many spaces does the tab key insert - 4
;; (setq indent-line-function 'insert-tab)
;; (setq evil-auto-indent nil)

;; (defun my-ement-panta-connect ()
  ;; (interactive)
  ;; (ement-connect :uri-prefix "http://localhost:8009" :user-id "@luchereturns:matrix.org"))

(setq browse-url-browser-function 'browse-url-firefox)
;; (setq rustic-cargo-bin "~/.cargo/bin/cargo")
(straight-use-package 'exec-path-from-shell)
(when (daemonp)
  (exec-path-from-shell-initialize))
