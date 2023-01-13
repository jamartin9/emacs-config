;;; early-init.el -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil ;; skip packages and  gc
      gc-cons-threshold most-positive-fixnum)

(if (native-comp-available-p)
    (setq native-comp-deferred-compilation t ;; native comp on
          native-comp-async-report-warnings-errors nil
          native-compile-target-directory (concat user-emacs-directory ".local/cache/" "eln/") ;; avoid literring
          native-comp-eln-load-path (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory ".local/cache/" "eln/"))))

(let ((default-directory  "~/.guix-home/profile/share/emacs/site-lisp/"))
  (if (file-directory-p default-directory)
      (progn ;; add dirs when not using guix-home
        (normal-top-level-add-subdirs-to-load-path)
        (require 'use-package)) ;; remove for emacs-29
    (setq use-package-always-ensure t ;; allow use-package to resolve packages when not using guix-home for elisp packages
          auto-package-update-delete-old-versions t ;; (require 'use-package-ensure)
          auto-package-update-hide-results t))) ;; (auto-package-update-maybe) ; maybe pin

(setq use-package-always-defer t
      use-package-verbose t)
