;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Justin Martin"
      user-mail-address "jaming@protonmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "monospace" :size 21))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't w
;; ant your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory (concat (expand-file-name doom-private-dir) (file-name-as-directory "org")))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;; swap elc for eln
(setq comp-deferred-compilation t)

;; eshell config
(after! eshell
  (require 'em-smart)
  (set-company-backend! 'eshell-mode 'company-capf)
  (setq eshell-prefer-lisp-functions nil
        eshell-cmpl-cycle-completions t
        eshell-password-prompt-regexp (concat eshell-password-prompt-regexp "\\|^Password for .*:\\s *\\'")))

;;;
;;; Package configs
;;;

(use-package! emms
  :commands (emms-play-file emms-librefm-stream)
  :config
  (progn
        (require 'emms-setup)
        (emms-all)
        (emms-default-players)
        (setq emms-player-list '(emms-player-vlc))
        ;;(require 'emms-librefm-stream)
        ;;(setq emms-librefm-scrobbler-username "foo"
        ;;      emms-librefm-scrobbler-pass
        ;;      word "bar")
        ;;(require 'emms--scrobbler)
        ;;(require 'emms-browser)
        ;;(setq emms-source-file-default-directory "~/Music/")
        ;;(setq emms-playlist-buffer-name "*Music*")
        (setq emms-info-asynchronously t)
        (require 'emms-info-libtag)
        (setq emms-info-functions '(emms-info-libtag))
        (require 'emms-mode-line)
        (emms-mode-line 1)
        (require 'emms-playing-time)
        (emms-playing-time 1)))

(use-package! guix
  :commands guix-popup)

(use-package! rmsbolt
  :commands rmsbolt-mode)

(use-package! system-packages
  :commands system-packages-ensure)

;;;
;;; Setup my stuff
;;;

(jam/init)
