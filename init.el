;;; init.el -*- lexical-binding: t; -*-
(setq gc-cons-threshold (* 256 1024 1024)) ; 256 MiB default before gc

(bind-keys :prefix-map jam/code :prefix "C-c c" ; all bind maps under C-c c
           ("j" . xref-find-definitions)
           ("c" . compile))
(bind-keys :prefix-map jam/toggle :prefix "C-c c t"
           ("v" . visible-mode)
           ("w" . visual-line-mode)
           ("x" . xterm-mouse-mode)
           ("c" . global-display-fill-column-indicator-mode)
           ("t" . toggle-frame-maximized)
           ("f" . toggle-frame-fullscreen)
           ("F" . flymake-mode)
           ("r" . recentf-mode)
           ("m" . follow-mode)
           ("M" . scroll-lock-mode)
           ("e" . strokes-mode)
           ("g" . auto-revert-mode))
(bind-keys :prefix-map jam/open :prefix "C-c c o"
           ("s" . jam/sudo-edit)
           ("S" . speedbar-frame-mode)
           ("b" . browse-url-of-file)
           ("f" . make-frame)
           ("D" . jam/draw)
           ("z" . jam/mpv-play)
           ("u" . xwidget-webkit-browse-url) ; upstream needs ported to WPE for offscreen render crashing
           ("U" . eww-browse))
(bind-keys :prefix-map jam/insert :prefix "C-c c i"
           ("y" . cua-paste)
           ("u" . insert-char)
           ("s" . yas-insert-snippet)
           ("e" . emojify-insert-emoji)
           ("b" . bookmark-set)
           ("R" . re-builder)
           ("r" . string-insert-rectangle))
(bind-keys :prefix-map jam/search :prefix "C-c c s"
           ("l" . shr-copy-url)
           ("L" . ffap-menu)
           ("i" . imenu)
           ("a" . apropos)
           ("c" . keep-lines)
           ("m" . bookmark-jump))
(bind-keys :prefix-map jam/file :prefix "C-c c f"
           ("d" . dired)
           ("f" . recentf-open)
           ("i" . image-crop)
           ("s" . jam/screenshot))
(bind-keys :prefix-map jam/quit :prefix "C-c c q"
           ("f" . delete-frame)
           ("d" . server-start) ;daemon
           ("D" . server-force-delete)
           ("q" . kill-emacs)
           ("r" . restart-emacs)
           ("Q" . save-buffers-kill-terminal)
           ("K" . save-buffers-kill-emacs))
(bind-keys :prefix-map jam/notes :prefix "C-c c n")

