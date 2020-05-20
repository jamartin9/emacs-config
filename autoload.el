;;; $DOOMDIR/autoload.el -*- lexical-binding: t; -*-

;;;
;;; set user-env
;;;

;;;###autoload
(defun jam/set-env ()
  "Sets commmonly used environment variables"
  (interactive)
  (setenv "XDG_CONFIG_HOME" (concat (file-name-as-directory (getenv "HOME")) ".config"))
  (setenv "XDG_CACHE_HOME" (concat (file-name-as-directory (getenv "HOME")) ".cache"))
  (setenv "XDG_DATA_HOME" (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".local") "share"))

  (setenv "PATH" (concat (getenv "PATH") ; add bin dirs to path
                         ":" (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".local") "bin")
                         ":" (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".cargo") "bin")
                         ":" (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory ".npm-packages") "bin")
                         ":" (concat (file-name-as-directory (getenv "HOME")) (file-name-as-directory "go") "bin")
                         ":" (concat (file-name-as-directory (getenv "XDG_CONFIG_HOME")) (file-name-as-directory "doom") (file-name-as-directory "doom-emacs") "bin")
                         ))
  ;;(setenv "JAVA_TOOL_OPTIONS" "-XX:+PrintFlagsFinal -XX:+UnlockDiagnosticVMOptions -XX:+UnlockExperimentalVMOptions -XX:+EnableJVMCI -XX:+UseJVMCICompiler -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=heapdump.hprof -XX:StartFlightRecording=disk=true,dumponexit=true,filename=recording.jfr,maxsize=1024m,maxage=1d,settings=profile,path-to-gc-roots=true -Xlog:gc:gc.log:utctime,uptime,tid,level:filecount=10,filesize=128m -XX:NativeMemoryTracking=detail -XX:+PreserveFramePointer")
  ;;(setenv "GUILE_LOAD_PATH" (concat
  ;;                           (expand-file-name "~/.guix-profile/share/guile/2.2")
  ;;                           ":" (expand-file-name "~/.guix-profile/share/guile/3.0")))
  ;;(setenv "GUILE_LOAD_COMPILED_PATH" (concat (expand-file-name "~/.guix-profile/lib/guile/2.2/ccache")
  ;;                                           ":" (expand-file-name "~/.guix-profile/lib/guile/3.0/ccache")))
  ;;(setenv "GUIX_LOCPATH" (concat (file-name-as-directory (getenv "HOME"))
  ;;                               (file-name-as-directory ".guix-profile")
  ;;                               (file-name-as-directory "lib") "locale"))
  )

;;;
;;; custom zsh
;;;

;;;###autoload
(defun jam/custom-shell-link ()
  (interactive)
  (let ((zsh-dir (concat (if (getenv "XDG_CONFIG_HOME") (file-name-as-directory (getenv "XDG_CONFIG_HOME"))
                           (file-name-as-directory (concat (file-name-as-directory (getenv "HOME")) ".config")))
                         "zsh"))
        (home-zshrc (concat (file-name-as-directory (getenv "HOME")) ".zshrc")))
    (if (not (or (file-exists-p zsh-dir) (file-symlink-p zsh-dir)))
        (make-symbolic-link (concat (expand-file-name doom-private-dir) "zsh-config") zsh-dir 1))
    (if (not (or (file-exists-p home-zshrc) (file-symlink-p home-zshrc)))
        (make-symbolic-link (concat (expand-file-name doom-private-dir) (file-name-as-directory "zsh-config") ".zshrc") home-zshrc 1))))

;;;
;;; custom protonfixes
;;;

;;;###autoload
(defun jam/protonfixes-link-local ()
  (interactive)
  (let* ((proton-dir (concat (if (getenv "XDG_CONFIG_HOME") (file-name-as-directory (getenv "XDG_CONFIG_HOME"))
                              (file-name-as-directory (concat (file-name-as-directory (getenv "HOME")) ".config")))
                            "protonfixes"))
        (localfixes-dir (concat (file-name-as-directory proton-dir) "localfixes")))
    (if (not (file-exists-p proton-dir))
        (make-directory proton-dir))
    (if (not (or (file-exists-p localfixes-dir) (file-symlink-p localfixes-dir)))
        (make-symbolic-link (concat (expand-file-name doom-private-dir) "localfixes") localfixes-dir 1))))

;;;
;;; system packages
;;;

;;;###autoload
(defun jam/syspkgs-install ()
  (interactive)
  (let ((pkglist (list "expac" "sudo" "emacs" "zsh" "firefox" "chromium" "veracrypt" "ufw" "gufw" "signal-desktop" "torbrowser-launcher")) ;; expac is needed for syspkgs -_-
        (system-packages-use-sudo t)
        (system-packages-package-manager 'pacman)) ;; "steam-devices" "python-pip" "emacs-native-comp-git"
    ;;(use-package use-package-ensure-system-package
    ;;  :ensure t)
    (dolist (pkg pkglist)
      (progn
        (system-packages-ensure pkg)))))

;;;
;;; GUIX
;;;

;;;###autoload
(defun jam/guix-source (filename)
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

;;;###autoload
(defun jam/guix-link-channels ()
  (interactive)
  (let* ((guix-dir (file-name-as-directory (concat (if (getenv "XDG_CONFIG_HOME") (file-name-as-directory (getenv "XDG_CONFIG_HOME"))
                                                    (file-name-as-directory (concat (file-name-as-directory (getenv "HOME")) ".config")))
                                                  "guix")))
        (guix-channel-file (concat guix-dir "channels.scm")))
    (if (not (file-exists-p guix-dir))
        (make-directory guix-dir))
    (if (not (or (file-exists-p guix-channel-file) (file-symlink-p guix-channel-file)))
        (make-symbolic-link (concat (expand-file-name doom-private-dir) (file-name-as-directory "channels") "channels.scm") guix-channel-file 1))))

;;;###autoload
(defun jam/guix-link-shepherd ()
  (interactive)
  (let ((shepherd-dir (file-name-as-directory (concat (if (getenv "XDG_CONFIG_HOME") (file-name-as-directory (getenv "XDG_CONFIG_HOME"))
                                                    (file-name-as-directory (concat (file-name-as-directory (getenv "HOME")) ".config")))
                                                  "shepherd"))))
    (if (not (or (file-exists-p shepherd-dir) (file-symlink-p shepherd-dir)))
        (make-symbolic-link (concat (expand-file-name doom-private-dir) (file-name-as-directory "shepherd")) shepherd-dir 1))))

;;;###autoload
(defun jam/default-prof ()
  "TODO: ensure glibc-locales are installed in default prof and its profile is sourced")

;;;###autoload
(defun jam/install-guix ()
  "TODO: script install/url hash check for update")

;;;
;;; fix kbd light
;;;

;;;###autoload
(defun jam/create-xmod ()
  "creates xmod file"
  (when (not (file-exists-p (expand-file-name "~/.Xmodmap")))
    (write-region "add mod3 = Scroll_Lock" nil (expand-file-name "~/.Xmodmap"))))

;;;
;;; Main
;;;

;;;###autoload
(defun jam/init ()
  "Runs my stuff"
  (interactive)
  ;; Copy-cut-paste-undo
  (cua-mode t)
  (jam/set-env)
  ;;(jam/create-xmod)
  (jam/custom-shell-link)
  (jam/protonfixes-link-local)
  ;;(jam/syspkgs-install)
  (jam/guix-link-shepherd)
  (jam/guix-link-channels))
