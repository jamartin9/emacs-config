;;; early-init.el -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil
      gc-cons-threshold most-positive-fixnum
      native-comp-deferred-compilation t ; native comp
      native-comp-async-report-warnings-errors nil
      native-compile-target-directory (concat user-emacs-directory ".local/cache/" "eln/")
      native-comp-eln-load-path (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory ".local/cache/" "eln/")))
