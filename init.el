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
  "Edits opens file with sudo. Defaults to current buffer's file name."
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
  "Saves all buffers"
  (interactive)
  (save-some-buffers t))

;;;###autoload
(defun jam/vterm ()
  "opens new vterm"
  (interactive)
  (vterm t))

;;;###autoload
(defun jam/newsticker-download ()
  "Downloads the current newsticker enclosure to tmpdir/newsticker/feed/title"
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
  "Activates artist-mode polygon in *scratch* buffer."
  (interactive)
  (switch-to-buffer "*scratch*")
  (artist-mode 1); (picture-mode)
  (artist-select-op-poly-line))


(use-package gcmh ; gc when idle
  :init (setq gcmh-idle-delay 'auto ; gc startup
              gcmh-auto-idle-delay-factor 10
              gcmh-high-cons-threshold (* 16 1024 1024)) ; 16 MiB
  (add-hook 'after-init-hook #'gcmh-mode)
  :config (setq gc-cons-threshold (* 16 1024 1024))
  :commands gcmh-mode)

;; Movement: f b n p, a e, M-g-g
(use-package emacs ; built-in
  :init (setq user-full-name "Justin Martin"
                user-mail-address "jaming@protonmail.com"
                backup-directory-alist `(("." .  ,(concat user-emacs-directory ".local/cache/")))
                recentf-save-file (expand-file-name "recentf" (concat user-emacs-directory ".local/cache/"))
                bookmark-default-file (expand-file-name "bookmarks" (concat user-emacs-directory ".local/cache/"))
                project-list-file (expand-file-name "projects" (concat user-emacs-directory ".local/cache/"))
                url-cookie-file (expand-file-name "cookies" (concat user-emacs-directory ".local/cache/"))
                url-cache-directory (expand-file-name "cache" (concat user-emacs-directory ".local/cache/"))
                auth-sources (list (concat user-emacs-directory ".local/cache/" "authinfo.gpg") "~/.authinfo.gpg") ; auth
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
                ad-redefinition-action 'accept ; ignore warnings
                completion-auto-help nil; '?' for help w/mouse click
                completion-cycle-threshold nil ; flex narrowing instead of cycling
                column-number-mode t
                sentence-end-double-space nil
                require-final-newline t
                bidi-inhibit-bpa t ; some naughty unicodes
                use-short-answers t ; annoying
                confirm-kill-processes nil
                visible-bell nil
                ring-bell-function #'ignore
                uniquify-buffer-name-style 'forward
                confirm-nonexistent-file-or-buffer nil
                confirm-kill-emacs nil
                blink-matching-paren nil
                enable-recursive-minibuffers t
                menu-bar-mode nil
                tool-bar-mode nil
                scroll-bar-mode nil
                mouse-yank-at-point t
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
                load-prefer-newer t; noninteractive
                auto-mode-case-fold nil
                kill-do-not-save-duplicates t
                edebug-print-length nil ; print whole edebug result
                browse-url-browser-function 'xwidget-webkit-browse-url ; libxml-parse-html-region w/ shr
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
                (setq native-comp-deferred-compilation t
                      native-comp-async-report-warnings-errors nil
                      native-compile-target-directory (concat user-emacs-directory ".local/cache/" "eln/")
                      native-comp-eln-load-path (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory ".local/cache/" "eln/"))))
            (if (>= emacs-major-version 29) ; remove after emacs-29
                (bind-keys :map window-prefix-map
                           ("w" . windmove-up)
                           ("a" . windmove-left)
                           ("s" . windmove-down)
                           ("d" . windmove-right)
                           ("f" . select-frame-by-name)
                           ("o" . other-frame)))
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
            (add-hook 'after-init-hook #'(lambda () (message "after-init-hook running after %s" (float-time (time-subtract after-init-time before-init-time)))))
            (blink-cursor-mode -1)
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
            (bind-keys :prefix-map jam/projects :prefix "C-c p"
                       ("d" . jam/draw))
            (bind-keys :prefix-map jam/toggle :prefix "C-c t"
                       ("v" . visible-mode)
                       ("w" . visual-line-mode)
                       ("x" . xterm-mouse-mode)
                       ("c" . global-display-fill-column-indicator-mode)
                       ("F" . toggle-frame-fullscreen))
            (bind-keys :prefix-map jam/open :prefix "C-c o"
                        ("s" . jam/sudo-edit)
                        ("S" . speedbar-frame-mode)
                        ("b" . browse-url-of-file)
                        ("-" . dired-jump)
                        ("f" . make-frame))
            (bind-keys :prefix-map jam/insert :prefix "C-c i"
                        ("y" .  cua-paste)
                        ("u" . insert-char)
                        ("s" . yas-insert-snippet)
                        ("e" . emojify-insert-emoji))
            (bind-keys :prefix-map jam/code :prefix "C-c c"
                        ("j" . xref-find-definitions)
                        ("c" . compile))
            (bind-keys :prefix-map jam/search :prefix "C-c s"
                        ("l" . link-hint-copy-link)
                        ("L" . ffap-menu)
                        ("i" . imenu)
                        ("a" . apropos)
                        ("m" . bookmark-jump))
            (bind-keys :prefix-map jam/file :prefix "C-c f"
                       ("f" . find-file)
                       ("r" . recentf-open)
                       ("d" . dired))
            (bind-keys :prefix-map jam/quit :prefix "C-c q"
                       ("f" . delete-frame)
                       ("q" . kill-emacs)
                       ("r" . restart-emacs)
                       ("Q" . save-buffers-kill-terminal)
                       ("K" . save-buffers-kill-emacs))
            (load-theme 'modus-vivendi); built-in does not need to hook after-make-frame-hook for daemonp
            (add-to-list 'default-frame-alist '(menu-bar-lines . 0)); disable w/o loading modes
            (add-to-list 'default-frame-alist '(tool-bar-lines . 0))
            (add-to-list 'default-frame-alist '(vertical-scroll-bars))
            (set-frame-parameter nil 'alpha-background 80)
            ;(add-to-list 'default-frame-alist '(width  . 190))
            ;(add-to-list 'default-frame-alist '(height  . 96))
            (add-to-list 'default-frame-alist '(alpha-background  . 80))
            ;(add-to-list 'initial-frame-alist '(width  . 190))
            ;(add-to-list 'initial-frame-alist '(height  . 96))
            (add-to-list 'initial-frame-alist '(alpha-background  . 80))
            (set-language-environment "UTF-8"))

(use-package emms
  :init (bind-keys :map jam/open
                   ("l" . jam/librefm-stream)
                   ("m" . emms-play-file))
  :commands (emms-play-file emms-librefm-stream emms-browser emms-play-url emms-play-directory)
  :config
  (require 'emms-setup)
  (emms-minimalistic)
  (setq emms-player-list '(emms-player-vlc emms-player-mpv))
  (require 'emms-librefm-stream)
  (emms-librefm-scrobbler-disable) ; BUG make work without login
  (setq emms-source-file-default-directory "~/Music/"
        emms-playlist-buffer-name "*Music*"
        emms-info-asynchronously t)
  (require 'emms-mode-line)
  (emms-mode-line 1)
  (require 'emms-playing-time)
  (emms-playing-time 1))

(use-package guix
  :config (require 'guix-autoloads)
  (guix-set-emacs-environment "~/.guix-home/profile")
  :commands guix-popup guix-set-emacs-environment)

(use-package rmsbolt
  :init (bind-keys :map jam/toggle ("r" . rmsbolt-mode))
  :commands rmsbolt-mode)

(use-package pass
  :init (bind-keys :map jam/open ("p" . pass))
  :config
  (setenv "GNUPGHOME" (concat (file-name-as-directory (getenv "XDG_DATA_HOME")) "gnupg"))
  (setenv "PASSWORD_STORE_DIR" (concat (file-name-as-directory (getenv "XDG_DATA_HOME")) "pass"))
  :commands pass)

(use-package password-store ; info:auth#The Unix password store
  :config (setq password-store-password-length 12)
          (auth-source-pass-enable))

(use-package newsticker ; built-in
  :commands (newsticker-start newsticker-treeview newsticker-plainview newsticker-stop)
  :config
  (bind-keys :map newsticker-treeview-item-mode-map ("d" . jam/newsticker-download))
  :init (bind-keys :map jam/open ("n" . newsticker-treeview))
  (bind-keys :map jam/toggle ("n" . newsticker-stop))
  (setq newsticker-frontend 'newsticker-treeview
        newsticker-dir (concat user-emacs-directory ".local/cache/" "newsticker")
        newsticker-automatically-mark-items-as-old nil
        newsticker-automatically-mark-visited-items-as-old t
        newsticker-url-list-defaults nil
        newsticker-url-list '(("Guile" "https://www.gnu.org/software/guile/news/feed.xml")
                              ("Guix" "https://guix.gnu.org/feeds/blog.atom")
                              ("Wine" "https://www.winehq.org/news/rss")
                              ("Linux" "https://www.kernel.org/feeds/kdist.xml")
                              ("Lwn" "https://lwn.net/headlines/newrss")
                              ("Tor" "https://blog.torproject.org/rss.xml")
                              ("zfs-release" "https://github.com/openzfs/zfs/releases.atom") ; gitea commit rss ex: https://codeberg.org/gnuastro/gnuastro.rss
                              ("emacs-tags" "https://github.com/emacs-mirror/emacs/tags.atom") ; not used: https://savannah.gnu.org/news/atom.php?group=emacs
                              ("guix-tags" "https://github.com/guix-mirror/guix/tags.atom")
                              ("chia-release" "https://github.com/Chia-Network/chia-blockchain/releases.atom")
                              ("xmrig-release" "https://github.com/xmrig/xmrig/releases.atom")
                              ("monero-release" "https://github.com/monero-project/monero-gui/releases.atom")
                              ("p2pool-release" "https://github.com/SChernykh/p2pool/releases.atom")
                              ("zfs-meetings" "https://yewtu.be/feed/channel/UC0IK6Y4Go2KtRueHDiQcxow")
                              ("chia-meetings" "https://yewtu.be/feed/channel/UChFkJ3OAUvnHZdiQISWdWPA")
                              ("TheChinaShow" "https://yewtu.be/feed/channel/UCcukTqc1cJJ4K3c4uzxTzjA")
                              ("Level1Techs" "https://yewtu.be/feed/channel/UC4w1YQAJMWOz4qtxinq55LQ"); youtube rss ex: https://www.youtube.com/feeds/videos.xml?channel_id=UC4w1YQAJMWOz4qtxinq55LQ
                              ("StyxHexenHammer" "https://odysee.com/$/rss/@Styxhexenhammer666:2"); bitchute rss ex: https://www.bitchute.com/feeds/rss/channel/Styxhexenhammer666
                              ("TimPool" "https://odysee.com/$/rss/@timcast:c")
                              ("Reddit-news" "https://teddit.net/r/news?api&type=rss"); reddit ex: https://www.reddit.com/r/news/.rss
                              ("CNN" "http://rss.cnn.com/rss/cnn_topstories.rss")
                              ("Fox" "http://feeds.foxnews.com/foxnews/latest?format=xml")
                              ("Lobste" "https://lobste.rs/rss")
                              ("HN" "https://hnrss.org/newest")
                              ("Phoronix" "https://www.phoronix.com/rss.php")
                              ("CVE" "https://nvd.nist.gov/feeds/xml/cve/misc/nvd-rss-analyzed.xml")
                              ("BruceSchneier" "https://www.schneier.com/feed/atom")
                              ("GlennGreenWald" "https://greenwald.substack.com/feed")
                              ("BramCohen" "https://nitter.net/bramcohen/rss")
                              ("AndyWingo" "https://wingolog.org/feed/atom"))))

(use-package vterm ; C-c C-t vterm-copy-mode
  :init (bind-keys :map jam/open ("t" . jam/vterm))
  :commands (vterm-mode vterm)
  :config (setq vterm-kill-buffer-on-exit t
                vterm-max-scrollback 5000)
  (bind-keys :map vterm-mode-map ("C-S-v" . vterm-yank)))

(use-package undo-tree
  :init (add-hook 'after-init-hook #'global-undo-tree-mode)
  :commands (global-undo-tree-mode)
  :custom (undo-tree-history-directory-alist `(("." . ,(concat user-emacs-directory ".local/cache/" "undo-tree-hist/"))))
  :config (setq undo-tree-visualizer-diff t
                undo-tree-auto-save-history t
                undo-limit 800000 ; 800 kb (default 160kb)
                undo-strong-limit 12000000 ; 12mb (default 240kb)
                undo-outer-limit 128000000 ; 128mb (default 24mb)
                undo-tree-enable-undo-in-region t))