(use-package emacs ; built-in ;; Movement: f b n p, a e, M-g-g, F3/F4 for macros
  :hook (((prog-mode text-mode) . (lambda () (setq show-trailing-whitespace t)))
         (tty-setup . xterm-mouse-mode)
         (after-init . (lambda () (message "after-init-hook running after %s" (float-time (time-subtract after-init-time before-init-time)))
                         (setq file-name-handler-alist default-file-name-handler-alist ;; restore default
                               default-file-name-handler-alist nil
                               modus-themes-mode-line '(accented borderless); theme
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
                                                          (popup . (accented))))
                           (fido-vertical-mode 1) ; M-j to ignore completion
                           (window-divider-mode 1)
                           (display-time-mode 1)
                           (delete-selection-mode 1)
                           (run-with-idle-timer 15 t (lambda () (garbage-collect))) ; collect gc every 15s while idle
                           (blink-cursor-mode -1);(pixel-scroll-precision-mode 1) ; smooth scrolling ; BUG disables minibuffer completion scrolling
                           (electric-pair-mode 1) ; less typing
                           (context-menu-mode 1); mouse right click menu
                           (url-handler-mode 1) ; open urls in buffers
                           ;(advice-add 'completion-at-point :after #'minibuffer-hide-completions)
                           (load-theme 'modus-vivendi-tinted); built-in does not need to hook server-after-make-frame-hook for daemonp
                           (cua-mode 1))))
  :bind (("<M-up>" . (lambda () (interactive) (transpose-lines 1) (forward-line -2))); move line up
         ("<M-down>" . (lambda () (interactive) (forward-line 1) (transpose-lines 1) (forward-line -1))); move line down
         ("<M-left>" . (lambda () (interactive) (transpose-words -1))); move word left
         ("<M-right>" . (lambda () (interactive) (transpose-words 1)));move word right
         ("C-+" . text-scale-increase)
         ("C--" . text-scale-decrease)
         :map ctl-x-map ("C-S-s" . jam/save-all)
         :map emacs-lisp-mode-map ("C-c C-S-f" . pp-buffer)
         :map help-map ("D" . shortdoc)
         :map window-prefix-map ; C-x 1 C-x o ; (windmove-default-keybindings 'control) ; winner-mode?
           ("w" . windmove-up)
           ("a" . windmove-left)
           ("s" . windmove-down)
           ("d" . windmove-right)
           ("f" . select-frame-by-name)
           ("D" . toggle-window-dedicated)
           ("o" . other-frame)
         :map minibuffer-local-completion-map
         ("<mouse-1>" . (lambda (event) (interactive "e"); call the completion candidate at the row location of EVENT in the minibuffer (choose-completion event ?)
                          (with-selected-window (active-minibuffer-window)
                            (when-let ((object (posn-object (event-end event)))
                                       (colrow (posn-col-row (event-end event)))
                                       ((and (consp object) (>= (cdr colrow) 1)))
                                       (cand (car (split-string (nth (- (cdr colrow) 1) (split-string (car object) "[\n\r]+" t "[ ]+"))))))
                              (if (string-search "Find file:" (minibuffer-prompt))
                                  (progn ; replace end of directory with candidate
                                    (let* ((revd-str (reverse (buffer-substring (minibuffer-prompt-end) (point))))
                                           (end-index (or (seq-position revd-str ?/) (seq-position revd-str ?\\)))
                                           (cand (if end-index (concat (buffer-substring (minibuffer-prompt-end) (- (point) end-index)) cand) cand)))
                                      (delete-minibuffer-contents); clear and insert candidate
                                      (insert (format "%s" cand))))
                                (delete-minibuffer-contents)
                                (insert (format "%s" cand)))
                              (minibuffer-complete-and-exit)))))
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
  :init (setq backup-directory-alist `(("." . ,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache"))))
              auto-save-list-file-prefix (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "auto-save-list") ".saves-")
              recentf-save-file (expand-file-name "recentf" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              bookmark-default-file (expand-file-name "bookmarks" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache"))) ; bookmarks support annotations
              project-list-file (expand-file-name "projects" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              url-cookie-file (expand-file-name "cookies" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              url-cache-directory (expand-file-name "cache" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              nsm-settings-file (expand-file-name "network-security.data" (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache")))
              auth-sources (list (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "authinfo.gpg") (concat (file-name-as-directory (getenv "HOME")) ".authinfo")) ; auth
              display-line-numbers-type t ; defaults
              apropos-do-all t
              xterm-set-window-title t
              xterm-extra-capabilities '(getSelection setSelection) ; osc term copy/paste
              visible-cursor nil
              isearch-wrap-pause 'no-ding ; wrap isearch
              ad-redefinition-action 'accept ; ignore warnings
              ;completion-auto-help 'lazy; '?' for help w/mouse click
              completion-cycle-threshold nil ; flex narrowing instead of cycling
              completions-format 'one-column
              completions-group t
              completion-styles '(basic initials substring partial-completion)
              completions-detailed t
              completions-sort 'historical
              ;completion-auto-select 'second-tab
              icomplete-scroll t
              column-number-mode t
              sentence-end-double-space nil
              require-final-newline t
              bidi-inhibit-bpa t ; some naughty unicodes
              bidi-paragraph-direction 'left-to-right
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
              tool-bar-mode nil ; modifier-bar-mode t; gui controls for android
              touch-screen-display-keyboard t
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
              ;jit-lock-defer-time 0.05 ; fontification delay
              read-process-output-max (* 64 1024)
              ;gc-cons-threshold (* 256 1024 1024) ; 256 MiB default before gc
              load-prefer-newer t; noninteractive
              auto-mode-case-fold nil
              kill-do-not-save-duplicates t
              edebug-print-length nil ; print whole edebug result
              browse-url-browser-function 'eww-browse-url ;'xwidget-webkit-browse-url ; libxml-parse-html-region w/ shr
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
              xref-search-program 'ripgrep ; replace grep with ripgrep
              ;enable-local-variables :all ; RISKY use safe-local-variable-directories
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
  (if (not (memq window-system '(android))) ; old fdroid android builds do not enable gnutls. Use sourceforge build w/termux for utils https://sourceforge.net/projects/android-ports-for-gnu-emacs/files/termux/ ex. emacs-30.0.50-29-arm64-v8a.apk
      (progn
        (setq menu-bar-mode nil) ; disable menu-bar on non android
        (add-to-list 'default-frame-alist '(menu-bar-lines . 0)))
    (add-to-list 'default-frame-alist '(tool-bar-position . bottom))
    (add-to-list 'initial-frame-alist '(tool-bar-position . bottom))
    (setenv "PATH" (format "%s:%s" "/data/data/com.termux/files/usr/bin" (getenv "PATH"))) ;; set android termux paths for call-process
    (setenv "LD_LIBRARY_PATH" (format "%s:%s" "/data/data/com.termux/files/usr/lib" (getenv "LD_LIBRARY_PATH")))
    (push "/data/data/com.termux/files/usr/bin" exec-path))
  (setq-default indent-tabs-mode nil
                tab-width 4
                tab-always-indent 'complete
                word-wrap t)
  (add-to-list 'default-frame-alist '(tool-bar-lines . 0)) ; disable w/o loading mode
  (add-to-list 'default-frame-alist '(vertical-scroll-bars))
  (set-frame-parameter nil 'alpha-background 80)
  (add-to-list 'default-frame-alist '(alpha-background . 80))
  (add-to-list 'initial-frame-alist '(alpha-background . 80))
  (set-language-environment "UTF-8"))

(use-package desktop
  :ensure nil ; built-in
  :config (setq desktop-path `(,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "desktop-session"))))
  :bind (:map jam/open ("d" . desktop-read)
         :map jam/file ("D" . desktop-save-in-desktop-dir))
  :commands (desktop-read desktop-save-in-desktop-dir))

(use-package calc
  :ensure nil ; built-in
  :commands (calc calc-algebraic-entry) ; a S to solve for var ex. x=y+1
  :config (with-temp-buffer (calc)); calc-graph-fast ex. [0..10] then x+1 on stack
  :bind (:map jam/open ("a" . calc-algebraic-entry)))

(use-package proced
  :ensure nil ; built-in
  :commands proced
  :bind (:map jam/open ("P" . proced)) ; T to toggle tree, k/x to kill, f filter
  :config
  ;(defun my-proced-node-name (attrs)
  ;  (cons 'node (or (when (string-prefix-p "java" (cdr (assq 'comm attrs)))
  ;                    (let ((args (cdr (assq 'args attrs))))
  ;                      args))
  ;                  "")))
  ;(add-to-list 'proced-custom-attributes 'my-proced-node-name)
  ;(add-to-list 'proced-grammar-alist '(node "My Node" "%s" left proced-string-lessp nil (node pid) (nil t nil)))
  ;(add-to-list 'proced-format-alist '(java user pid tree pcpu pmem start time node (args comm)));F then type java
  ;(add-to-list 'proced-filter-alist '(beam (comm . "^beam")));f then type beam
  (setq-default proced-enable-color-flag t
                proced-filter 'all
                proced-show-remote-processes t
                proced-tree-flag t
                proced-auto-update-flag t))

