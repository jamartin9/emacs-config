;;; early-init.el -*- lexical-binding: t; -*-

(setq package-enable-at-startup nil ;; skip packages
      package-quickstart t ;; concat autoloads ; (package-quickstart-refresh)
      load-prefer-newer noninteractive ;; skip newer checks
      gc-cons-threshold most-positive-fixnum) ;; skip gc

(if (native-comp-available-p)
    (progn
      (if (>= emacs-major-version 29) ; set eln-cache & remove after emacs-29
          (startup-redirect-eln-cache (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln"))
        (setq native-comp-eln-load-path (add-to-list 'native-comp-eln-load-path (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln"))))
      (setq native-comp-deferred-compilation t
            native-comp-enable-subr-trampolines (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln") ; renamed with native- in 29.1
            native-comp-async-report-warnings-errors nil
            native-compile-target-directory (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "eln"))))


(let* ((guix-home-dir (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".guix-home") (file-name-as-directory "profile") (file-name-as-directory "share") (file-name-as-directory "emacs") "site-lisp"))
       (user-package-dir (concat user-emacs-directory (file-name-as-directory ".local") (file-name-as-directory "cache") "elpa"))
       (default-directory (if (file-directory-p guix-home-dir) guix-home-dir user-package-dir)))
  (if (not (file-directory-p guix-home-dir))
      (progn ; use-package-ensure w/o guix-home-dir
        (require 'package)
        (setq package-check-signature nil
              package-user-dir user-package-dir)
        (if (gnutls-available-p) ; melpa requires gnutls
            (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)) ; add package repo
        (if (not (>= emacs-major-version 29)) ; remove after emacs-29
            (progn ; install use-package
              (if (not (package-installed-p 'use-package))
                  (package-install 'use-package) ; (package-refresh-contents)
		(package-initialize)))
          (package-initialize))
	(require 'use-package-ensure)
    ;(if (gnutls-available-p) (setq use-package-always-pin "melpa")) ; pin to melpa
    (setq use-package-always-ensure t
          package-pinned-packages '((pcre2el . "nongnu")
                                    (eat . "nongnu")
                                    (which-key . "gnu")
                                    (gcmh . "gnu")
                                    (company . "gnu")
                                    (osm . "gnu")
                                    (debbugs . "gnu")
                                    (undo-tree . "gnu"))
    )))
  (normal-top-level-add-subdirs-to-load-path)
  (require 'use-package)) ;; remove for emacs-29

(setq use-package-always-defer t
      use-package-verbose t)

(if (memq window-system '(android))
    (progn ;; add termux to path on android
      (setenv "PATH" (format "%s:%s" "/data/data/com.termux/files/usr/bin"
		                     (getenv "PATH")))
      (setenv "LD_LIBRARY_PATH" (format "%s:%s"
				                        "/data/data/com.termux/files/usr/lib"
				                        (getenv "LD_LIBRARY_PATH")))
      (push "/data/data/com.termux/files/usr/bin" exec-path)))