;;; init.el -*- lexical-binding: t; -*-

;;;###autoload
(defun jam/librefm-stream (station)
  "Start default stream with emms. Uses pass for login information."
  (interactive
   (list
    (read-string
     (format "Station (librefm://globaltags/Classical): ")
     nil nil
     "librefm://globaltags/Classical")))
  (message "station is %s" station)
  (setq emms-librefm-scrobbler-username "jaming"
        emms-librefm-scrobbler-password (alist-get 'secret (auth-source-pass-parse-entry "librefm/jaming")))
  (emms-librefm-stream station))

;;;###autoload
(defun jam/sudo-edit (file)
  "Edit file with sudo. Defaults to current buffer's file name."
  (interactive
   (list
    (read-string
     (format "Sudo Edit File(%s): " (buffer-file-name (current-buffer)))
     nil nil
     (buffer-file-name (current-buffer)))))
  (message "sudo-edited file: %s" file)
  (find-file (format "/sudo::%s" file)))

;;;###autoload
(defun jam/save-all ()
  "Save all buffers"
  (interactive)
  (save-some-buffers t))

;;;###autoload
(defun jam/newsticker-download ()
  "Download the current newsticker enclosure to tmpdir/newsticker/feed/title"
  (interactive)
  (let* ((item (newsticker--treeview-get-selected-item))
         (feedname "jam")
         (title (newsticker--title item))
         (enclosure (newsticker--enclosure item))
         (download-dir (file-name-as-directory
                        (expand-file-name (newsticker--title (newsticker--treeview-get-selected-item))
                                          (expand-file-name feedname (expand-file-name "newsticker" temporary-file-directory))))))
  (newsticker-download-enclosures feedname item)
  (emms-play-directory download-dir)));(delete-directory download-dir t)

;;;###autoload
(defun jam/draw ()
  "Activate artist-mode polygon in *scratch* buffer."
  (interactive)
  (switch-to-buffer "*scratch*")
  (artist-mode 1); (picture-mode)
  (artist-select-op-poly-line))

;;;###autoload
(defun jam/set-rust-path ()
  "Set PATH, exec-path, RUSTUP_HOME and CARGO_HOME to XDG_DATA_HOME locations"
  (interactive)
  (setenv "PATH" (concat (getenv "PATH")
                         path-separator (concat (file-name-as-directory (xdg-data-home))
                                                (file-name-as-directory "cargo") "bin")))
  (setenv "RUSTUP_HOME" (concat (file-name-as-directory (xdg-data-home)) "rustup"))
  (setenv "CARGO_HOME" (concat (file-name-as-directory (xdg-data-home)) "cargo"))
  (setq exec-path (append `(,(concat (file-name-as-directory (getenv "CARGO_HOME")) "bin")) exec-path)))

;;;###autoload
(defun jam/compile-init-bytecode ()
  "Recompile init.el, early-init.el, make-el.el and package-quickstart.el (autoloads)"
  (interactive)
  (byte-recompile-file (concat user-emacs-directory "init.el"))
  (byte-recompile-file (concat user-emacs-directory "early-init.el"))
  (byte-recompile-file (concat user-emacs-directory "make-el.el"))
  (require 'package) ; recompile autoloads
  (package-quickstart-refresh)
  (byte-recompile-file (concat user-emacs-directory "package-quickstart.el")))

;;;###autoload
(defun jam/eshell ()
  "Open new eshell"
  (interactive)
  (eshell t))

;;;###autoload
(defun jam/eshell ()
  "Open new eshell"
  (interactive)
  (eshell t))

;;;###autoload
(defun jam/move-line-up ()
  "Move line up"
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

;;;###autoload
(defun jam/move-line-down ()
  "Move line down"
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

;;;###autoload
(defun jam/move-word-right ()
  "Move word right"
  (interactive)
  (transpose-words 1))

;;;###autoload
(defun jam/move-word-left ()
  "Move word left"
  (interactive)
  (transpose-words -1))

;; Movement: f b n p, a e, M-g-g, F3/F4 for macros
(use-package emacs ; built-in
  :init (setq backup-directory-alist `(("." . ,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache"))))
              auto-save-list-file-prefix (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "auto-save-list") ".saves-")
              recentf-save-file (expand-file-name "recentf" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              bookmark-default-file (expand-file-name "bookmarks" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache"))) ; bookmarks support annotations
              project-list-file (expand-file-name "projects" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              url-cookie-file (expand-file-name "cookies" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              url-cache-directory (expand-file-name "cache" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              nsm-settings-file (expand-file-name "network-security.data" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              auth-sources (list (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "authinfo.gpg") (concat (file-name-as-directory (getenv "HOME")) ".authinfo.gpg")) ; auth
              epa-file-cache-passphrase-for-symmetric-encryption t
              modus-themes-mode-line '(accented borderless moody) ; theme
              modus-themes-box-buttons '(underline faint accented)
              modus-themes-paren-match '(bold underline)
              modus-themes-org-blocks '(tinted-background)
              modus-themes-headings '((t . (rainbow)))
              modus-themes-subtle-line-numbers t
              modus-themes-markup '(bold intense)
              modus-themes-org-agenda '((header-block . (1.5 variable-pitch))
                                        (header-date . (bold-today))
                                        (event . (accented varied))
                                        (scheduled . rainbow)
                                        (habit . nil))
              modus-themes-prompts '(background)
              modus-themes-region '(accented bg-only no-extend)
              modus-themes-completions '((matches . (extrabold background intense))
                                         (selection . (semibold accented intense))
                                         (popup . (accented)))
              display-line-numbers-type t ; defaults
              apropos-do-all t
              xterm-set-window-title t
              xterm-extra-capabilities '(getSelection setSelection) ; osc term copy/paste
              visible-cursor nil
              isearch-wrap-pause 'no-ding ; wrap isearch
              ad-redefinition-action 'accept ; ignore warnings
              completion-auto-help 'lazy; '?' for help w/mouse click
              completion-cycle-threshold nil ; flex narrowing instead of cycling
              completions-format 'one-column
              completions-group t
              completion-styles '(basic initials substring partial-completion)
              completions-detailed t
              ;completion-auto-select 'second-tab
              column-number-mode t
              sentence-end-double-space nil
              require-final-newline t
              bidi-inhibit-bpa t ; some naughty unicodes
              auto-revert-remote-files nil ; dired
              auto-revert-interval 1
              use-short-answers t ; annoying
              confirm-kill-processes nil
              visible-bell t
              ring-bell-function #'ignore
              uniquify-buffer-name-style 'forward
              confirm-nonexistent-file-or-buffer nil
              confirm-kill-emacs nil
              blink-matching-paren nil
              enable-recursive-minibuffers t
              tool-bar-mode nil
              scroll-bar-mode nil
              mouse-yank-at-point t
              mouse-drag-and-drop-region t
              x-stretch-cursor nil
              indicate-buffer-boundaries nil
              indicate-empty-lines nil
              shift-select-mode t
              frame-resize-pixelwise t ; frames/windows
              frame-inhibit-implied-resize t
              highlight-nonselected-windows nil
              window-resize-pixelwise nil
              window-divider-default-places t
              window-divider-default-bottom-width 1
              window-divider-default-right-width 1
              split-height-threshold nil
              split-width-threshold 160
              resize-mini-windows 'grow-only
              truncate-partial-width-windows nil
              auto-window-vscroll nil ; scrolling
              mouse-wheel-tilt-scroll t ; horizontal scrolling
              mouse-wheel-flip-direction t ; horizontal scrolling
              scroll-conservatively 101
              scroll-margin 0
              scroll-preserve-screen-position t
              hscroll-margin 2
              hscroll-step 1
              fast-but-imprecise-scrolling t
              inhibit-compacting-font-caches t
              redisplay-skip-fontification-on-input t
              shift-select-mode t
              read-process-output-max (* 64 1024)
              gc-cons-threshold (* 256 1024 1024) ; 256 MiB default before gc
              desktop-path `(,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "desktop-session"))) ; create dir before saving
              ;load-prefer-newer t; noninteractive
              auto-mode-case-fold nil
              kill-do-not-save-duplicates t
              edebug-print-length nil ; print whole edebug result
              browse-url-browser-function 'xwidget-webkit-browse-url ; libxml-parse-html-region w/ shr
              shr-use-xwidgets-for-media t ; eww display video tags
              display-time-format "%m-%d-%Y %R"
              display-time-default-load-average nil
              find-file-visit-truename t ; files
              vc-follow-symlinks t
              find-file-suppress-same-file-warnings t
              create-lockfiles nil
              make-backup-files nil
              version-control t
              backup-by-copying t
              delete-old-versions t
              kept-old-versions 5
              kept-new-versions 5
              auto-save-default t
              auto-save-include-big-deletions t
              initial-major-mode 'fundamental-mode ; startup
              initial-scratch-message nil
              default-input-method nil
              inhibit-startup-screen t
              inhibit-startup-echo-area-message user-login-name
              inhibit-default-init t)

  (if (native-comp-available-p)
      (progn
        (startup-redirect-eln-cache (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln"))
        (setq native-comp-deferred-compilation t
              native-comp-enable-subr-trampolines (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln")
              native-comp-async-report-warnings-errors nil
              native-comp-eln-load-path (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln"))
              native-compile-target-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln"))))
  (bind-keys :map window-prefix-map ; C-x 1 C-x o ; (windmove-default-keybindings 'control)
             ("w" . windmove-up)
             ("a" . windmove-left)
             ("s" . windmove-down)
             ("d" . windmove-right)
             ("f" . select-frame-by-name)
             ("o" . other-frame))
  (setq-default indent-tabs-mode nil
                tab-width 4
                tab-always-indent 'complete
                word-wrap t)
  (add-hook 'prog-mode-hook #'(lambda () (setq show-trailing-whitespace t)))
  (add-hook 'text-mode-hook #'(lambda () (setq show-trailing-whitespace t)))
  (fido-vertical-mode 1) ; M-j to ignore completion
  (cua-mode 1)
  (window-divider-mode 1)
  (display-time-mode 1)
  (delete-selection-mode 1)
  (add-hook 'tty-setup-hook #'xterm-mouse-mode)
  (add-hook 'after-init-hook #'(lambda () (message "after-init-hook running after %s" (float-time (time-subtract after-init-time before-init-time)))
                                 (setq file-name-handler-alist default-file-name-handler-alist ;; restore default
                                       default-file-name-handler-alist nil)))
  (run-with-idle-timer 15 t (lambda () (garbage-collect))) ; collect gc every 15s while idle
  (blink-cursor-mode -1)
  (pixel-scroll-precision-mode 1) ; smooth scrolling
  (electric-pair-mode 1) ; less typing
  (context-menu-mode 1); mouse right click menu
  (bind-keys ("<M-up>" . jam/move-line-up)
             ("<M-down>" . jam/move-line-down)
             ("<M-left>" . jam/move-word-left)
             ("<M-right>" . jam/move-word-right))
  (bind-keys :map ctl-x-map ("C-S-s" . jam/save-all))
  (bind-keys :map help-map ("D" . shortdoc))
  (bind-keys :map emacs-lisp-mode-map ("C-c C-S-f" . pp-buffer))
  (bind-keys :map minibuffer-local-completion-map
             ;("<mouse-1>" . minibuffer-choose-completion)
             ("C-TAB" . icomplete-fido-ret)
             ("C-<tab>" . icomplete-fido-ret)
             ("S-TAB" . icomplete-backward-completions) ; wraparound?
             ("<backtab>" . icomplete-backward-completions)
             ("TAB" . icomplete-forward-completions)
             ("<tab>" . icomplete-forward-completions)
             ("<mouse-4>" . icomplete-backward-completions)
             ("<wheel-up>" . icomplete-backward-completions)
             ("<mouse-5>" . icomplete-forward-completions)
             ("<wheel-down>" . icomplete-forward-completions))
  (bind-keys :prefix-map jam/vcs :prefix "C-c v")
  (bind-keys :prefix-map jam/notes :prefix "C-c n")
  (bind-keys :prefix-map jam/projects :prefix "C-c p"); C-x p g
  (bind-keys :prefix-map jam/toggle :prefix "C-c t"
             ("v" . visible-mode)
             ("w" . visual-line-mode)
             ("x" . xterm-mouse-mode)
             ("c" . global-display-fill-column-indicator-mode)
             ("F" . toggle-frame-fullscreen)
             ("f" . flymake-mode)
             ("r" . recentf-mode)
             ("g" . auto-revert-mode))
  (bind-keys :prefix-map jam/open :prefix "C-c o"
             ("r" . recentf-open)
             ("s" . jam/sudo-edit)
             ("S" . speedbar-frame-mode)
             ("b" . browse-url-of-file)
             ("-" . dired-jump)
             ("f" . make-frame)
             ("D" . jam/draw)
             ("d" . desktop-read)
             ("u" . xwidget-webkit-browse-url)
             ("U" . eww-browse))
  (bind-keys :prefix-map jam/insert :prefix "C-c i"
             ("y" . cua-paste)
             ("u" . insert-char)
             ("s" . yas-insert-snippet)
             ("e" . emojify-insert-emoji)
             ("b" . string-insert-rectangle))
  (bind-keys :prefix-map jam/code :prefix "C-c c"
             ("j" . xref-find-definitions)
             ("c" . compile))
  (bind-keys :prefix-map jam/search :prefix "C-c s"
             ("l" . shr-copy-url)
             ("L" . ffap-menu)
             ("i" . imenu)
             ("a" . apropos)
             ("m" . bookmark-jump))
  (bind-keys :prefix-map jam/file :prefix "C-c f"
             ("f" . find-file)
             ("d" . dired)
             ("D" . desktop-save-in-desktop-dir))
  (bind-keys :prefix-map jam/quit :prefix "C-c q"
             ("f" . delete-frame)
             ("q" . kill-emacs)
             ("r" . restart-emacs)
             ("Q" . save-buffers-kill-terminal)
             ("K" . save-buffers-kill-emacs))
  (load-theme 'modus-vivendi); built-in does not need to hook server-after-make-frame-hook for daemonp
  (if (not (memq window-system '(android))) ; disable menu-bar on non android
      (progn
        (setq menu-bar-mode nil)
        (add-to-list 'default-frame-alist '(menu-bar-lines . 0)))
    ;; set android termux paths for call-process
    (setenv "PATH" (format "%s:%s" "/data/data/com.termux/files/usr/bin"
                           (getenv "PATH")))
    (setenv "LD_LIBRARY_PATH" (format "%s:%s"
                                      "/data/data/com.termux/files/usr/lib"
                                      (getenv "LD_LIBRARY_PATH")))
    (push "/data/data/com.termux/files/usr/bin" exec-path))
  (add-to-list 'default-frame-alist '(tool-bar-lines . 0)) ; disable w/o loading mode
  (add-to-list 'default-frame-alist '(vertical-scroll-bars))
  (set-frame-parameter nil 'alpha-background 80)
  (add-to-list 'default-frame-alist '(alpha-background  . 80))
  (add-to-list 'initial-frame-alist '(alpha-background  . 80))
  (set-language-environment "UTF-8"))

(use-package org-crypt
  :ensure nil ; built-in
  :commands (org-encrypt-entries org-encrypt-entry org-decrypt-entries org-decrypt-entry))

(use-package org-clock
  :ensure nil ; built-in
  :init (bind-keys :map jam/notes ("g" . org-clock-goto))
  :commands (org-clock-goto org-clock-in org-clock-cancel))

(use-package org
  :ensure nil ; built-in
  :commands (org-mode org-agenda org-capture org-todo-list org-id-update-id-locations)
  :init (setq org-timer-default-timer 60
              org-src-tab-acts-natively nil
              org-edit-src-content-indentation 0
              org-clock-sound t); org-timer-set-timer
  (bind-keys :map jam/notes
              ("D" . org-id-update-id-locations)
              ("t" . org-todo-list)
              ("a" . org-agenda)))

;; M-j newline in regex
(use-package dired
  :ensure nil ; built-in
  :config (setq dired-dwim-target t
                dired-hide-details-hide-symlink-targets nil
                dired-auto-revert-buffer #'dired-buffer-stale-p
                dired-recursive-copies  'always
                dired-recursive-deletes 'top
                dired-create-destination-dirs 'ask)
  :commands (dired dired-jump dired-other-frame dired-other-tab dired-other-window))

(use-package emms ; mpv
  :init (bind-keys :map jam/open
                   ("l" . jam/librefm-stream)
                   ("m" . emms-play-file)
                   ("M" . emms-play-directory)
                   ("L" . emms-play-url)
                   ("z" . emms-next))
  :commands (emms-play-file emms-librefm-stream emms-browser emms-play-url emms-play-directory emms-next)
  :config
  (setq emms-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "emms"))
  (require 'emms-setup)
  (emms-minimalistic)
  (setq emms-player-list '(emms-player-mpv)); emms-player-vlc
  (require 'emms-librefm-stream)
  (emms-librefm-scrobbler-disable) ; BUG make work without login
  (setq emms-source-file-default-directory (concat (file-name-as-directory (getenv "HOME")) "Music")
        emms-playlist-buffer-name "*Music*"
        emms-info-asynchronously t)
  (require 'emms-mode-line)
  (emms-mode-line 1)
  (require 'emms-playing-time)
  (emms-playing-time 1))

(when (not (memq window-system '(android))) ; old android builds do not enable gnutls (sourceforge build w/termux for utils)
(use-package guix ; guix
  :config (require 'guix-autoloads)
  (guix-set-emacs-environment (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") "profile"))
  (guix-set-emacs-environment (concat (file-name-as-directory (getenv "HOME")) ".guix-profile"))
  ;(guix-emacs-autoload-packages); set EMACSLOADPATH
  :commands guix-popup guix-set-emacs-environment)
)

(use-package geiser ; guile
  :init (add-hook 'scheme-mode-hook #'geiser-mode)
  :commands (geiser geiser-mode geiser-mode-hook geiser-repl-mode geiser-repl-mode-hook)
  :config
  (setq geiser-repl-per-project-p t
        geiser-repl-current-project-function #'geiser-repl-project-root
        geiser-repl-history-filename (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "geiser-history"))
  (require 'geiser-guile)); geiser call per buffer?

(use-package macrostep-geiser ; guile
  :init
  (add-hook 'geiser-mode-hook #'macrostep-geiser-setup)
  (add-hook 'geiser-repl-mode-hook #'macrostep-geiser-setup)
  :commands macrostep-geiser-setup)

(use-package geiser-guile ; guile
  :init (require 'xdg)
  (with-eval-after-load 'geiser-guile (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (xdg-config-home)) (file-name-as-directory "guix") (file-name-as-directory "current") (file-name-as-directory "share") (file-name-as-directory "guile") (file-name-as-directory "site") "3.0")) ; source
                        (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (xdg-config-home)) (file-name-as-directory "guix") (file-name-as-directory "current") (file-name-as-directory "lib") (file-name-as-directory "guile") (file-name-as-directory "3.0") "site-ccache")) ; compiled
                        (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "share") (file-name-as-directory "guile") (file-name-as-directory "site") "3.0"))
                        (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "share") (file-name-as-directory "guile") "3.0"))
                        (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "lib") (file-name-as-directory "guile") (file-name-as-directory "3.0") "site-ccache"))
                        (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "lib") (file-name-as-directory "guile") (file-name-as-directory "3.0") "ccache")))
  :commands geiser-guile)

(use-package flymake ; MAYBE add flycheck backends
  :ensure nil ; built-in
  :commands flymake-mode)

(use-package flymake-guile ; guile/guild
  :commands flymake-guile
  :hook (scheme-mode . flymake-guile)
  :hook (scheme-mode . flymake-mode))

(use-package flyspell ; aspell
  :ensure nil ; built-in
  :init (bind-keys :map jam/toggle ("s" . flyspell-mode))
  (add-hook 'org-mode-hook #'flyspell-mode)
  (add-hook 'markdown-mode-hook #'flyspell-mode)
  (add-hook 'TeX-mode-hook #'flyspell-mode)
  (add-hook 'rst-mode-hook #'flyspell-mode)
  (add-hook 'message-mode-hook #'flyspell-mode)
  (add-hook 'git-commit-mode-hook #'flyspell-mode)
  (add-hook 'yaml-mode-hook #'flyspell-prog-mode)
  (add-hook 'conf-mode-hook #'flyspell-prog-mode)
  (add-hook 'prog-mode-hook #'flyspell-prog-mode)
  :config (setq flyspell-issue-welcome-flag nil
                flyspell-issue-message-flag nil
                ispell-program-name "aspell" ; runs as own process
                ispell-extra-args '("--sug-mode=ultra"
                                    "--run-together")
                ispell-personal-dictionary (expand-file-name (concat (file-name-as-directory "ispell") ispell-dictionary ".pws") (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc")))
                ispell-aspell-dict-dir (ispell-get-aspell-config-value "dict-dir")
                ispell-aspell-data-dir (ispell-get-aspell-config-value "data-dir")))

(use-package eglot
  :hook (((rust-mode) . eglot-ensure))
  :custom (eglot-send-changes-idle-time 0.1)
  :config (fset #'jsonrpc--log-event #'ignore); stop logging
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer" :initializationOptions (:checkOnSave (:command "clippy"))))))

(use-package rust-mode
  :commands rust-mode
  :config (jam/set-rust-path))

(use-package undo-tree
  ;:pin gnu
  :init (add-hook 'after-init-hook #'global-undo-tree-mode)
  :commands (global-undo-tree-mode)
  :custom (undo-tree-history-directory-alist `(("." . ,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "undo-tree-hist")))))
  :config (setq undo-tree-visualizer-diff t
                undo-tree-auto-save-history t
                undo-limit 800000 ; 800 kb (default 160kb)
                undo-strong-limit 12000000 ; 12mb (default 240kb)
                undo-outer-limit 128000000 ; 128mb (default 24mb)
                undo-tree-enable-undo-in-region t))

(use-package pass ; gpg/pass/sh
  :init (bind-keys :map jam/open ("p" . pass))
  :config
  (setenv "GNUPGHOME" (concat (file-name-as-directory (xdg-data-home)) "gnupg"))
  (setenv "PASSWORD_STORE_DIR" (concat (file-name-as-directory (xdg-data-home)) "pass"))
  :commands pass)

(use-package password-store-otp; pass
  :after pass)

(use-package password-store ; pass
  :ensure nil ; built-in ; info:auth#The Unix password store
  :config (setq password-store-password-length 12)
          (auth-source-pass-enable))

(use-package newsticker ; wget
  :ensure nil ; built-in
  :commands (newsticker-start newsticker-treeview newsticker-plainview newsticker-stop)
  :config
  (bind-keys :map newsticker-treeview-item-mode-map ("d" . jam/newsticker-download))
  :init (bind-keys :map jam/open ("n" . newsticker-treeview))
  (bind-keys :map jam/toggle ("n" . newsticker-stop))
  (setq newsticker-frontend 'newsticker-treeview
        newsticker-dir (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "newsticker")
        newsticker-automatically-mark-items-as-old nil
        newsticker-automatically-mark-visited-items-as-old t
        newsticker-url-list-defaults nil
        newsticker-url-list '(("Guix" "https://guix.gnu.org/feeds/blog.atom") ; supports atom feeds unlike gnus
                              ("Lwn" "https://lwn.net/headlines/newrss")
                              ("Tor" "https://blog.torproject.org/rss.xml")
                              ("emacs-tags" "https://github.com/emacs-mirror/emacs/tags.atom") ; not used: https://savannah.gnu.org/news/atom.php?group=emacs
                              ("chia-release" "https://github.com/Chia-Network/chia-blockchain/releases.atom") ; gitea commit rss ex: https://codeberg.org/gnuastro/gnuastro.rss
                              ("Level1Techs" "https://yewtu.be/feed/channel/UC4w1YQAJMWOz4qtxinq55LQ"); youtube rss ex: https://www.youtube.com/feeds/videos.xml?channel_id=UC4w1YQAJMWOz4qtxinq55LQ
                              ("StyxHexenHammer" "https://odysee.com/$/rss/@Styxhexenhammer666:2"); bitchute rss ex: https://www.bitchute.com/feeds/rss/channel/Styxhexenhammer666
                              ("Reddit-news" "https://www.reddit.com/r/news/.rss"); teddit(dead?) ex: https://teddit.net/r/news?api&type=rss
                              ("Lobste" "https://lobste.rs/rss")
                              ("Phoronix" "https://www.phoronix.com/rss.php")
                              ("CVE" "https://nvd.nist.gov/feeds/xml/cve/misc/nvd-rss-analyzed.xml")
                              ("BramCohen" "https://bramcohen.substack.com/feed"); https://nitter.net/bramcohen/rss
                              ("AndyWingo" "https://wingolog.org/feed/atom"))))

(use-package magit ; git
  :commands magit-file-delete magit-status
  :init
  (bind-keys :map jam/vcs ("s" . magit-status))
  (setq magit-auto-revert-mode nil)
  (setq transient-levels-file (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") (file-name-as-directory "transient") "levels")
        transient-values-file (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") (file-name-as-directory "transient") "values")
        transient-history-file (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") (file-name-as-directory "transient") "history"))
  :config
  (setq transient-default-level 5
        transient-display-buffer-action '(display-buffer-below-selected)
        magit-diff-refine-hunk t
        magit-save-repository-buffers nil
        magit-revision-insert-related-refs nil
        magit-bury-buffer-function #'magit-mode-quit-window)
  (add-hook 'magit-process-mode-hook #'goto-address-mode)
  (bind-keys :map magit-mode-map ("q" . kill-buffer))
  (bind-keys :map transient-map ([escape] . transient-quit-one)))

;; authinfo machine api.github.com login USERNAME^forge password 012345abcdef...
(use-package forge ; git
  :after magit
  :commands forge-create-pullreq forge-create-issue
  :init
  (setq forge-database-file (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") (file-name-as-directory "forge") "forge-database.sqlite"))
  (setq forge-add-default-bindings t))

(use-package code-review ; git
  :after magit
  :init
  (setq code-review-db-database-file (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") (file-name-as-directory "code-review") "code-review-db-file.sqlite")
        code-review-log-file (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") (file-name-as-directory "code-review") "code-review-error.log")
        code-review-download-dir (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") (file-name-as-directory "code-review"))
        code-review-auth-login-marker 'forge))

(use-package transmission ; C-u universal arg for directory prompt ; transmission
  :commands (transmission transmission-add))

(use-package orgit ; git
  :commands (orgit-store-link))

(use-package orgit-forge ; git
  :commands (orgit-topic-store orgit-topic-open))

;; C-u C-c . for agenda with timestamp or org-time-stamp-inactive for no agenda version
(use-package org-roam ; sqlite ; emacs-29 >= (sqlite-available-p)
  :commands (org-roam-node-find org-roam-node-insert org-roam-dailies-goto-date org-roam-dailies-goto-today org-roam-graph org-roam-db-autosync-enable)
  :init (setq org-roam-directory (concat (expand-file-name user-emacs-directory) (file-name-as-directory "org") (file-name-as-directory "roam"))
              org-directory org-roam-directory
              org-id-locations-file (expand-file-name ".orgids" org-directory) ; org-id-update-id-locations org-roam-db-sync
              org-return-follows-link t
              org-persist-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "org-persist"))
              org-roam-dailies-directory ""
              org-agenda-files (list org-roam-directory)
              org-roam-db-location (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "org-roam.db")
              org-modules '(org-crypt);ol-bibtext
              org-roam-dailies-capture-templates '(("d" "default" entry
                                                    "* %U %?\n%i\n%a"
                                                    :if-new (file+datetree "journal.org" "#+title: ${title}\n")
                                                    :prepend t
                                                    :unnarrowed t))
              org-roam-capture-templates `(("d" "default" plain
                                            "%?"
                                            :if-new (file+head "${slug}.org" ,(concat "#+title: ${title}\n"
                                                                                      "#+OPTIONS: toc:nil num:nil date:nil \\n:nil html-style:nil author:nil timestamp:nil title:nil html-postamble:nil html5-fancy:t\n"
                                                                                      "#+HTML_HEAD: <link rel=\"stylesheet\" type=\"text/css\" href=\"org-default.css\" />\n"
                                                                                      "#+HTML_CONTENT_CLASS: container content \n"
                                                                                      "#+HTML_DOCTYPE: html5 \n"
                                                                                      "#+INCLUDE: \"css.org::navbar\" :only-contents t \n"))
                                            :unnarrowed t)))
  (bind-keys :map jam/notes
              ("T" . org-roam-dailies-capture-today)
              ("d" . org-roam-dailies-goto-date)
              ("n" . org-roam-capture)
              ("N" . org-roam-dailies-capture-date)
              ("i" . org-roam-node-insert)
              ("R" . org-roam-db-sync)
              ("r" . org-roam-node-find)))

(use-package osm ; curl
  ;:pin gnu
  :init (bind-keys :map jam/open ("o" . osm-home)) ;(with-eval-after-load 'org (require 'osm-ol))
  :commands (osm-home osm-search)
  :config (setq osm-tile-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "osm")))
  :custom (osm-copyright nil))

(use-package python ; python
  :ensure nil ; built-in
  :commands (python-mode python-mode-hook python-mode-local-vars-hook))

(use-package pyvenv ; python
  :init (add-hook 'python-mode-hook #'pyvenv-tracking-mode)
  (add-hook 'pyvenv-post-activate-hooks #'eglot-ensure)
  :commands (pyvenv-mode pyvenv-activate pyvenv-tracking-mode pyvenv-post-activate-hooks))

(use-package rmsbolt
  :init (bind-keys :map jam/toggle ("R" . rmsbolt-mode))
  :commands rmsbolt-mode)

(use-package minions ; hide minor modes on modeline
  :init (add-hook 'after-init-hook #'minions-mode)
  :commands minions-mode)

(use-package debbugs
  ;:pin gnu
  :init (bind-keys :map jam/search ("b" . debbugs-gnu-bugs)); bug number search
  :commands (debbugs-gnu debbugs-gnu-tagged debbugs-org debbugs-org-tagged debbugs-org-mode debbugs-gnu-bugs debbugs-gnu-guix-search debbugs-org-guix-search)
  :config ;(setq org-link-elisp-confirm-function nil)
  (setq debbugs-gnu-default-packages '("guix-patches"))
  (require 'debbugs-guix)
  (require 'debbugs-org)
  (require 'debbugs-gnu)
  (require 'debbugs-browse)); C-u M-x debbugs-gnu guix-patches n y then tag with t

(use-package hideshow
  :ensure nil ; built-in
  :init (bind-keys :map jam/toggle ("z" . hs-minor-mode))
  (bind-keys :map jam/code ("z" . hs-toggle-hiding)
                           ("v" . hs-hide-block))
  :commands (hs-minor-mode hs-toggle-hiding hs-hide-block hs-hide-level hs-show-all hs-hide-all))

(use-package erc
  :ensure nil ; built-in
  :init (bind-keys :map jam/open ("i" . erc-tls))
  :commands erc-tls erc ; MAYBE add bot msg to erc-nickserv-identified-hook, erc-login function override/erc-join-hook for SASL support
  :config (setq erc-rename-buffers t
                erc-interpret-mirc-color t
                erc-save-buffer-on-part t
                erc-log-insert-log-on-open t
                erc-log-channels-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") "erc")
                ;erc-nick '("jaming" "jamin" "jam")
                ;erc-user-full-name "jaming"
                ;erc-keywords '("jaming")
                erc-server-history-list '("irc.rizon.net" "irc.libera.chat" "irc.choopa.net" "irc.corrupt-net.org")
                erc-autojoin-timing 'ident
                erc-autojoin-delay 30
                ;erc-max-buffer-size 20000
                ;erc-prompt-for-nickserv-password nil
                ;erc-nickserv-passwords '((Corrupt (("nickname" . "password"))))
                ;erc-use-auth-source-for-nickserv-password t; format: machine irc.site.net login your_nickname password your_password
                erc-prompt-for-password nil
                erc-nickserv-identify-mode 'both
                ;erc-dcc-auto-masks '(".*!.*@.*") ; accept dcc files from anyone with 'auto send-requests
                ;erc-dcc-send-request 'auto ; BUG /dcc get NICK FILE fails with unknown filename (spaces/brackets in name) and daemon default-directory not respected
                erc-server-auto-reconnect nil ; /reconnect
                erc-auto-query 'bury
                erc-join-buffer 'bury
                erc-fill-column 80
                erc-fill-static-center 20
                erc-fill-function 'erc-fill-static
                erc-kill-buffer-on-part t
                erc-kill-queries-on-quit t
                erc-kill-server-buffer-on-quit t
                erc-autojoin-channels-alist '(("Libera.Chat" "#emacs" "#guix")
                                              ("Rizon" "#subsplease")
                                              ("EFnet" "#srrdb")
                                              ("Corrupt" "#Pre" "#Pre.Nuke"))
                erc-hide-list '("JOIN" "PART" "QUIT")
                erc-network-hide-list '(("Libera.Chat" "JOIN" "PART" "QUIT")
                                       ("Rizon" "JOIN" "PART" "QUIT")
                                       ("EFnet" "JOIN" "PART" "QUIT")
                                       ("Corrupt" "JOIN" "PART" "QUIT")))
  (add-to-list 'erc-server-alist '("EFnet: New York reverse proxy scanner" EFnet "irc.choopa.net" ((6665 6669)) 7000 9999))
  (add-to-list 'erc-server-alist '("Corrupt-Net" Corrupt "irc.corrupt-net.org" ((6666 6669)) 8067 6697 7000))
  ;(add-to-list 'erc-nickserv-alist '(Corrupt "NickServ!services@shd.u" "This\\s-nickname\\s-is\\s-registered\\s-and\\s-protected.\\s-\\s-If\\s-it\\s-is\\s-your" "NickServ" "IDENTIFY" nil nil "Password\\s-accepted\\s--\\s-you\\s-are\\s-now\\s-recognized."))
  (add-to-list 'erc-modules 'dcc);/dcc list and /dcc get -s nick file
  ;(add-to-list 'erc-modules 'notifications); requires notification-daemon from freedesktop.org
  (add-to-list 'erc-modules 'log)
  ;(add-to-list 'erc-modules 'services); nickserv
  (erc-update-modules))

(use-package eshell
  :ensure nil ; built-in
  :init (add-hook 'eshell-mode-hook #'(lambda () (add-to-list 'eshell-visual-commands "btm")))
  (bind-keys :map jam/open ("e" . jam/eshell))
  :commands (eshell)
  :config (require 'em-smart)
  (setq eshell-directory-name (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eshell")
        eshell-prefer-lisp-functions nil
        eshell-cmpl-cycle-completions t; replace # with : for prompt regex using /ssh:jam@10.0.0.1#6969:/tmp
        eshell-prompt-function #'(lambda () (concat (propertize (replace-regexp-in-string "[#$]" ":" (abbreviate-file-name (eshell/pwd))) 'face `(:foreground "green"))
                                                    (propertize " $ " 'face (if (= (user-uid) 0) `(:foreground "red") `(:foreground "white")))))))
(use-package eat
  ;:pin nongnu
  :init (bind-keys :map jam/open ("t" . eat))
  (add-hook 'eshell-load-hook #'eat-eshell-mode)
  (add-hook 'eshell-load-hook #'eat-eshell-visual-command-mode)
  :commands (eat eat-mode eat-eshell-mode eat-eshell-visual-command-mode)
  :config (bind-keys :map eat-mode-map ("C-S-v" . eat-yank)))

(use-package tramp
  :ensure nil ; built-in
  :commands (tramp)
  :config (add-to-list 'tramp-remote-path 'tramp-own-remote-path); use login shell for tramp
  (setq tramp-auto-save-directory (getenv "TMPDIR")
        tramp-persistency-file-name (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "tramp")))

(use-package company
  ;:pin gnu ; pin gnu for android
  :init (add-hook 'after-init-hook #'global-company-mode)
  (bind-keys :map jam/toggle ("a" . global-company-mode))
  (setq company-minimum-prefix-length 2
        company-tooltip-limit 14
        company-tooltip-align-annotations t
        company-require-match 'never
        company-global-modes
        '(not erc-mode
              message-mode
              help-mode
              ;eshell-mode
              gud-mode)
        company-frontends
        '(company-pseudo-tooltip-frontend  ; always show candidates in overlay tooltip
          company-echo-metadata-frontend)  ; show selected candidate docs in echo area
        company-backends '(company-capf company-yasnippet); company-ispell company-files company-keywords company-dabbrev
        company-auto-commit nil
        company-dabbrev-other-buffers nil
        company-dabbrev-ignore-case nil
        company-dabbrev-downcase nil)
  :commands (global-company-mode
             company-complete-common
             company-complete-common-or-cycle
             company-manual-begin
             company-grab-line)
  :config
  (require 'company-tng) ; TabNGo
  (company-tng-configure-default))

;; prompts for authinfo.gpg with format: machine gmail login your_user password your_password
;; C-u RET for unread and read, ! to save for offline/cache, U to manually subscribe, L list all groups, M-g to rescan group
(use-package gnus
  :ensure nil ; built-in
  :init (bind-keys :map jam/open ("g" . gnus))
  :commands (gnus)
  :config
  (setq
   gnus-save-newsrc-file nil
   gnus-read-newsrc-file nil
   ;gnus-use-dribble-file t
   ;gnus-always-read-dribble-file t
   gnus-dribble-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "gnus"))
   gnus-startup-file (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "gnus") "newsrc")
   gnus-select-method
          '(nnimap "gmail"
                   (nnimap-address "imap.gmail.com")
                   (nnimap-server-port 993)
                   (nnimap-stream ssl)
                   (nnir-search-engine imap)
                   (nnmail-expiry-target "nnimap+gmail:[Gmail]/Trash") ;; press 'E' to expire email
                   (nnmail-expiry-wait 90)) ;; @see http://www.gnu.org/software/emacs/manual/html_node/gnus/Expiring-Mail.html
          gnus-secondary-select-methods '((nnimap "riseup"
                                                  (nnimap-address "mail.riseup.net")
                                                  (nnimap-server-port 993)
                                                  (nnimap-stream ssl)
                                                  (nnir-search-engine imap)
                                                  (nnmail-expiry-wait 90)))
          gnus-use-cache t
          gnus-asynchronous t
          gnus-use-header-prefetch t
          message-send-mail-function 'smtpmail-send-it ;; Send email through SMTP
          smtpmail-default-smtp-server "smtp.gmail.com";"mail.riseup.net"
          smtpmail-smtp-service 587
          smtpmail-local-domain "localhost"
          gnus-thread-sort-functions '(gnus-thread-sort-by-most-recent-date (not gnus-thread-sort-by-number))
          gnus-read-active-file 'some ;; read only some
          gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject
          gnus-thread-hide-subtree t
          gnus-thread-ignore-subject t
          gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]"  ;; Make Gnus NOT ignore [Gmail] mailboxes
          gnus-use-correct-string-widths nil)
    (add-hook 'gnus-group-mode-hook 'gnus-topic-mode)
    (eval-after-load 'gnus-topic
      '(progn
         (setq gnus-message-archive-group '((format-time-string "sent.%Y"))
               gnus-server-alist `(("archive" nnfolder "archive" (nnfolder-directory ,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "archive"))
                                   (nnfolder-active-file ,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "archive") "active"))
                                   (nnfolder-get-new-mail nil)
                                   (nnfolder-inhibit-expiry t)))
               ;; "Gnus" is the root folder, and there are three mail accounts, "misc", "gmail", "riseup"
               gnus-topic-topology '(("Gnus" visible)
                                    (("misc" visible))
                                    (("gmail" visible nil nil))
                                    (("riseup" visible nil nil)))
               ;; each topic corresponds to a public imap folder
               gnus-topic-alist '(("gmail" ; the key of topic
                                   "nnimap+gmail:INBOX"
                                   "nnimap+gmail:[Gmail]/Sent Mail"
                                   "nnimap+gmail:[Gmail]/Trash"
                                   "nnimap+gmail:Drafts")
                                  ("riseup" ; the key of topic
                                   "nnimap+riseup:INBOX"
                                   "nnimap+riseup:Sent"
                                   "nnimap+riseup:Trash"
                                   "nnimap+riseup:Drafts")
                                  ("misc" ; the key of topic
                                   "nnfolder+archive:sent.2022"
                                   "nnfolder+archive:sent.2023"
                                   "nndraft:drafts")
                                  ("Gnus")))

         ;; see latest 200 mails in topic then press Enter on any group
         (gnus-topic-set-parameters "gmail" '((display . 200)))
         (gnus-topic-set-parameters "riseup" '((display . 200)))
         (gnus-subscribe-hierarchically "nnimap+riseup:INBOX")
         (gnus-subscribe-hierarchically "nnimap+riseup:Sent")
         (gnus-subscribe-hierarchically "nnimap+riseup:Trash")
         (gnus-subscribe-hierarchically "nnimap+riseup:Drafts")
         (gnus-subscribe-hierarchically "nnimap+gmail:INBOX")
         (gnus-subscribe-hierarchically "nnimap+gmail:[Gmail]/Sent Mail")
         (gnus-subscribe-hierarchically "nnimap+gmail:[Gmail]/Trash")
         (gnus-subscribe-hierarchically "nnimap+gmail:Drafts"))))

(use-package pcre2el
  ;:pin nongnu
  :commands (rxt-pcre-to-elisp
             rxt-elisp-to-pcre
             rxt-convert-pcre-to-rx
             rxt-convert-elisp-to-rx
             rxt-toggle-elisp-rx
             rxt-mode rxt-global-mode))

(use-package which-key
  ;:pin gnu
  :init (add-hook 'after-init-hook #'which-key-mode)
  :commands (which-key-mode))

(use-package yaml-mode
  ;:pin nongnu
  :commands yaml-mode
  :config (add-hook 'yaml-mode-hook #'(lambda () (setq-local tab-width yaml-indent-offset))))

;(use-package explain-pause-mode
  ;:vc (:url "https://github.com/lastquestion/explain-pause-mode" :rev :newest) ; MAYBE install from source with package.el or url-copy-file
;  :ensure nil ; BUG not in melpa
;  :init (bind-keys :map jam/open ("T" . explain-pause-top))
;  :commands (explain-pause-top explain-pause-mode))

;(use-package treesit ; libtreesitter-*.so
;  :ensure nil ; built-in
;  :init
;  (if (treesit-available-p)
;      (progn
;          (setq treesit-extra-load-path '("~/.guix-home/profile/lib/tree-sitter"))
;          ;(push '(python-mode . python-ts-mode) major-mode-remap-alist) ; MAYBE after lsp-mode > 8
;          (add-to-list 'auto-mode-alist '("\\.\\(e?ya?\\|ra\\)ml\\'" . yaml-ts-mode)))))

;(use-package combobulate
;  :init (setq combobulate-key-prefix "C-c e")
;  :hook ((python-ts-mode . combobulate-mode)
;         (yaml-ts-mode . combobulate-mode))
;  :load-path ("/gnu/git/combobulate"))


;;;###autoload
(defun jam/guix-env()
  "Guix variables for local guix daemon/client"
  (interactive)
  (setenv "GUIX_DAEMON_SOCKET" (concat (file-name-as-directory (xdg-data-home))
                                       (file-name-as-directory "guix")
                                       (file-name-as-directory "var")
                                       (file-name-as-directory "guix")
                                       (file-name-as-directory "daemon-socket") "socket"))
  (setenv "GUIX_DATABASE_DIRECTORY" (concat (file-name-as-directory (xdg-data-home))
                                            (file-name-as-directory "guix")
                                            (file-name-as-directory "var")
                                            (file-name-as-directory "guix") "db"))
  (setenv "GUIX_LOG_DIRECTORY" (concat (file-name-as-directory (xdg-data-home))
                                       (file-name-as-directory "guix")
                                       (file-name-as-directory "var")
                                       (file-name-as-directory "log") "guix"))
  (setenv "GUIX_STATE_DIRECTORY" (concat (file-name-as-directory (xdg-data-home))
                                         (file-name-as-directory "guix")
                                         (file-name-as-directory "var") "guix"))
  (setenv "GUIX_CONFIGURATION_DIRECTORY" (concat (file-name-as-directory (xdg-config-home))
                                                 (file-name-as-directory "guix") "etc"))
  (setenv "GUIX_LOCPATH" (concat (file-name-as-directory (xdg-data-home))
                                 (file-name-as-directory "guix")
                                 (file-name-as-directory "var")
                                 (file-name-as-directory "guix")
                                 (file-name-as-directory "profiles")
                                 (file-name-as-directory "per-user")
                                 (file-name-as-directory "root")
                                 (file-name-as-directory "guix-profile")
                                 (file-name-as-directory "lib") "locale"))
  (setenv "NIX_STORE" (concat (file-name-as-directory (xdg-data-home))
                              (file-name-as-directory "guix")
                              (file-name-as-directory "gnu") "store"))
  (setenv "PATH" (concat (getenv "PATH")
                         path-separator (concat (file-name-as-directory (xdg-data-home))
                                                (file-name-as-directory "guix") "bin"))))

;;;###autoload
(defun jam/replace-unicode ()
  "Replaces the following unicode characters:
ZERO WIDTH NO-BREAK SPACE (65279, #xfeff) aka BOM
ZERO WIDTH SPACE (codepoint 8203, #x200b)
RIGHT-TO-LEFT MARK (8207, #x200f)
RIGHT-TO-LEFT OVERRIDE (8238, #x202e)
LEFT-TO-RIGHT MARK ‎(8206, #x200e)
OBJECT REPLACEMENT CHARACTER (65532, #xfffc)"
  (interactive)
  (query-replace-regexp "\ufeff\\|\u200b\\|\u200f\\|\u202e\\|\u200e\\|\ufffc" ""))