(use-package org-crypt
  :ensure nil ; built-in
  :commands (org-encrypt-entries org-encrypt-entry org-decrypt-entries org-decrypt-entry))

(use-package org-clock
  :ensure nil ; built-in
  :bind (:map jam/notes ("g" . org-clock-goto))
  :commands (org-clock-goto org-clock-in org-clock-cancel))

(use-package org-timer
  :ensure nil; built-in
  :bind (:map jam/open ("c" . org-timer-set-timer))
  :config (with-temp-buffer (org-mode)) ; hack to load org
  :commands (org-timer-set-timer))

(use-package org
  :ensure nil ; built-in
  :commands (org-mode org-agenda org-capture org-todo-list org-id-update-id-locations)
  :config (setq org-timer-default-timer 60
                org-src-tab-acts-natively nil
                org-edit-src-content-indentation 0)
  :bind (:map jam/notes
              ("D" . org-id-update-id-locations)
              ("t" . org-todo-list)
              ("a" . org-agenda)))

(use-package dired ;; M-j newline in regex
  :ensure nil ; built-in
  :config (setq dired-dwim-target t
                dired-hide-details-hide-symlink-targets nil
                dired-auto-revert-buffer #'dired-buffer-stale-p
                dired-listing-switches "-alh"
                dired-recursive-copies 'always
                dired-recursive-deletes 'top
                dired-create-destination-dirs 'ask)
  :commands (dired dired-jump dired-other-frame dired-other-tab dired-other-window)
  :bind (:map jam/open ("-" . dired-jump)))

(use-package password-store
  :ensure nil ; built-in
  :bind (:map jam/open ("p" . jam/auth-display))
  :commands (auth-source-search auth-info-password auth-source-pick-first-password auth-source-forget+ auth-source-forget auth-source-delete))

(use-package eglot
  :ensure nil ; built-in
  :bind (:map jam/code ("a" . eglot-code-actions))
  :hook (((rust-ts-mode rust-mode) . eglot-ensure))
  :custom (eglot-send-changes-idle-time 0.1)
  :config (fset #'jsonrpc--log-event #'ignore); stop logging
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) . ; set RA_LOG=rust_analyzer=info for logs
                 ("rust-analyzer" :initializationOptions (:check (:command "clippy" :allTargets :json-false :workspace :json-false);:checkOnSave :json-false ;(:command "clippy")
                                                          :cargo (:cfgs (:extraArgs ["offline"] ;:features "all"; :noDefaultFeatures t; :buildScripts (:enable :json-false)
                                                                         :tokio_unstable "")))))))

(use-package hideshow
  :ensure nil ; built-in
  :bind (:map jam/toggle ("z" . hs-minor-mode)
         :map jam/code ("z" . hs-toggle-hiding)
                       ("v" . hs-hide-block))
  :commands (hs-minor-mode hs-toggle-hiding hs-hide-block hs-hide-level hs-show-all hs-hide-all)
  :config (setq hs-special-modes-alist (append '((yaml-ts-mode "\\s-*\\_<\\(?:[^:]+\\)\\_>" "" "#")
                                                 (nxml-mode "<!--\\|<[^/>]*[^/]>" "-->\\|</[^/>]*[^/]>" "<!--" sgml-skip-tag-forward nil))
                                               hs-special-modes-alist)))

