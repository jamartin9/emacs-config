":"; emacs --batch -l early-init.el -l make-el.el -- $@ $args ; exit $? # -*- mode: emacs-lisp; lexical-binding: t; -*-
;;;###autoload
(defun jam/parse-args (argv &optional dry-run)
"ARGV: Parse cli arguments from list.
DRY-RUN: do not run the tangled argument"
  (mapc (lambda (arg)
        (pcase arg
          (" " (message "\n"))
          ("--" (message "### make-el.el ###\n"))
          ("$@" (message "\n"));; temp bench startup: hyperfine -w 10 -r 20 -N -u second "emacs -Q --eval '(kill-emacs)'" "emacs --eval '(kill-emacs)'" "emacs -Q --batch" "emacs --batch -l /gnu/git/emacs-config/early-init.el -l /gnu/git/emacs-config/init.el"
          ("all" (jam/parse-args (directory-files-recursively (file-name-directory (or load-file-name buffer-file-name))
                                                              "\.org$" nil
                                                              #'(lambda (local-dir)
                                                                  (if (string-match-p "\\(\.git$\\|\.local$\\|guix-channel$\\|profile$\\|gh-pages$\\|elpa$\\|eln-cache$\\)" local-dir) nil t)))
                                 t))
          ("install" (jam/parse-args (list "README.org")))
          ("install-all" (jam/parse-args (directory-files-recursively (file-name-directory (or load-file-name buffer-file-name))
                                                                      "\.org$" nil
                                                                      #'(lambda (local-dir)
                                                                          (if (string-match-p "\\(\.git$\\|\.local$\\|guix-channel$\\|profile$\\|gh-pages$\\|elpa$\\|eln-cache$\\)" local-dir) nil t)))))
          ("update" (let ((dir (file-name-directory (or load-file-name buffer-file-name))))
                      (message "%s" (process-lines "git" "-C" dir "submodule" "update" "--recursive" "--remote"))))

          ("update-guix" (let ((dir (file-name-directory (or load-file-name buffer-file-name))))
                      (message "%s" (process-lines "guix" "pull")); --disable-authentication --allow-downgrades
                      (jam/parse-args "update")
                      (message "%s" (process-lines "guix" "home" "reconfigure" (concat dir (file-name-as-directory "guix-channel") (file-name-as-directory "jam") (file-name-as-directory "system") "home.scm")))
                      (message "%s" (process-lines "guix" "package" "-u"))))
          ("clean" (mapc #'(lambda (del-file)
                             (message "Deleting file %s \n" del-file)
                             (delete-file del-file))
                           (directory-files-recursively (file-name-directory (or load-file-name buffer-file-name))
                                                "\\(\.sh$\\|\.yml$\\|^\.torrc$\\|\.py$\\|\.scm$\\|\.css$\\|\.html$\\|\.html~$\\|\.sql$\\|\.sqlite$\\|\.js$\\)" nil
                                                #'(lambda (local-dir)
                                                    (if (string-match-p "\\(\.git$\\|\.local$\\|guix-channel$\\|profile$\\|gh-pages$\\|elpa$\\|eln-cache$\\)" local-dir) nil t)))))
          ("clean-guix" (message "%s" (process-lines "guix" "package" "-d"))
                        (message "%s" (process-lines "guix" "pull" "-d"))
                        (message "%s" (process-lines "guix" "home" "delete-generations"))
                        (ignore-errors (message "%s" (process-lines "guix" "system" "delete-generations")))
                        (message "%s" (process-lines "guix" "gc")))
          ("site" (jam/parse-args (list "install-all")); use install to run scripts for timestamps (css, js, sqlite, emacs, etc)
                  (let* ((init-dir (file-name-directory (or load-file-name buffer-file-name)))
                         (org-dir (concat init-dir (file-name-as-directory "org") "roam"))
                         (site-dir (concat init-dir (file-name-as-directory "gh-pages") "docs")))
                    (if (not (file-directory-p site-dir)) ; add gh-pages as worktree
                        (message "%s" (process-lines "git" "worktree" "add" "--track" "-b" "gh-pages" (concat init-dir "gh-pages") "origin/gh-pages")))
                    (mapc #'(lambda (cpy-file); copy files (pngs, css, html, sqlite, js) to site-dir if export is newer than site
                              (message "checking file %s" cpy-file)
                              (let ((dst-file (concat (file-name-as-directory site-dir) (file-name-nondirectory cpy-file))))
                                (if (file-newer-than-file-p cpy-file dst-file)
                                    (progn
                                      (message "copying %s to %s" cpy-file dst-file)
                                      (copy-file cpy-file dst-file t t)))))
                          (directory-files org-dir t "\\(\.png$\\|\.css$\\|\.html$\\|\.sqlite$\\|\.js$\\)"))))
          ((or "-h" "--h" "--help" "help") (message (concat
                           "Usage Information: \n"
                           " all - tangle all org files \n"
                           " install - run README.org's script \n"
                           " install-all - tangle all org files and run their scripts \n"
                           " update - update git submodules \n"
                           " update-guix - update guix packages and guix home \n"
                           " clean - remove generated files \n"
                           " clean-guix - collect guix garbage \n"
                           " ARG.org - tangle and runs ARG \n"
                           " help - Print this message \n")))
          ((pred (and (string-match-p "\.org$" arg)
                      (file-exists-p arg)))
           (let* ((org-file (expand-file-name arg (file-name-directory (or load-file-name buffer-file-name))))
                   (sh-file (concat (file-name-sans-extension org-file) ".sh"))
                   (html-file (concat (file-name-sans-extension org-file) ".html"))
                   (org-id-locations-file (concat (file-name-directory org-file) ".orgids"))
                   (cwd default-directory))
               (if (and (file-newer-than-file-p org-file sh-file)
                       (file-newer-than-file-p org-file html-file))
                   (let ((backup (make-temp-file (file-name-base org-file) nil ".backup.org")))
                     (unwind-protect
                         (let (org-mode-hook org-confirm-babel-evaluate)
                           (copy-file org-file backup t t)
                           (with-current-buffer (find-file-noselect org-file)
                             (require 'ob-tangle)
                             (require 'ox)
                             (org-export-expand-include-keyword)
                             (add-to-list 'org-html-html5-elements "iframe") ; export custom iframe tags
                             (add-to-list 'org-html-html5-elements "input")  ; export custom input tags
                             (add-to-list 'org-html-html5-elements "button") ; export custom button tags
                             (add-to-list 'org-html-html5-elements "dialog") ; export custom dialog tags
                             ;(add-to-list 'org-babel-default-lob-header-args '(:sync))
                             (org-babel-tangle nil nil nil)
                             (ignore-errors
                               (require 'org-id)
                               (org-id-locations-load) ; resolve id links
                               (ignore-errors (require 'org-roam-export))
                               (org-html-export-to-html)
                               (message "Tangled html file %s" html-file) ; set time on html for site diff
                               (set-file-times html-file (time-add (file-attribute-modification-time (file-attributes backup)) (seconds-to-time 1))))))
                       (ignore-errors (copy-file backup org-file t t))
                       (ignore-errors (delete-file backup))))
                 (message "org-file %s is older than html-file %s" org-file html-file))
               (if (or dry-run (not (file-exists-p sh-file)))
                   (message "Tangle Finished for %s \n" org-file)
                 (message "Running script %s \n" sh-file)
                 (cd (file-name-directory org-file))
                 (message (shell-command-to-string sh-file)); scripts can handle their own errors
                 (cd cwd))))
          (_ (if (string-match-p "\.org$" arg)
                 (message "File %s doesn't exist \n" arg)
               (message "Invalid argument %s \n" arg))
             (jam/parse-args (list "help")))))
      argv))
;; main EOF comment
(jam/parse-args argv);#@00
