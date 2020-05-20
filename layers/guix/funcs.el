(defun spacemacs/guix-source (filename)
  "Update environment variables from a shell source file."
  (interactive "fSource file: ")
  (message "Sourcing environment from `%s'..."
           filename)
  (with-temp-buffer
    (shell-command (format "diff -u <(true; export) <(source %s; export)"
                           filename)
                   '(4))
    (let ((envvar-re "declare -x \\([^=]+\\)=\\(.*\\)$"))
      ;; Remove environment variables

      (while (search-forward-regexp (concat "^-" envvar-re)
                                    nil
                                    t)
        (let ((var (match-string 1)))
          (message "%s"
                   (prin1-to-string `(setenv ,var nil)))
          (setenv var nil)))
      ;; Update environment variables
      (goto-char (point-min))
      (while (search-forward-regexp (concat "^+" envvar-re)
                                    nil
                                    t)
        (let ((var (match-string 1))
              (value (read (match-string 2))))
          (message "%s"
                   (prin1-to-string `(setenv ,var ,value)))
          (setenv var value)))))
  (message "Sourcing environment from `%s'... done."
           filename))

(defun spacemacs/use-manifest-prof ()
  "TODO: install manifest in different profile and use it to avoid conflicts")

(defun spacemacs/default-prof ()
  "TODO: ensure glibc-locales are installed in default prof and its profile is sourced"

  ;;(setenv "GUILE_LOAD_PATH" (concat
  ;;                           (expand-file-name "~/.guix-profile/share/guile/2.2")
  ;;                           ":" (expand-file-name "~/.guix-profile/share/guile/3.0")))

  ;;(setenv "GUILE_LOAD_COMPILED_PATH" (concat (expand-file-name "~/.guix-profile/lib/guile/2.2/ccache")
  ;;                                           ":" (expand-file-name "~/.guix-profile/lib/guile/3.0/ccache")))
  ;;(setenv "GUIX_LOCPATH" (concat (file-name-as-directory (getenv "HOME"))
  ;;                               (file-name-as-directory ".guix-profile")
  ;;                               (file-name-as-directory "lib") "locale"))

  )

(defun spacemacs/install-guix ()
  "TODO: script install/url hash check for update")

(defun spacemacs/guix-link-channels ()
  (interactive)
  (let (guix-dir guix-channel-file)
    (setq guix-dir (file-name-as-directory (concat (if (getenv "XDG_CONFIG_HOME")
                                                      (file-name-as-directory (getenv "XDG_CONFIG_HOME"))
                                                    (file-name-as-directory (concat (file-name-as-directory (getenv "HOME"))
                                                                                    ".config")))
                                                  "guix")))
    (setq guix-channel-file (concat guix-dir "channels.scm"))
    (if (not (file-exists-p guix-dir))
        (make-directory guix-dir))
    (if (not (or (file-exists-p guix-channel-file) (file-symlink-p guix-channel-file)))
        (make-symbolic-link (concat dotspacemacs-directory
                                    (file-name-as-directory "layers")
                                    (file-name-as-directory "guix")
                                    (file-name-as-directory "channels")
                                    "channels.scm")
                            guix-channel-file))))


(defun spacemacs/guix-link-shepherd ()
  (interactive)
  (let (shepherd-dir)
    (setq shepherd-dir (file-name-as-directory (concat (if (getenv "XDG_CONFIG_HOME")
                                                      (file-name-as-directory (getenv "XDG_CONFIG_HOME"))
                                                    (file-name-as-directory (concat (file-name-as-directory (getenv "HOME"))
                                                                                    ".config")))
                                                  "shepherd")))

    (if (not (or (file-exists-p shepherd-dir) (file-symlink-p shepherd-dir)))
        (make-symbolic-link (concat dotspacemacs-directory
                                    (file-name-as-directory "layers")
                                    (file-name-as-directory "guix")
                                    (file-name-as-directory "shepherd"))
                            shepherd-dir))))