(use-package erc
  :ensure nil ; built-in
  :bind (:map jam/open ("i" . erc-tls))
  :commands (erc-tls erc) ; add bot msg to erc-nickserv-identified-hook?
  :config (setq erc-rename-buffers t
                erc-interpret-mirc-color t
                erc-save-buffer-on-part t
                erc-log-insert-log-on-open t
                erc-log-channels-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") "erc")
                erc-nick '("jaming")
                erc-user-full-name "jaming"
                erc-keywords '("jaming")
                erc-server-history-list '("irc.rizon.net" "irc.libera.chat" "irc.choopa.net" "irc.corrupt-net.org")
                erc-autojoin-timing 'ident
                erc-autojoin-delay 30
                erc-max-buffer-size 20000
                erc-prompt-for-nickserv-password nil
                ;erc-nickserv-passwords '((Corrupt (("nickname" . "password"))))
                erc-use-auth-source-for-nickserv-password t; format: machine irc.site.net login your_nickname password your_password
                ;erc-sasl-mechanism 'ecdsa-nist256p-challenge ; expects key file for erc-sasl-password
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
                                              ("Rizon" "#subsplease") ("EFnet" "#srrdb")
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
  (add-to-list 'erc-modules 'notifications); requires notification-daemon from freedesktop.org
  (add-to-list 'erc-modules 'log)
  (add-to-list 'erc-modules 'services); nickserv
  ;(add-to-list 'erc-modules 'sasl)
  (erc-update-modules))

(use-package eshell
  :ensure nil ; built-in
  :hook ((eshell-mode . (lambda () (add-to-list 'eshell-visual-commands "btm"))))
  :bind (:map jam/open ("e" . jam/eshell))
  :commands (eshell)
  :config (require 'em-smart)
  (setq eshell-directory-name (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eshell")
        eshell-prefer-lisp-functions nil
        ;pcomplete-remote-file-ignore t
        eshell-cmpl-cycle-completions t; replace # with : for prompt regex using /ssh:jam@10.0.0.1#6969:/tmp
        eshell-prompt-function #'(lambda () (concat (propertize (replace-regexp-in-string "[#$]" ":" (abbreviate-file-name (eshell/pwd))) 'face `(:foreground "green"))
                                                    (propertize " $ " 'face (if (= (user-uid) 0) `(:foreground "red") `(:foreground "white")))))))

(use-package tramp
  :ensure nil ; built-in
  :commands (tramp)
  :config (add-to-list 'tramp-remote-path 'tramp-own-remote-path); use login shell for tramp
  (setq tramp-auto-save-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "tramp-autosave")
        tramp-persistency-file-name (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "tramp")))

(use-package completion-preview
  :ensure nil ; built-in
  :hook ((after-init . global-completion-preview-mode))
  :bind (:map completion-preview-active-mode-map
              ("M-n" . completion-preview-next-candidate)
              ("M-p" . completion-preview-prev-candidate))
  :config
  (setq ;completion-preview-idle-delay 0.2
   completion-preview-minimum-symbol-length 2))

(use-package gnus ;; M-u for unread, ! to save for offline/cache, U to manually subscribe, L list all groups, g to rescan all groups or gnus-group-get-new-news-this-group, c to read all
  :ensure nil ; built-in
  :bind (:map jam/open ("g" . gnus)
         :map jam/file ("u" . gnus-cloud-upload-all-data)
                       ("a" . gnus-cloud-download-all-data))
  :commands (gnus gnus-setup-news-hook)
  :config
  ;(gnus-demon-add-handler 'gnus-demon-scan-news 2 t); show notifications on new mail
  ;(add-hook 'gnus-after-getting-new-news-hook #'gnus-notifications); set level of group for notification (nneething to watch dir)
  (setq
   gnus-save-newsrc-file nil
   gnus-read-newsrc-file nil
   gnus-use-dribble-file nil;t
   gnus-always-read-dribble-file nil;t
   gnus-cloud-synced-files `(,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "authinfo.gpg"))
   gnus-cloud-method "nnimap:riseup" ; gnus-cloud-download-all-data gnus-cloud-upload-all-data
   gnus-cloud-storage-method nil; disable epg for just ascii armored file
   gnus-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "gnus"))
   gnus-cache-directory (concat gnus-directory (file-name-as-directory "cache"))
   gnus-dribble-directory gnus-directory
   gnus-startup-file (concat gnus-directory "newsrc")
   gnus-select-method '(nnnil ""); / N or M-g inside summary to refresh, / o for read articles
   gnus-secondary-select-methods '((nnatom "wingolog.org/feed/atom")(nnatom "guix.gnu.org/feeds/blog.atom") (nnatom "www.reddit.com/r/news/.rss") (nnatom "blog.torproject.org/rss.xml") (nnatom "youtube.com/feeds/videos.xml?channel_id=UC4w1YQAJMWOz4qtxinq55LQ"); youtube rss id comes from inspect source on channel page for external-id/externalId ex: https://www.youtube.com/feeds/videos.xml?channel_id=UC4w1YQAJMWOz4qtxinq55LQ ; do not include http/https/www
                                   (nnatom "github.com/jellyfin/jellyfin/releases.atom") (nnatom "github.com/emacs-mirror/emacs/tags.atom") ; not used: https://savannah.gnu.org/news/atom.php?group=emacs
                                   ;(nntp "news.newsgroupdirect.com"); ^ or Shift 6  to list all groups after username/password prompt ; gnus-binary-mode g for uudecode
                                   (nnimap "riseup" (nnimap-address "mail.riseup.net") (nnimap-server-port 993) (nnimap-stream ssl) (nnir-search-engine imap) (nnmail-expiry-wait 90)) ; prompts for authinfo.gpg with format: machine gmail login your_user password your_password
                                   (nnimap "gmail" (nnimap-address "imap.gmail.com") (nnimap-server-port 993) (nnimap-stream ssl) (nnir-search-engine imap) (nnmail-expiry-target "nnimap+gmail:[Gmail]/Trash") (nnmail-expiry-wait immediate)); 'B m' to move, 'B DEL' to delete, 'E' is expire with 'B e'. Mark with '#' for mass operations.  x to execute
                                   ;(nneething "/tmp"); G m for solid or G D for ephemeral (gnus-group-enter-directory) (over ange-ftp /ftp.hpc.uh.edu:/pub/emacs/ding-list/ ?)
                                   )
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
  (add-hook 'gnus-after-getting-new-news-hook #'gnus-notifications)
  (add-hook 'gnus-group-mode-hook 'gnus-topic-mode)
  (eval-after-load 'gnus-topic
    '(progn
       (require 'epa)
       (advice-add 'gnus-cloud-download-all-data :before 'epa-file-disable); prevent encryption when syncing as authinfo.gpg
       (advice-add 'gnus-cloud-download-all-data :after 'epa-file-enable)
       (setq gnus-cloud-sequence 1) ; set to 0 for init sync
       (require 'nnrss) ; setup rss feeds.
       (setq nnrss-group-alist '(("phoronix" "https://www.phoronix.com/rss.php" "Tech stuff") ("lunduke" "https://api.substack.com/feed/podcast/462466.rss" "Lunduke articles") ("bram" "https://bramcohen.com/feed" "Bram blog") ("lwn" "https://lwn.net/headlines/newrss" "Linux stuff") ("lobste" "https://lobste.rs/rss" "Tech lobsters"))); https://www.bitchute.com/feeds/rss/channel/Styxhexenhammer666 https://cacm.acm.org/feed/ https://codeberg.org/gnuastro/gnuastro.rss
       (nnrss-save-server-data nil)
       (setq gnus-message-archive-group '((format-time-string "sent.%Y"))
             gnus-server-alist `(("archive" nnfolder "archive" (nnfolder-directory ,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "archive"))
                                  (nnfolder-active-file ,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "archive") "active"))
                                  (nnfolder-get-new-mail nil)
                                  (nnfolder-inhibit-expiry t)))
             gnus-topic-topology '(("Gnus" visible);"Gnus" is the root folder. three mail accounts, "gmail", "riseup", "misc" then the nnatom feeds
                                   (("gmail" visible nil nil)) (("riseup" visible nil nil)) (("misc" visible))
                                   (("Releases" visible)) (("Level1Techs" visible)) (("wingolog" visible)) (("Guix" visible)) (("Reddit" visible)) (("Tor" visible)))
             gnus-topic-alist '(("gmail" "nnimap+gmail:INBOX" "nnimap+gmail:[Gmail]/All Mail" "nnimap+gmail:[Gmail]/Sent Mail" "nnimap+gmail:[Gmail]/Spam" "nnimap+gmail:[Gmail]/Trash" "nnimap+gmail:Drafts")
                                ("riseup" "nnimap+riseup:INBOX" "nnimap+riseup:Sent" "nnimap+riseup:Trash" "nnimap+riseup:Drafts" "nnimap+riseup:Emacs-Cloud")
                                ("misc" "nnfolder+archive:sent.2024" "nnfolder+archive:sent.2025" "nndraft:drafts"); the key of topic corresponds to a public imap folder or feed
                                ("Level1Techs" "nnatom+youtube.com/feeds/videos.xml?channel_id=UC4w1YQAJMWOz4qtxinq55LQ:Level1Techs") ("wingolog" "nnatom+wingolog.org/feed/atom:wingolog") ("Guix" "nnatom+guix.gnu.org/feeds/blog.atom:GNU Guix — Blog") ("Reddit" "nnatom+www.reddit.com/r/news/.rss:News") ("Tor" "nnatom+blog.torproject.org/rss.xml:Tor Project blog")
                                ("Releases" "nnatom+github.com/emacs-mirror/emacs/tags.atom:Tags from emacs" "nnatom+github.com/jellyfin/jellyfin/releases.atom:Release notes from jellyfin")
                                ("Gnus")))
       (gnus-topic-set-parameters "gmail" '((display . 200))) (gnus-topic-set-parameters "riseup" '((display . 200))); see latest 200 mails in topic then press Enter on any group
       (gnus-subscribe-hierarchically "nnimap+riseup:INBOX") (gnus-subscribe-hierarchically "nnimap+riseup:Sent") (gnus-subscribe-hierarchically "nnimap+riseup:Trash") (gnus-subscribe-hierarchically "nnimap+riseup:Drafts")(gnus-subscribe-hierarchically "nnimap+riseup:Emacs-Cloud")
       (gnus-subscribe-hierarchically "nnimap+gmail:INBOX") (gnus-subscribe-hierarchically "nnimap+gmail:[Gmail]/All Mail") (gnus-subscribe-hierarchically "nnimap+gmail:[Gmail]/Sent Mail") (gnus-subscribe-hierarchically "nnimap+gmail:[Gmail]/Trash") (gnus-subscribe-hierarchically "nnimap+gmail:[Gmail]/Spam") (gnus-subscribe-hierarchically "nnimap+gmail:Drafts")
       (gnus-subscribe-hierarchically "nnatom+youtube.com/feeds/videos.xml?channel_id=UC4w1YQAJMWOz4qtxinq55LQ:Level1Techs") (gnus-subscribe-hierarchically "nnatom+wingolog.org/feed/atom:wingolog") (gnus-subscribe-hierarchically "nnatom+guix.gnu.org/feeds/blog.atom:GNU Guix — Blog") (gnus-subscribe-hierarchically "nnatom+www.reddit.com/r/news/.rss:News") (gnus-subscribe-hierarchically "nnatom+blog.torproject.org/rss.xml:Tor Project blog");"nnatom+odysee.com/$/rss/@Styxhexenhammer666:2:Styxhexenhammer666 on Odysee"
       (gnus-subscribe-hierarchically "nnatom+github.com/emacs-mirror/emacs/tags.atom:Tags from emacs") (gnus-subscribe-hierarchically "nnatom+github.com/jellyfin/jellyfin/releases.atom:Release notes from jellyfin") ; https://gantnews.com/category/police-logs/feed/
       (gnus-subscribe-hierarchically "nnrss:bram") (gnus-subscribe-hierarchically "nnrss:lwn") (gnus-subscribe-hierarchically "nnrss:lunduke") (gnus-subscribe-hierarchically "nnrss:lobste") (gnus-subscribe-hierarchically "nnrss:phoronix")
       ))
  )

(use-package which-key
  :ensure nil ; built-in
  :hook (after-init . which-key-mode)
  :commands (which-key-mode))

(use-package flymake ; add flycheck backends?
  :ensure nil ; built-in
  :config (setq flymake-indicator-type 'margins)
  :commands (flymake-mode))

(use-package epa ; gpg
  :ensure nil ; built-in
  :defer t
  :config (setq epa-file-cache-passphrase-for-symmetric-encryption t
                epa-armor t ; ascii armored output
                epg-pinentry-mode 'loopback) ; minibuffer for gpg input instead of 'allow-loopback-pinentry' in ~/.gnupg/gpg-agent.conf
  (require 'xdg)
  (let ((gpg-dir (concat (file-name-as-directory (xdg-data-home)) "gnupg")))
    (setenv "GNUPGHOME" gpg-dir) ; setup gnupg
    (if (not (file-directory-p gpg-dir)) (make-directory gpg-dir t))))

(use-package flyspell ; aspell
  :ensure nil ; built-in
  :bind (:map jam/toggle ("s" . flyspell-mode))
  :hook (((org-mode markdown-mode TeX-mode rst-mode message-mode git-commit-mode) . flyspell-mode)
         ((yaml-mode conf-mode prog-mode) . flyspell-prog-mode))
  :commands (flyspell-mode)
  :config (setq flyspell-issue-welcome-flag nil
                flyspell-issue-message-flag nil
                ispell-program-name "aspell" ; runs as own process
                ispell-extra-args '("--sug-mode=ultra"
                                    "--run-together")
                ispell-personal-dictionary (expand-file-name (concat (file-name-as-directory "ispell") ispell-dictionary ".pws") (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc")))
                ispell-aspell-dict-dir (ispell-get-aspell-config-value "dict-dir")
                ispell-aspell-data-dir (ispell-get-aspell-config-value "data-dir")))

(use-package treesit ; libtreesitter-*.so
  :ensure nil ; built-in
  :init
  (if (treesit-available-p)
      (progn
        (add-to-list 'treesit-extra-load-path "/usr/lib")
        (add-to-list 'treesit-extra-load-path "~/.guix-home/profile/lib/tree-sitter")
        (push '(python-mode . python-ts-mode) major-mode-remap-alist)
        (add-to-list 'auto-mode-alist '("\\.\\(e?ya?\\|ra\\)ml\\'" . yaml-ts-mode)))))

(use-package yaml-ts-mode
  :ensure nil ; built-in
  :commands (yaml-ts-mode))

(use-package rust-ts-mode
  :ensure nil ; built-in
  :mode "\\.rs\\'"
  :commands (rust-ts-mode)
  :config (jam/set-rust-path))

(use-package python ; python
  :ensure nil ; built-in
  :commands (python-mode python-mode-hook python-mode-local-vars-hook python-ts-mode python-ts-mode-hook))

(use-package flymake-guile ; guile/guild
  :commands (flymake-guile)
  :hook (scheme-mode . flymake-guile)
  :hook (scheme-mode . flymake-mode))

(use-package pyvenv ; python ; projects can install pydebug and pylsp inside venv
  :init (add-hook 'pyvenv-post-activate-hooks #'eglot-ensure)
  :hook (((python-mode python-ts-mode) . pyvenv-tracking-mode))
  :commands (pyvenv-mode pyvenv-activate pyvenv-tracking-mode pyvenv-post-activate-hooks))

(use-package guix ; guix
  :config (require 'guix-autoloads)
  (guix-set-emacs-environment (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") "profile"))
  (guix-set-emacs-environment (concat (file-name-as-directory (getenv "HOME")) ".guix-profile"));(guix-emacs-autoload-packages); set EMACSLOADPATH
  :commands (guix-popup guix-set-emacs-environment))

(use-package geiser ; guile
  :hook ((scheme-mode . geiser-mode))
  :commands (geiser geiser-mode geiser-mode-hook geiser-repl-mode geiser-repl-mode-hook)
  :config
  (setq geiser-repl-per-project-p t
        geiser-repl-current-project-function #'geiser-repl-project-root
        geiser-repl-history-filename (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "geiser-history"))
  (require 'geiser-guile)); geiser call per buffer?

(use-package macrostep-geiser ; guile
  :hook (((geiser-mode geiser-repl-mode) . macrostep-geiser-setup))
  :commands (macrostep-geiser-setup))

(use-package geiser-guile ; guile
  :init (with-eval-after-load 'geiser-guile
          (require 'xdg)
          (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (xdg-config-home)) (file-name-as-directory "guix") (file-name-as-directory "current") (file-name-as-directory "share") (file-name-as-directory "guile") (file-name-as-directory "site") "3.0")) ; source
          (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (xdg-config-home)) (file-name-as-directory "guix") (file-name-as-directory "current") (file-name-as-directory "lib") (file-name-as-directory "guile") (file-name-as-directory "3.0") "site-ccache")) ; compiled
          (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "share") (file-name-as-directory "guile") (file-name-as-directory "site") "3.0"))
          (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "share") (file-name-as-directory "guile") "3.0"))
          (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "lib") (file-name-as-directory "guile") (file-name-as-directory "3.0") "site-ccache"))
          (add-to-list 'geiser-guile-load-path (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "lib") (file-name-as-directory "guile") (file-name-as-directory "3.0") "ccache")))
  :commands (geiser-guile))

(use-package undo-tree
  ;:pin gnu
  :hook ((after-init . global-undo-tree-mode))
  :commands (global-undo-tree-mode)
  :custom (undo-tree-history-directory-alist `(("." . ,(concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "undo-tree-hist")))))
  :config (setq undo-tree-visualizer-diff t
                undo-tree-auto-save-history t
                undo-limit 800000 ; 800 kb (default 160kb)
                undo-strong-limit 12000000 ; 12mb (default 240kb)
                undo-outer-limit 128000000 ; 128mb (default 24mb)
                undo-tree-enable-undo-in-region t))

(use-package magit ; git ; magit-diff then magit-patch to save
  :commands (magit-file-delete magit-status)
  :bind (:map jam/open ("m" . magit-status)
         :map magit-mode-map ("q" . kill-buffer)
         :map transient-map ([escape] . transient-quit-one))
  :init
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
  (add-hook 'magit-process-mode-hook #'goto-address-mode)); magit-generate-changelog after magit-create-commit for commit msg

(use-package forge ; git ;; authinfo machine api.github.com login USERNAME^forge password 012345abcdef...
  :after magit
  :commands (forge-pull forge-add-repository forge-list-issues forge-list-pullreqs forge-list-notifications forge-list-repositories forge-create-issue forge-create-pullreq)
  :init (setq forge-database-file (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "etc") (file-name-as-directory "forge") "forge-database.sqlite"))
  (setq forge-add-default-bindings t))

(use-package transmission ; C-u universal arg for directory prompt ; transmission
  :commands (transmission transmission-add))

(use-package org-roam ; sqlite-available-p ;; C-u C-c . for agenda with timestamp or org-time-stamp-inactive for no agenda version
  :commands (org-roam-node-find org-roam-node-insert org-roam-dailies-goto-date org-roam-dailies-goto-today org-roam-graph org-roam-db-autosync-enable)
  :bind (:map jam/file ("r" . org-roam-node-find)
         :map jam/notes
              ("T" . org-roam-dailies-capture-today)
              ("d" . org-roam-dailies-goto-date)
              ("r" . org-roam-capture)
              ("R" . org-roam-dailies-capture-date)
              ("i" . org-roam-node-insert)
              ("N" . org-roam-db-sync)
              ("n" . org-roam-node-find))
  :init (setq org-roam-directory (concat (expand-file-name user-emacs-directory) (file-name-as-directory "org") (file-name-as-directory "roam"))
              org-directory org-roam-directory
              org-id-locations-file (expand-file-name ".orgids" org-directory) ; org-id-update-id-locations org-roam-db-sync
              org-clock-sound (expand-file-name "alert.wav" org-directory) ; play-sound-file (from flac --decode)
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
                                                                                      "#+HTML_CONTENT_CLASS: container \n"
                                                                                      "#+HTML_DOCTYPE: html5 \n"
                                                                                      "#+INCLUDE: \"css.org::navbar\" :only-contents t \n"))
                                            :unnarrowed t))))

(use-package osm ; curl
  ;:pin gnu
  :bind (:map jam/open ("o" . osm-home)) ;(with-eval-after-load 'org (require 'osm-ol))
  :commands (osm-home osm-search)
  :config (setq osm-tile-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (file-name-as-directory "osm")))
  :custom (osm-copyright nil))

(use-package minions ; hide minor modes on modeline
  :hook ((after-init . minions-mode))
  :commands (minions-mode))

(use-package debbugs
  ;:pin gnu
  :bind (:map jam/search ("b" . debbugs-gnu-bugs)); bug number search
  :commands (debbugs-gnu debbugs-gnu-tagged debbugs-org debbugs-org-tagged debbugs-org-mode debbugs-gnu-bugs debbugs-gnu-guix-search debbugs-org-guix-search)
  :config ;(setq org-link-elisp-confirm-function nil)
  (setq debbugs-gnu-default-packages '("guix-patches"))
  (require 'debbugs-guix) (require 'debbugs-org) (require 'debbugs-gnu) (require 'debbugs-browse)); C-u M-x debbugs-gnu guix-patches n y then tag with t

(use-package eat
  ;:pin nongnu
  :bind (:map jam/open ("t" . eat)
         :map eat-mode-map ("C-S-v" . eat-yank))
  :hook ((eshell-load . eat-eshell-mode)
         (eshell-load . eat-eshell-visual-command-mode))
  :commands (eat eat-mode eat-eshell-mode eat-eshell-visual-command-mode))

(use-package dape ; Extract adapter https://github.com/vadimcn/codelldb/releases unzip codelldb-<platform>-<os>.vsix -d ~/.emacs.d/.local/debug-adapters/codelldb
  :bind (:map jam/code ("d" . dape))
  :config (setq dape-adapter-dir (concat user-emacs-directory (file-name-as-directory ".local") "debug-adapters"))
  :commands (dape))

(use-package gptel ; optional curl
  ;:pin nongnu
  :commands (gptel-send gptel gptel-menu gptel-add gptel-add-file gptel)
  :config
  (setq gptel-model 'exaone-deep:7.8b ;qwen2.5-coder:14b;qwen2.5-vl:3b
        gptel-backend (gptel-make-openai "llama-cpp" :protocol "http" ;gptel-make-ollama "Ollama"
                                         :host "localhost:8080";"localhost:11434"
                                         :models '((exaone-deep:7.8b)
                                                   (gemma-3:27B :capabilities (media));:mime-types ("image/jpeg" "image/png")
                                                   (deepseek-r1:14b))
                                         :stream t)))

;(use-package llm-tool-collection
;  :after (gptel)
;  :vc (:url "https://github.com/skissue/llm-tool-collection" :rev "304a06aacbe77ce0ee5f2a6c9063d4a3a4bfda22")
;  :config ;(apply #'gptel-make-tool (llm-tool-collection-get "read_file"))
;  (mapcar (apply-partially #'apply #'gptel-make-tool) (llm-tool-collection-get-category "filesystem")))

;;;###autoload
(defun jam/sudo-edit (file) "Edit file with sudo. Defaults to current buffer's file name." (interactive (list (read-file-name (format "Sudo Edit File(%s): " (buffer-file-name (current-buffer))) nil (buffer-file-name (current-buffer)) nil))) (find-file (format "/sudo::%s" file)))
;;;###autoload
(defun jam/save-all () "Save all buffers" (interactive) (save-some-buffers t))
;;;###autoload
(defun jam/draw () "Activate artist-mode polygon in *scratch* buffer." (interactive) (switch-to-buffer "*scratch*") (artist-mode 1) (artist-select-op-poly-line)); (picture-mode)
;;;###autoload
(defun jam/eshell () "Open new eshell" (interactive) (eshell t))
;;;###autoload
(defun jam/replace-unicode() "Replaces the following unicode characters: ZERO WIDTH NO-BREAK SPACE (65279, #xfeff) aka BOM, ZERO WIDTH SPACE (codepoint 8203, #x200b), RIGHT-TO-LEFT MARK (8207, #x200f), RIGHT-TO-LEFT OVERRIDE (8238, #x202e), LEFT-TO-RIGHT MARK ‎(8206, #x200e), OBJECT REPLACEMENT CHARACTER (65532, #xfffc)" (interactive) (query-replace-regexp "\ufeff\\|\u200b\\|\u200f\\|\u202e\\|\u200e\\|\ufffc" ""))
;;;###autoload
(defun jam/screenshot () "Save screenshot to local cache directory" (interactive) (let* ((image (x-export-frames nil 'png)) (image-file (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") (format-time-string "Screenshot-%Y-%m-%d-%T.png")))) (with-temp-file image-file (insert image)) (message "Saved Screenshot %s" image-file)))
;;;###autoload
(defun jam/compile-init-bytecode () "Recompile init.el, early-init.el, make-el.el and package-quickstart.el (autoloads)" (interactive) (byte-recompile-file (concat user-emacs-directory "init.el")) (byte-recompile-file (concat user-emacs-directory "early-init.el")) (byte-recompile-file (concat user-emacs-directory "make-el.el")) (require 'package) (package-quickstart-refresh)(byte-recompile-file (concat user-emacs-directory "package-quickstart.el"))); recompile autoloads
;;;###autoload
(defun jam/mpv-play (url) "Run mpv in eat terminal. 9 is volume down; 0 is up. Requires url-handler-mode for default completion (use home and del)." (interactive (list (read-file-name (format "Args(https://somafm.com/vaporwaves.pls): ") nil nil nil "https://somafm.com/vaporwaves.pls"))) (eat (concat "mpv " url) t))

;;;###autoload
(defun jam/set-rust-path ()
  "Set PATH, exec-path, RUSTUP_HOME and CARGO_HOME to XDG_DATA_HOME locations"
  (interactive)
  (require 'xdg)
  (setenv "PATH" (concat (getenv "PATH") path-separator (concat (file-name-as-directory (xdg-data-home)) (file-name-as-directory "cargo") "bin")))
  (setenv "RUSTUP_HOME" (concat (file-name-as-directory (xdg-data-home)) "rustup"))
  (setenv "CARGO_HOME" (concat (file-name-as-directory (xdg-data-home)) "cargo"))
  (setq exec-path (append `(,(concat (file-name-as-directory (getenv "CARGO_HOME")) "bin")) exec-path)))

;;; TOTP
;;;###autoload
(defun jam/totp (string &optional time digits)
  "Return a TOTP token using the secret hex STRING and current time.
TIME is used as counter value instead of current time, if non-nil.
DIGITS is the number of pin digits and defaults to 6."
  (defun jam/totp--hex-decode-string (string)
    "Hex-decode STRING and return the result as a unibyte string."
    (require 'hexl)
    (unless (zerop (logand (length string) 1))
      (setq string (concat "0" string))) ;; Pad the string with a leading zero if its length is odd.
    (apply #'unibyte-string
           (seq-map (lambda (s) (hexl-htoi (aref s 0) (aref s 1)))
                    (seq-partition string 2))))
  (require 'bindat)
  (require 'gnutls)
  (let* ((key-bytes (jam/totp--hex-decode-string (upcase string)))
         (counter (truncate (/ (or time (time-to-seconds)) 30)))
         (digits (or digits 6))
         (format-string (format "%%0%dd" digits))
         (counter-bytes (bindat-pack  '((:high u32) (:low u32)) ;; split the 64 bit number (u64 not supported in Emacs 27.2)
                                      `((:high . ,(ash counter -32)) (:low . ,(logand counter #xffffffff)))))
         (mac (gnutls-hash-mac 'SHA1 key-bytes counter-bytes))
         (offset (logand (bindat-get-field (bindat-unpack '((:offset u8)) mac 19) :offset) #xf)))
    (format format-string
            (mod
             (logand (bindat-get-field (bindat-unpack '((:totp-pin u32)) mac offset) :totp-pin)
                     #x7fffffff)
             (expt 10 digits)))))

;;;###autoload
(defun jam/base32-hex-decode (string) ; Base32 for TOTP
  (defconst jam/base32-alphabet
    (let ((tbl (make-char-table nil)))
      (dolist (mapping '(("A" . 0)  ("B" . 1)  ("C" . 2)  ("D" . 3)
                         ("E" . 4)  ("F" . 5)  ("G" . 6)
                         ("H" . 7)  ("I" . 8)  ("J" . 9)  ("K" . 10)
                         ("L" . 11) ("M" . 12) ("N" . 13)
                         ("O" . 14) ("P" . 15) ("Q" . 16) ("R" . 17)
                         ("S" . 18) ("T" . 19) ("U" . 20)
                         ("V" . 21) ("W" . 22) ("X" . 23) ("Y" . 24)
                         ("Z" . 25) ("2" . 26) ("3" . 27)
                         ("4" . 28) ("5" . 29) ("6" . 30) ("7" . 31)))
        (aset tbl (string-to-char (car mapping)) (cdr mapping)))
      tbl)
    "Base-32 mapping table, as defined in RFC 4648.")
  (setq string (upcase string))
  (let* ((trimmed-array (append (string-trim-right string "=+") nil))
         (ntrail (mod (* 5 (length trimmed-array)) 8))) ; shift for partial bits
    (format "%X" (ash (seq-reduce (lambda (acc char) (+ (ash acc 5) (aref jam/base32-alphabet char))) trimmed-array 0)
                      (- ntrail)))))

;;;###autoload
(defun jam/auth-display (auth)
  "Select a TOTP or AUTH from `auth-sources'"
  (interactive
   (list
    (let ((candidates (mapcar
           (lambda (auth)
             (cons (format "User '%s' on %s"
                           (propertize (plist-get auth :user) 'face 'font-lock-keyword-face)
                           (propertize (plist-get auth :host) 'face 'font-lock-string-face))
                   auth))
           (auth-source-search :max 10000))))
      (cdr (assoc (completing-read "Pick an AUTH> " candidates) candidates)))))
  (let ((code (if (string-prefix-p "TOTP:" (plist-get auth :host))
                  (jam/totp (jam/base32-hex-decode (funcall (plist-get auth :secret))))
                (funcall (plist-get auth :secret)))))
    (message "%s sent to kill ring" (if auth-source-debug (propertize code 'face 'font-lock-string-face) "AUTH"))
    (kill-new code)
    code))
