":"; emacs --script make-el.el -- $@ $args ; exit $? # -*- mode: emacs-lisp; lexical-binding: t; -*-
;;;###autoload
(defun jam/parse-args (argv &optional no-run)
"ARGV: Parse cli arguments from list.
NO-RUN: do not run the tangled argument"
  (mapc (lambda (arg)
        (pcase arg
          (" " (message "\n"))
          ("--" (message "### make-el.el ###\n"))
          ("$@" (message "\n"))
          ("all" (jam/parse-args (directory-files-recursively (file-name-directory (or load-file-name buffer-file-name))
                                                              "\.org$" nil
                                                              #'(lambda (local-dir)
                                                                  (if (string-match-p "\\(\.git$\\|doomemacs$\\|guix-channel$\\|profile$\\)" local-dir) nil t)))
                                 t))
          ("install" (jam/parse-args (list "README.org"))
                     (message "%s" (process-lines (concat (file-name-directory (or load-file-name buffer-file-name))
                                                     (file-name-as-directory "doomemacs")
                                                     (file-name-as-directory "bin")
                                                     "doom")
                                                  "sync")))
          ("install-all" (jam/parse-args (directory-files-recursively (file-name-directory (or load-file-name buffer-file-name))
                                                                      "\.org$" nil
                                                                      #'(lambda (local-dir)
                                                                          (if (string-match-p "\\(\.git$\\|doomemacs$\\|guix-channel$\\|profile$\\)" local-dir) nil t)))))
          ("update" (let ((dir (file-name-directory (or load-file-name buffer-file-name))))
                      (message "%s" (process-lines "git" "-C" dir "submodule" "update" "--recursive" "--remote"))
                      (message "%s" (process-lines-ignore-status "git" "-C" (concat dir "doomemacs") "remote" "add" "upstream" "https://github.com/doomemacs/doomemacs.git")); || :
                      (message "%s" (process-lines "git" "-C" (concat dir "doomemacs") "fetch" "--all"))
                      (message "%s" (process-lines "git" "-C" (concat dir "doomemacs") "merge" "upstream/master"))
                      (message "%s" (process-lines (concat dir (file-name-as-directory "doomemacs") (file-name-as-directory "bin") "doom") "sync" "-upe"))))

          ("update-guix" (let ((dir (file-name-directory (or load-file-name buffer-file-name))))
                      (message "%s" (process-lines "guix" "pull")); --disable-authentication --allow-downgrades
                      (jam/parse-args (list (concat dir (file-name-as-directory "org") (file-name-as-directory "roam") "guix.org")))
                      (message "%s" (process-lines "guix" "home" "reconfigure" (concat dir (file-name-as-directory "org") (file-name-as-directory "roam") "home.scm")))
                      (message "%s" (process-lines "guix" "package" "-u"))))
          ("clean" (mapc #'(lambda (del-file)
                             (message "Deleting file %s \n" del-file)
                             (delete-file del-file))
                           (directory-files-recursively (file-name-directory (or load-file-name buffer-file-name))
                                                "\\(\.sh$\\|\.yml$\\|^\.torrc$\\|\.py$\\|\.scm$\\|\.css$\\|\.html$\\|.html~$\\)" nil
                                                #'(lambda (local-dir)
                                                    (if (string-match-p "\\(\.git$\\|doomemacs$\\|guix-channel$\\|profile$\\)" local-dir) nil t)))))
          ("clean-guix" (message "%s" (process-lines "guix" "package" "-d"))
                        (message "%s" (process-lines "guix" "pull" "-d"))
                        (message "%s" (process-lines "guix" "home" "delete-generations"))
                        (message "%s" (process-lines "guix" "gc")))
          ((or "-h" "--h" "--help" "help") (message (concat
                           "Usage Information: \n"
                           " all - tangles all org files and runs install scripts \n"
                           " install - runs README.org's script and then syncs doom \n"
                           " install-all - tangles all org files and runs their scripts \n"
                           " update - updates doom packages \n"
                           " update-guix - updates guix packages \n"
                           " clean - removes generated files \n"
                           " clean-guix - collect guix garbage \n"
                           " ARG.org - tangles and runs ARG \n"
                           " help - Prints this message \n")))
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
                             ;(add-to-list 'org-babel-default-lob-header-args '(:sync))
                             (org-babel-tangle nil nil nil)
                             (ignore-errors
                               (require 'org-id)
                               (org-id-locations-load) ; resolve id links
                               (ignore-errors (require 'org-roam-export))
                               (org-html-export-to-html)
                               (message "Tangled html file %s" html-file))))
                       (ignore-errors (copy-file backup org-file t t))
                       (ignore-errors (delete-file backup))))
                 (message "org-file %s is older than sh-file %s \n" org-file sh-file))
               (if (or no-run (not (file-exists-p sh-file)))
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
