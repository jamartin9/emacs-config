;;; early-init.el -*- lexical-binding: t; -*-

;; skip gc and packages
(setq package-enable-at-startup nil
      gc-cons-threshold most-positive-fixnum)

;; avoid literring
(if (native-comp-available-p)
    (setq native-comp-deferred-compilation t ; native comp
          native-comp-async-report-warnings-errors nil
          native-compile-target-directory (concat user-emacs-directory ".local/cache/" "eln/")
          native-comp-eln-load-path (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory ".local/cache/" "eln/"))))

;; add dirs when not using guix-home
(let ((default-directory  "~/.guix-home/profile/share/emacs/site-lisp/"))
  (normal-top-level-add-subdirs-to-load-path))

;; remove for emacs-29
(require 'use-package)
