;;; early-init.el -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil ;; skip packages
      load-prefer-newer noninteractive ;; skip newer checks
      gc-cons-threshold most-positive-fixnum) ;; skip gc


(if (native-comp-available-p)
    (progn
      (if (>= emacs-major-version 29) ; set eln-cache & remove after emacs-29
          (startup-redirect-eln-cache (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln"))
        (setq native-comp-eln-load-path (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln"))))
      (setq native-comp-deferred-compilation t
            native-comp-async-report-warnings-errors nil
            native-compile-target-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln"))))


(let ((default-directory  (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "share") (file-name-as-directory "emacs") "site-lisp" )))
  (if (file-directory-p default-directory)
      (progn ;; add dirs when not using guix-home
        (normal-top-level-add-subdirs-to-load-path)
        (require 'use-package)) ;; remove for emacs-29
    (setq use-package-always-ensure t ;; allow use-package to resolve packages when not using guix-home for elisp packages
          package-user-dir (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "elpa")
          auto-package-update-delete-old-versions t ;; (require 'use-package-ensure)
          auto-package-update-hide-results t))) ;; (auto-package-update-maybe) ; maybe pin

(setq use-package-always-defer t
      use-package-verbose t)