(use-package minions ; hide minor modes on modeline
  :init (add-hook 'after-init-hook #'minions-mode)
  :commands minions-mode)

(use-package magit
  :commands magit-file-delete magit-status
;  :defer-incrementally (dash f s with-editor git-commit package eieio transient)
  :init
  (bind-keys :map jam/vcs ("s" . magit-status))
  (setq magit-auto-revert-mode nil)
  (setq transient-levels-file  (concat user-emacs-directory ".local/etc/" "transient/levels")
        transient-values-file  (concat user-emacs-directory ".local/etc/" "transient/values")
        transient-history-file (concat user-emacs-directory ".local/etc/" "transient/history"))
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

(use-package magit-todos
  ;:init (add-hook 'magit-status-mode-hook #'magit-status-mode)
  :after magit
  :custom (magit-todos-exclude-globs "*.html")
  :config
  (setq magit-todos-keyword-suffix "\\(?:([^)]+)\\)?:?") ; make colon optional
  (bind-keys :map jam/projects ("t" . magit-todos-list)))

;; authinfo machine api.github.com login USERNAME^forge password 012345abcdef...
(use-package forge
  :after magit
  :commands forge-create-pullreq forge-create-issue
  :init
  (setq forge-database-file (concat user-emacs-directory ".local/etc/" "forge/forge-database.sqlite"))
  (setq forge-add-default-bindings t))

(use-package code-review
  :after magit
  :init
  (setq code-review-db-database-file (concat user-emacs-directory ".local/etc/" "code-review/code-review-db-file.sqlite")
        code-review-log-file (concat user-emacs-directory ".local/etc/" "code-review/code-review-error.log")
        code-review-download-dir (concat user-emacs-directory ".local/etc/" "code-review/")
        code-review-auth-login-marker 'forge))

(use-package yaml ; TODO remove for yaml-ts-mode (built-in emacs-29)
  :config (add-hook 'yaml-mode-hook #'(lambda () (setq-local tab-width yaml-indent-offset))))

(use-package transmission ; C-u universal arg for directory prompt
  :commands (transmission transmission-add))

(use-package debbugs
  :init (bind-keys :map jam/search ("b" . debbugs-gnu-bugs)); bug number search
  :commands (debbugs-gnu debbugs-gnu-tagged debbugs-org debbugs-org-tagged debbugs-org-mode debbugs-gnu-bugs debbugs-gnu-guix-search debbugs-org-guix-search)
  :config ;(setq org-link-elisp-confirm-function nil)
  (setq debbugs-gnu-default-packages '("guix-patches"))
  (require 'debbugs-guix)
  (require 'debbugs-org)
  (require 'debbugs-gnu)
  (require 'debbugs-browse)); C-u M-x debbugs-gnu guix-patches n y then tag with t

(use-package hideshow ; built-in
  :init (bind-keys :map jam/toggle ("z" . hs-minor-mode))
  (bind-keys :map jam/code ("z" . hs-toggle-hiding)
                           ("v" . hs-hide-block))
  :commands (hs-minor-mode hs-toggle-hiding hs-hide-block hs-hide-level hs-show-all hs-hide-all))

(use-package org-crypt ; built-in
  :commands (org-encrypt-entries org-encrypt-entry org-decrypt-entries org-decrypt-entry))

(use-package org-clock ; built-in
  :commands org-clock-save)

(use-package org ; built-in
;  :defer-incrementally calendar find-func format-spec org-macs org-compat org-faces org-entities org-list org-pcomplete org-src org-footnote org-macro ob org org-agenda org-capture)
  :commands org-mode org-agenda org-capture
  :config (setq org-timer-default-timer 60)
  (bind-keys :map jam/notes
              ("D" . org-id-update-id-locations)
              ("t" . org-todo-list)
              ("g" . org-clock-goto)
              ("a" . org-agenda)))

;; C-u C-c . for agenda with timestamp or org-time-stamp-inactive for no agenda version
(use-package org-roam
  :commands (org-roam-node-find org-roam-node-insert org-roam-dailies-goto-date org-roam-dailies-goto-today org-roam-graph org-roam-db-autosync-enable)
  :init (setq org-roam-directory (concat (expand-file-name user-emacs-directory) (file-name-as-directory "org") (file-name-as-directory "roam"))
              org-directory org-roam-directory
              org-id-locations-file (expand-file-name ".orgids" org-directory) ; org-id-update-id-locations org-roam-db-sync
              org-return-follows-link t
              org-persist-directory (concat user-emacs-directory ".local/cache/" "org-persist/")
              org-roam-dailies-directory ""
              org-agenda-files (list org-roam-directory (concat org-roam-directory org-roam-dailies-directory))
              org-roam-db-location (concat user-emacs-directory ".local/cache/" "org-roam.db")
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
              ("T" .  org-roam-dailies-capture-today)
              ("d" . org-roam-dailies-goto-date)
              ("n" . org-roam-capture)
              ("N" . org-roam-dailies-capture-date)
              ("i" . org-roam-node-insert)
              ("R" . org-roam-db-sync)
              ("r" . org-roam-node-find)))

;; M-j newline in regex
(use-package dired ; built-in
  :config (setq dired-dwim-target t
                dired-hide-details-hide-symlink-targets nil
                dired-auto-revert-buffer #'dired-buffer-stale-p
                dired-recursive-copies  'always
                dired-recursive-deletes 'top
                dired-create-destination-dirs 'ask)
  :commands (dired dired-jump dired-other-frame dired-other-tab dired-other-window))

(use-package fd-dired
  :after dired
  :config (bind-key [remap find-dired] 'fd-dired)
  (bind-key [remap find-grep-dired] 'fd-grep-dired)
  (bind-key [remap find-name-dired] 'fd-name-dired)
  :commands (fd-dired fd-grep-dired fd-name-dired))

(use-package geiser
  :init (add-hook 'scheme-mode-hook #'geiser-mode)
  :commands (geiser geiser-mode geiser-mode-hook geiser-repl-mode geiser-repl-mode-hook)
  :config
  (setq geiser-repl-per-project-p t
        geiser-repl-current-project-function #'geiser-repl-project-root
        geiser-repl-history-filename (concat user-emacs-directory ".local/cache/" "geiser-history"))
  (require 'geiser-guile)); geiser call per buffer?

(use-package macrostep-geiser
  :init
  (add-hook 'geiser-mode-hook #'macrostep-geiser-setup)
  (add-hook 'geiser-repl-mode-hook #'macrostep-geiser-setup)
  :commands macrostep-geiser-setup)

(use-package geiser-guile
  :init (with-eval-after-load 'geiser-guile (add-to-list 'geiser-guile-load-path (expand-file-name "~/.config/guix/current/share/guile/site/3.0"))
                              (add-to-list 'geiser-guile-load-path (expand-file-name "~/.guix-home/profile/share/guile/site/3.0")))
  :commands geiser-guile)

(use-package flycheck-guile
  :after geiser)

(use-package flycheck
  :init ;(add-hook 'after-init-hook #'global-flycheck-mode)
  (add-hook 'prog-mode-hook #'flycheck-mode)
  (bind-keys :map jam/toggle ("f" . flycheck-mode))
  :commands (flycheck-list-errors flycheck-buffer global-flycheck-mode flycheck-mode-hook flycheck-mode)
  :custom (flycheck-display-errors-function #'display-error-messages)
  :config
  (delq 'new-line flycheck-check-syntax-automatically)
  (setq flycheck-emacs-lisp-load-path 'inherit
        flycheck-idle-change-delay 1.0
        flycheck-buffer-switch-check-intermediate-buffers t
        flycheck-display-errors-delay 0.25)
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

(use-package flycheck-popup-tip ; flycheck tty popups
  :init (add-hook 'flycheck-mode-hook #'flycheck-popup-tip-mode)
  :commands (flycheck-popup-tip-mode flycheck-popup-tip-show-popup flycheck-popup-tip-delete-popup))

(use-package flyspell ; built-in
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
                ispell-personal-dictionary (expand-file-name (concat "ispell/" ispell-dictionary ".pws") (concat user-emacs-directory ".local/etc/"))
                ispell-aspell-dict-dir (ispell-get-aspell-config-value "dict-dir")
                ispell-aspell-data-dir (ispell-get-aspell-config-value "data-dir")))

(use-package erc ; built-in
  :init (bind-keys :map jam/open ("i" . erc-tls))
  :commands erc-tls ; MAYBE add bot msg to erc-nickserv-identified-hook, erc-login function override/erc-join-hook for SASL support
  :config (setq erc-rename-buffers t
                erc-interpret-mirc-color t
                erc-save-buffer-on-part t
                erc-log-insert-log-on-open t
                erc-log-channels-directory (concat user-emacs-directory ".local/etc/" "erc")
                erc-nick '("jaming" "jamin" "jam")
                erc-user-full-name "jaming"
                erc-server-history-list '("irc.rizon.net" "irc.libera.chat" "irc.choopa.net" "irc.corrupt-net.org")
                erc-autojoin-timing 'ident
                erc-autojoin-delay 30
                ;erc-max-buffer-size 20000
                erc-keywords '("jaming")
                ;erc-prompt-for-nickserv-password nil
                ;erc-nickserv-passwords '((Corrupt (("nickname" . "password"))))
                erc-use-auth-source-for-nickserv-password t; format: machine irc.site.net login your_nickname password your_password
                erc-prompt-for-password nil
                erc-nickserv-identify-mode 'both
                ;erc-dcc-auto-masks '(".*!.*@.*") ; accept dcc files from anyone with 'auto send-requests
                ;erc-dcc-send-request 'auto ; BUG /dcc get NICK FILE fails with unknown filename (spaces/brackets in name) and daemon default-directory not respected
                ;erc-server-auto-reconnect nil ; /reconnect
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
                erc-network-hide-list '(("Libera.Chat" "JOIN" "PART" "QUIT")
                                       ("Rizon" "JOIN" "PART" "QUIT")
                                       ("EFnet" "JOIN" "PART" "QUIT")
                                       ("Corrupt" "JOIN" "PART" "QUIT")))
  (add-to-list 'erc-server-alist '("EFnet: New York reverse proxy scanner" EFnet "irc.choopa.net" ((6665 6669)) 7000 9999))
  (add-to-list 'erc-server-alist '("Corrupt-Net" Corrupt "irc.corrupt-net.org" ((6666 6669)) 8067 6697 7000))
  ;(add-to-list 'erc-nickserv-alist '(Corrupt "NickServ!services@shd.u" "This\\s-nickname\\s-is\\s-registered\\s-and\\s-protected.\\s-\\s-If\\s-it\\s-is\\s-your" "NickServ" "IDENTIFY" nil))
  (add-to-list 'erc-modules 'dcc);/dcc list and /dcc get -s nick file
  (add-to-list 'erc-modules 'notifications); requires notification-daemon from freedesktop.org
  (add-to-list 'erc-modules 'log)
  ;(add-to-list 'erc-modules 'services); nickserv
  (erc-update-modules))

(use-package eshell ; built-in
  :init (add-hook 'eshell-mode-hook #'(lambda () (add-to-list 'eshell-visual-commands "btm")))
  (bind-keys :map jam/open ("e" . eshell))
  :commands (eshell)
  :config
  (require 'em-smart)
  (setq-local company-backends '(company-capf))
  (add-hook 'completion-at-point-functions 'pcomplete-completions-at-point nil t); add eshell C-c TAB to TAB
  (setq eshell-directory-name (concat user-emacs-directory ".local/cache/" "eshell")
        eshell-prefer-lisp-functions nil
        eshell-cmpl-cycle-completions t; replace # with : for prompt regex using /ssh:jam@10.0.0.1#6969:/tmp
        eshell-prompt-function #'(lambda () (concat (propertize (replace-regexp-in-string "[#$]" ":" (abbreviate-file-name (eshell/pwd))) 'face `(:foreground "green"))
                                                  (propertize " $ " 'face (if (= (user-uid) 0) `(:foreground "red") `(:foreground "white"))))))
  (add-to-list 'eshell-modules-list 'eshell-tramp))

(use-package tramp ; built-in
  :commands (tramp)
  :config (add-to-list 'tramp-remote-path 'tramp-own-remote-path); use login shell for tramp
  (setq tramp-auto-save-directory "/tmp"
        tramp-persistency-file-name (concat user-emacs-directory ".local/cache/" "tramp")))

(use-package company
  :init (add-hook 'after-init-hook #'global-company-mode)
  (bind-keys :map jam/toggle ("a" . global-company-mode))
  (setq company-minimum-prefix-length 2
        company-tooltip-limit 14
        company-tooltip-align-annotations t
        company-require-match 'never
        company-global-modes
        '(not erc-mode
              circe-mode
              message-mode
              help-mode
              ;gud-mode
              vterm-mode)
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

(use-package treemacs
  :init (bind-keys ("<f9>" . treemacs))
  (bind-keys :map jam/projects ("w" . treemacs-switch-workspace))
  (setq treemacs-persist-file (concat user-emacs-directory ".local/cache/" "treemacs-persist"))
  :commands (treemacs treemacs-find-file treemacs-switch-workspace))

(use-package treemacs-magit
  :after treemacs magit)

(use-package cfrs ; BUG guix package needs for treemacs
  :commands cfrs-read
  :after treemacs)

(use-package lsp-mode
  :commands (lsp-install-server lsp-mode lsp)
  :hook ((python-mode . lsp))
  :config (bind-keys :map jam/code
                      ("a" . lsp-execute-code-action)
                      ("f" . lsp-format-buffer)
                      ("r" . lsp-rename))
  (require 'lsp-diagnostics) ; flycheck enable?
  (require 'lsp-lens) ; default enabled
  (require 'lsp-modeline)
  :init (setq lsp-enable-on-type-formatting nil
              lsp-response-timeout 60
              lsp-headerline-breadcrumb-enable nil
              lsp-session-file (expand-file-name ".lsp-session-v1" (concat user-emacs-directory ".local/cache/"))
              lsp-enable-folding nil))

(use-package lsp-treemacs
  :config (bind-keys :map jam/code
                      ("X" . lsp-treemacs-errors-list)
                      ("y" . lsp-treemacs-call-hierarchy))
  :after (treemacs lsp))

(use-package lsp-ui
  :init (add-hook 'lsp-mode-hook #'lsp-ui-mode)
  :commands lsp-ui-mode
  :config (setq lsp-ui-peek-enable t))

(use-package dap-mode ; BUG guix: icons not included in package
  :init (bind-keys :map jam/code ("d" . dap-debug))
  :commands (dap-debug dap-debug-edit-template)
  :after lsp-mode
  :config
  (require 'dap-mouse)
  (require 'dap-ui)
  (setq dap-auto-configure-features '(sessions locals breakpoints expressions controls tooltip))
  (require 'dap-gdb-lldb)
  ;;;###package gdb
  (setq gdb-show-main t
        gdb-many-windows t)
  ;(dap-gdb-lldb-setup) ; BUG download/unzip fails? redirect?
  (dap-register-debug-template "Rust::GDB Run Configuration"
                               (list :type "gdb"
                                     :request "attach"; "launch"
                                     :name "Rust::GDB"
                                     :gdbpath "rust-gdb"
                                     :target nil; 666; pid
                                     ;:executable "/somesuchfile"
                                     ;:arguments "-h" ; dap-debug-edit-template
                                     ;debugger_args ""
                                     :cwd nil))
  (require 'dap-python)
  (setq dap-python-executable "python3" ; use guix-home's python for debug module
        dap-python-debugger 'debugpy))


;; prompts for authinfo.gpg with format: machine gmail login your_user password your_password
;; C-u RET for unread and read
;; ! to save for offline/cache
;; U to manually subscribe
;; L list all groups
(use-package gnus ; built-in
  :init (bind-keys :map jam/open ("g" . gnus))
  :commands (gnus)
  :config
  (setq
   gnus-save-newsrc-file nil
   gnus-read-newsrc-file nil
   gnus-use-dribble-file t
   gnus-always-read-dribble-file t
   gnus-dribble-directory (concat user-emacs-directory ".local/cache/" (file-name-as-directory "gnus"))
   gnus-startup-file (concat user-emacs-directory ".local/cache/" (file-name-as-directory "gnus") "newsrc")
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
               gnus-server-alist '(("archive" nnfolder "archive" (nnfolder-directory (concat user-emacs-directory ".local/cache/" "archive"))
                                   (nnfolder-active-file (concat user-emacs-directory ".local/cache/" (file-name-as-directory "archive") "active"))
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
                                   "nnfolder+archive:sent.2021"
                                   "nnfolder+archive:sent.2022"
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

(use-package osm
  :init (bind-keys :map jam/open ("o" . osm-home)) ;(with-eval-after-load 'org (require 'osm-ol))
  :commands (osm-home osm-search)
  :config (setq osm-tile-directory (concat user-emacs-directory ".local/cache/osm/"))
  :custom (osm-copyright nil))

(use-package multiple-cursors
  :commands (multiple-cursors-mode mc/add-cursor-on-click mc/vertical-align
             mc/mark-next-like-this mc/mark-previous-like-this mc/mark-more-like-this-extended
             mc/mark-pop mc/unmark-previous-like-this mc/unmark-next-like-this
             mc/edit-lines mc/edit-beginnings-of-lines mc/edit-ends-of-lines
             mc/mark-all-in-region mc/mark-all-dwim mc/mark-all-like-this
             set-rectangular-region-anchor mc/edit-lines mc/vertical-align mc/mark-sgml-tag-pair)
  :config (setq mc/list-file (concat user-emacs-directory ".local/etc/" "mc-lists.el")))

(use-package drag-stuff
  :commands (drag-stuff-up drag-stuff-down drag-stuff-left drag-stuff-right)
  :init (bind-keys ("<M-up>" . drag-stuff-up)
           ("<M-down>" . drag-stuff-down)
           ("<M-left>" . drag-stuff-left)
           ("<M-right>" . drag-stuff-right)))

(use-package explain-pause-mode
  :init (bind-keys :map jam/open ("T" . explain-pause-top))
  :commands (explain-pause-top explain-pause-mode))

(use-package pcre2el
  :commands (rxt-pcre-to-elisp
             rxt-elisp-to-pcre
             rxt-convert-pcre-to-rx
             rxt-convert-elisp-to-rx
             rxt-toggle-elisp-rx
             rxt-mode rxt-global-mode))

(use-package smartparens
  :init (add-hook 'after-init-hook #'smartparens-global-mode) ; less typing
  (bind-keys :map jam/toggle ("p" . smartparens-strict-mode))
  :commands (sp-pair sp-local-pair sp-with-modes sp-point-in-comment sp-point-in-string smartparens-global-mode smartparens-strict-mode))

(use-package expand-region
  :init (bind-key "C-=" #'er/expand-region)
  :commands (er/contract-region er/mark-symbol er/mark-word er/expand-region))

(use-package which-key
  :init (add-hook 'after-init-hook #'which-key-mode)
  :commands (which-key-mode))

(use-package rustic
  :config (setenv "PATH" (concat (getenv "PATH")
                                 path-separator (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                                        (file-name-as-directory "cargo") "bin")))
  (setenv "RUSTUP_HOME" (concat (file-name-as-directory (getenv "XDG_DATA_HOME")) "rustup"))
  (setenv "CARGO_HOME" (concat (file-name-as-directory (getenv "XDG_DATA_HOME")) "cargo"))
  (setq exec-path (append exec-path '("~/.local/share/cargo/bin")))
  :mode ("\\.rs$" . rustic-mode))

(use-package python
  :commands (python-mode python-mode-hook python-mode-local-vars-hook))

(use-package pyvenv ; activate before lsp or restart workspace
  :init (add-hook 'python-mode-local-vars-hook #'pyvenv-tracking-mode)
  :commands (pyvenv-mode pyvenv-activate pyvenv-tracking-mode))

; maybe packages
;
;(use-package! signal-msg ; https://github.com/AsamK/signal-cli
;  :commands (signal-msg-new-message) ; jam/signal-msg-rec
;  :config (setq signal-msg-username (alist-get 'secret (auth-source-pass-parse-entry "signal/account"))
;                signal-msg-number (alist-get 'secret (auth-source-pass-parse-entry "signal/phone")))
;  (advice-add 'signal-msg-send :override #'jam/signal-msg-send))
;
;;;###autoload
;(defun jam/signal-msg-send ()
;  "Override to use -a account notation and stdin for sending buffer to signal-cli"
;  (interactive)
;  (let ((exit-code (call-process-region
;                    (point-min)
;                    (point-max)
;                    "signal-cli"
;                    nil                                  ; delete
;                    nil                                  ; buffer
;                    nil                                  ; display
;                    "-a" signal-msg-number "send" "--message-from-stdin" signal-msg-dest-number)))
;    (if (= exit-code 0)
;        (kill-buffer)
;      (warn (format "Something went wrong. signal-cli returned %d" exit-code)))))
;
;;;;###autoload
;(defun jam/signal-msg-rec ()
;  "Reads all json encoded messages from signal-cli into *Signal* buffer"
;  (interactive)
;  (with-temp-buffer (progn (call-process "signal-cli" nil (current-buffer) nil "--output=json" "receive"); (call-process "cat" nil (current-buffer) nil "signals.json")
;                           ;(message "current buffer is %s " (buffer-string))
;                           (goto-char (point-min))
;                           (unwind-protect
;                               (while (not (eobp))
;                                 (let* (;(message-json (json-read-file "signals.json"))
;                                        (message-json (json-read))
;                                        (message-content (alist-get 'envelope message-json ))
;                                        (message-from (alist-get 'sourceName message-content))
;                                        (message-data (alist-get 'dataMessage message-content))
;                                        (message-text (alist-get 'message message-data)))
;                                   ;(message "\nFrom: %s\nMessage: %s\n" message-from message-text)
;                                   (with-current-buffer (get-buffer-create "*Signal*") (insert (format "\nFrom: %s\nMessage: %s\n" message-from message-text)))))))))


;;;###autoload
(defun jam/guix-env()
  "Guix variables for local guix daemon/client"
  (interactive)
  (setenv "GUIX_DAEMON_SOCKET" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                       (file-name-as-directory "guix")
                                       (file-name-as-directory "var")
                                       (file-name-as-directory "guix")
                                       (file-name-as-directory "daemon-socket") "socket"))
  (setenv "GUIX_DATABASE_DIRECTORY" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                            (file-name-as-directory "guix")
                                            (file-name-as-directory "var")
                                            (file-name-as-directory "guix") "db"))
  (setenv "GUIX_LOG_DIRECTORY" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                       (file-name-as-directory "guix")
                                       (file-name-as-directory "var")
                                       (file-name-as-directory "log") "guix"))
  (setenv "GUIX_STATE_DIRECTORY" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                         (file-name-as-directory "guix")
                                         (file-name-as-directory "var") "guix"))
  (setenv "GUIX_CONFIGURATION_DIRECTORY" (concat (file-name-as-directory (getenv "XDG_CONFIG_HOME"))
                                                 (file-name-as-directory "guix") "etc"))
  (setenv "GUIX_LOCPATH" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                 (file-name-as-directory "guix")
                                 (file-name-as-directory "var")
                                 (file-name-as-directory "guix")
                                 (file-name-as-directory "profiles")
                                 (file-name-as-directory "per-user")
                                 (file-name-as-directory "root")
                                 (file-name-as-directory "guix-profile")
                                 (file-name-as-directory "lib") "locale"))
  (setenv "NIX_STORE" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                              (file-name-as-directory "guix")
                              (file-name-as-directory "gnu") "store"))
  (setenv "PATH" (concat (getenv "PATH")
                         path-separator (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                     (file-name-as-directory "guix") "bin")))
  )
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

;;;###autoload
(defun jam/chia-lsp-setup ()
  "Adds syntax highlighting to chialisp and lsp client"
  (interactive)
  (define-generic-mode 'chialisp-mode
    '(";;")
    '("mod" "defun" "defun-inline" "defmacro" "defconstant")
    '(("\\(A\\(?:GG_SIG_\\(?:\\(?:M\\|UNSAF\\)E\\)\\|SSERT_\\(?:COIN_ANNOUNCEMENT\\|HEIGHT_\\(?:\\(?:ABSOLUT\\|RELATIV\\)E\\)\\|MY_\\(?:AMOUNT\\|COIN_ID\\|P\\(?:ARENT_ID\\|UZZLEHASH\\)\\)\\|PUZZLE_ANNOUNCEMENT\\|SECONDS_\\(?:\\(?:ABSOLUT\\|RELATIV\\)E\\)\\)\\)\\|CREATE_\\(?:COIN\\(?:_ANNOUNCEMENT\\)?\\|PUZZLE_ANNOUNCEMENT\\)\\|RESERVE_FEE\\)" 1 'font-lock-variable-name-face)
      ("\\(i\\(?:f\\|nclude\\)\\|list\\|sha256\\)" . 'font-lock-constant-face))
    '(".cl\\(sp\\|vm\\|ib\\)\\'")
    nil
    "Generic mode for chialisp syntax highlighting")
  (with-eval-after-load 'lsp-mode
    (add-to-list 'lsp-language-id-configuration
                 '(chialisp-mode . "chialisp"))
    (lsp-register-client ;; needs unzipped VSX extension in path
     (make-lsp-client :new-connection (lsp-stdio-connection '("node" "/home/jam/.vscode/extension/runner/build/runner.js"))
                      :activation-fn (lsp-activate-on "chialisp")
                      :server-id 'chialisp))))
