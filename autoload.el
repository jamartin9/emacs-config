;;; $DOOMDIR/autoload.el -*- lexical-binding: t; -*-

;;; GUIX

;;;###autoload
(defun jam/guix-env()
  "Guix variables for local guix daemon/client"
  (interactive)
  (setenv "GUIX_DAEMON_SOCKET" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                       (file-name-as-directory "guix")
                                       (file-name-as-directory "var")
                                       (file-name-as-directory "guix")
                                       (file-name-as-directory "daemon-socket") "socket"))
  (setenv "GUIX_DATABASE_DIRECTORY" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                            (file-name-as-directory "guix")
                                            (file-name-as-directory "var")
                                            (file-name-as-directory "guix") "db"))
  (setenv "GUIX_LOG_DIRECTORY" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                       (file-name-as-directory "guix")
                                       (file-name-as-directory "var")
                                       (file-name-as-directory "log") "guix"))
  (setenv "GUIX_STATE_DIRECTORY" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                         (file-name-as-directory "guix")
                                         (file-name-as-directory "var") "guix"))
  (setenv "GUIX_CONFIGURATION_DIRECTORY" (concat (file-name-as-directory (getenv "XDG_CONFIG_HOME"))
                                                 (file-name-as-directory "guix") "etc"))
  (setenv "GUIX_LOCPATH" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                 (file-name-as-directory "guix")
                                 (file-name-as-directory "var")
                                 (file-name-as-directory "guix")
                                 (file-name-as-directory "profiles")
                                 (file-name-as-directory "per-user")
                                 (file-name-as-directory "root")
                                 (file-name-as-directory "guix-profile")
                                 (file-name-as-directory "lib") "locale"))
  (setenv "NIX_STORE" (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                              (file-name-as-directory "guix")
                              (file-name-as-directory "gnu") "store"))
  (setenv "PATH" (concat (getenv "PATH")
                         path-separator (concat (file-name-as-directory (getenv "XDG_DATA_HOME"))
                                     (file-name-as-directory "guix") "bin")))
  )

;;;###autoload
(defun jam/librefm-stream (station)
  "Start default stream with emms. Uses pass for login information."
  (interactive
   (list
    (read-string
     (format "Station (librefm://globaltags/Classical): ")
     nil
     nil
     "librefm://globaltags/Classical")))
  (message "station is %s" station)
  (setq emms-librefm-scrobbler-username "jaming"
        emms-librefm-scrobbler-password (alist-get 'secret (auth-source-pass-parse-entry "librefm/jaming")))
  (emms-librefm-stream station))

;;;###autoload
(defun jam/save-all ()
  "Saves all buffers"
  (interactive)
  (save-some-buffers t))

;;;###autoload
(defun jam/vterm ()
  "opens new vterm"
  (interactive)
  (vterm t))

;;;###autoload
(defun jam/newsticker-download ()
  "Downloads the current newsticker enclosure to tmpdir/newsticker/feed/title"
  (interactive)
  (let* ((item (newsticker--treeview-get-selected-item))
         (feedname "jam")
         (title (newsticker--title item))
         (enclosure (newsticker--enclosure item))
         (download-dir (file-name-as-directory
                        (expand-file-name (newsticker--title (newsticker--treeview-get-selected-item))
                                          (expand-file-name feedname (expand-file-name "newsticker" temporary-file-directory))))))
  (newsticker-download-enclosures feedname item)
  (emms-play-directory download-dir)
  ;(delete-directory download-dir t)
  ))

;;;###autoload
(defun jam/replace-unicode ()
  "Replaces the following unicode characters (be wary of IDN urls):
ZERO WIDTH NO-BREAK SPACE (65279, #xfeff) aka BOM
ZERO WIDTH SPACE (codepoint 8203, #x200b)
RIGHT-TO-LEFT MARK (8207, #x200f)
RIGHT-TO-LEFT OVERRIDE (8238, #x202e)
LEFT-TO-RIGHT MARK ‎(8206, #x200e)
OBJECT REPLACEMENT CHARACTER (65532, #xfffc)"
  (interactive)
  (query-replace-regexp "\ufeff\\|\u200b\\|\u200f\\|\u202e\\|\u200e\\|\ufffc" ""))

;;;###autoload
(defun jam/chia-lsp-setup ()
  "Adds syntax highlighting to chialisp and lsp client"
  (interactive)
  (define-generic-mode 'chialisp-mode
    '(";;")
    '("mod" "defun" "defun-inline" "defmacro" "defconstant")
    '(("\\(A\\(?:GG_SIG_\\(?:\\(?:M\\|UNSAF\\)E\\)\\|SSERT_\\(?:COIN_ANNOUNCEMENT\\|HEIGHT_\\(?:\\(?:ABSOLUT\\|RELATIV\\)E\\)\\|MY_\\(?:AMOUNT\\|COIN_ID\\|P\\(?:ARENT_ID\\|UZZLEHASH\\)\\)\\|PUZZLE_ANNOUNCEMENT\\|SECONDS_\\(?:\\(?:ABSOLUT\\|RELATIV\\)E\\)\\)\\)\\|CREATE_\\(?:COIN\\(?:_ANNOUNCEMENT\\)?\\|PUZZLE_ANNOUNCEMENT\\)\\|RESERVE_FEE\\)" 1 'font-lock-variable-name-face)
      ("\\(i\\(?:f\\|nclude\\)\\|list\\|sha256\\)" . 'font-lock-constant-face))
    '(".cl\\(sp\\|vm\\|ib\\)\\'")
    nil
    "Generic mode for chialisp syntax highlighting")
  (with-eval-after-load 'lsp-mode
    (add-to-list 'lsp-language-id-configuration
                 '(chialisp-mode . "chialisp"))
    (lsp-register-client ;; TODO unzip VSX extension in path
     (make-lsp-client :new-connection (lsp-stdio-connection '("node" "/home/jam/.vscode/extension/runner/build/runner.js"))
                      :activation-fn (lsp-activate-on "chialisp")
                      :server-id 'chialisp))))

;;;###autoload
(defun jam/utf-banner ()
  "draws qr gpg pub key banner"
    (mapc (lambda (line)
          (insert line)
          (insert "\n"))
        '(
"█████████████████████████████████████████████████████████████████████████████████████████████
██ ▄▄▄▄▄ █ ▄▄ █ █   ▄▄ █▄█▀███▄▄ ▀▄▄ ▄▄▄█▄ ▄▄ ██ ▄ ▄▀▄▀ ▀ █▀▄ ▄▄▀▄██▀▀  ▄  ▀ ▄█▀▄ ▄█ ▄▄▄▄▄ ██
██ █   █ █ ▀▄▀▀▀ █▄▀ ▀▀ ▄▀█▄█▀▀ ▄█▄▄ ▀█▀▀▄   ▀▀▄  ▀▀ ▀▄▄█▄▀ ▀ ███  ▄▄█▄▄▀▄▀ ██▄█▀█▀█ █   █ ██
██ █▄▄▄█ █▀ ▄▄ █▄█▄▄▄▄▀▀▀▀▀█ █ ▄▄▄ ▀██▀▄▄▄   ▄█▀█▄█ ▄▄ █ ▄▄▄  ▄▀▀ ▀▀▀█ ▀▄█▄█ █▀▀█ ██ █▄▄▄█ ██
██▄▄▄▄▄▄▄█▄█▄▀ ▀▄█▄█ ▀▄█ ▀ ▀ █ █▄█ ▀ █▄▀▄▀▄▀ ▀ ▀▄▀▄█▄█ ▀ █▄█ █▄▀▄█ █ █▄▀▄▀▄▀▄█▄█ █▄█▄▄▄▄▄▄▄██
██ ▄▀█ ▄▄█▀▄▄▄▀▀█▀   ▄▀██▄ ▄▀█▄▄ ▄▄▄▄▀▄█▀▀▀██▀▀ ▄▀██▀▀▄▀▄ ▄▄▄  ▀  ▄▄▄▄ ██▀ ▀ █▀▄ █▄█▀▄█ ▄  ██
███▄▀█▄▀▄▄  ▄▄█▄▀█▄▄ ▀▀▄▀██ ▀▄▄  ▄▄ ▀▄█  ▄▀ ▀██ ▄▄  ▀▄  █▀▄   ▄ ▀▀█▄█▀▄▄█▄▀██ ▄▄ ██  ▀  ▄▄▄██
██▀▀▄▀█▀▄▄▀█ ▀ ▄████ ▄▄██▄▀▀▄ ▀▀ ▀ ▄▄▄█▄█▀█▄▀ ▄▄ ▀█▄█▀██▄▄  ▀  █▄▀   ▀▀▄█▀▀ ▀█▄▄ █▄▀ █▀ ▄█▀██
██  ██▄▀▄▀█▄▄▄ ▄█▀ ▄▄▀█▄ ████ ▄██▄█▀▀▄▀██ ▄▄▄▀▄  ▄███   ▀▀▄█▄ ▄▀   ██▀█▀█  ██  ▀▀▄  █▄▄▄▀▄███
██▀▀ ▄▄█▄ ▄▀█▄▀▄█   ████▀██▀▀██▄▄ ▀▄▀▀█ █▀  ▄ █▄▄▀▀▀█ ▀▄ ▀▄ ▀  █ ▄▄ ▄▀▀▄██ ▄█▀█    ▀▀▄▀ ██ ██
██▀█ ▀▄▀▄▄ ▄▄▄▀▀ ▀██ ▀▀█ ▀█▀█▀ ▀ ▀    ▄▄▄█▄ ▄█▄ █ ▄█▄ ▀▄█ ▀█▄▀█▀▄█  ▀▀▀  ▄▀ ▀▀  █ ▀▀▄ ▀▀▄▀███
██▀▄█▄▄█▄▄ ▀ ▄▄▀▄ ▄▄█▄▄▄▀▀▀ █▀█▄▀ ▀█▄▄█▀██▀▄  ██ ▄█ █▀▄▀▄▀▄▄████  ██ ▄▀▄██ █▄▄▄█▄▄▄▄▀▀▀▀▄█▄██
███▄█▄▄▄▄ █▀▄▀ ▄█ ██▄▀█▀██▄ █▄█▄▀▄  █▀▄▄█▄█▀▀▀▀ ██▄█▀ █ █▄▄██▄█▀█  █ ▄   ▄▄▄█   ▄ █▀▀▀▀█▄ ███
██ █▀█▀ ▄▀▄  █ ██▄ ▀▀▄▀▄▀█▄▄▀██▄ █▄ ▄ ▀▀▄▄▀▀▀▀▄▀ ▄ ▀▀▀▄ ▄▀▄▄▀▀  ▄ ▄▄▄▄ ▄▀  ▀▄ ▄█▀▀ █ ▄▀▄▄▀▀██
██▀█ ███▄▄▀▄ ██████ ▀  █▄█  █   ▀▄ ▄▄▀▄▄    █▀▄▄▄▄▀▄ ▄▄▀▀▀█▄█ ▀▀ █▀▄█▄▄   ▄▀ ▀▀▄█▄▀▀█▀▄ ▄▄▄██
██▄▄ ▀ ▄▄▄ ▀██▄▄▀  ▀▄ ▄▄▀ ▄▄ ▄ ▄▄▄ ▀  ▄▀▀█▀▄▀▄ ▀ ▄▄ ██▀█ ▄▄▄ ▄▀▀▄▀▄  ▄▄ ▄▀ ▀ ▄▄▄▄  ▄▄▄ ▀██▄██
████ ▀ █▄█ ▄▀█ ██▄▄▄ ██▄ █▀ ▄▄ █▄█   ▄▄▄▄ ▀▀▄██  ▄█▄  ██ █▄█   ▄▀▀█▄█▄ ▀  █▀▀ ▄ ▀█ █▄█ █  ▄██
██▄ ██▄▄▄ ▄▀▄█▀▄▄▀ ██▀▀▀▀    ▀▄▄ ▄ ▀█▄█▀  ▀██▄  ▄▄▄ █▀ █▄▄▄▄▄█ █▄▀█▀▄▄▀▄▀▄▀▀ █▀  ▀ ▄ ▄▄  █▀██
██▄▄  ▀ ▄█▀▄▀▄██▀ ▄  ▀▄█▀▀▀██ ▄▀▀▀ ▀▄▄▄▄█  ▀▀▀▄  ▄▄▄▄  ▄█ ▀ ███▄█ ▄▀██▄▀▀▄▀▀█▄▄█▀▀ █▀ ▀▄▀▄▀██
██ ▀▀▄█ ▄ ▄▄   ▄  █ █  ▀▄▄▄ ▀█  ▀ ██▄▄▄▀ ▄ ▀▀ ▄█ ▄█▀ ▄  ▄▀▄  ▀ ███▀▄ ▄▀ ▀▀ ▄  ▀▄ █ █ ▀▄ ▀▀ ██
██▀ █  ▀▄█▄▀▀▀█▄▀▄▄  ▄█▀▀█▀ ▄ ▀▀█▀▄▀█  ▄█▀▀▄█▀█ ▄  ▄▀▀▀▀ ██▀▄ █ ▀▄█ ▀█ █▄▀█ ▀▄▀▄██  ▀▄██▄█ ██
███▀▄  █▄▄▄▀  ▄█▀▀████▄█▀█▄ ▀▀▀ ▀  ▄ ▀▄ ▀▀▀▀▄ ▄▄ ▄▄▀▀▀ ▄▀█ ▄█▀▀▀ █▄▀▄█ ▄█▄  █▀█▄▄█▀█▀▀▄▀ ▄ ██
██▄▄▄  ▀▄██▄ ▄█▄ ▀  ▄▀▀▄▀▀▀▀▄▄███▄   ▄██  ▀█ ▀▄▀█▄█▄█▄█  ▀█▀█ ██▀█▄ ▀▄▀█▀▄ ▄ █▄  ▀▄▄█▄▀▄▄▀▄██
████ ▄ █▄ ██ █▄▄▄▄▄█▄▀▄ ▄█▄█ ▀▄█▀▀▀█ ▀  ▀▄ ▀█ ▄▀▄▀ ▀▄▀▀▄▀█▄▀█▄ ▀▄▀▄▄ ▄  ▀█ █ ▀▄ █ ██▀▄ █▀ ▄██
██▄▀██ ▀▄ █ █▀▀██▀  ▄ █▀▀ █▀█▄▄ █ ▀▀▄ ██▄▄▀ █▀█   ▀█  ▀▄ █▀█▀ █▀▄▀▀▄ █▀█ ▀ █▄▄▀▀█▀█ ▀ ██▄ ▄██
██  ▀▀▄ ▄▄▀██▀  █▀█  ▄▄█▀▀▄█▀█▀▄ ██▀▄▄▄ ██ ██▄▀ ▄▀▄ █  ▀▄ ▄▀▄ ▀▀ ▀▄▀▄█  █▀ ▀  ▄▄█▀█▀██▀▄▀▀▀██
██▄▄ █▄█▄ ▄███ ▀▀▀▄ ▀██  ▄  █ █▀█ ▀ ▀▀█▄  ▄  █▄▀▀  ▄  █▄▀█ ▀   ▄▀█▀██▄ ▄█▀▄██ ▀██ █▄█▀▄██▄▀██
██▄▄▀▄ █▄█▄██▄▀ ▀▀▄▀█▄▀█▄  ▀▀ ▀ ▀  ▄█▄█ ▀ ▀ ▀▀█▄█▀██ █▀▀█ ▄ █  █▄▀▄   ▄ ▄▀ ▀ ▀▄▄▄ ██  █  ▀▄██
██▀▄ █ ▄▄▄ █ █▄█▀█▀▄▀ ▄▄▀█▀▀ ▄ ▄▄▄ ▀  ▀▀▀   ▄ ▄▀  ▀▄▀▄█▀ ▄▄▄ ▀▀ █ █▀███▄▄▀▀▀▀▄ █▄█ ▄▄▄ █▄ ▄██
██▀▄█▀ █▄█  ▄ ▄████ █▀▀▄▀▀█ ▀▀ █▄█ █▄▀▀ ▀▀ █▀▄▀▄▄▀▀█▀▀ ▀ █▄█  ▀█ ▀█▄ █ ▄█ ▀▀▄██ ▄▄ █▄█ ▀▀▀ ██
██▄▄  ▄▄▄▄ ▀▀██ ██▄▄▀▀▀█ ██ ▀▀   ▄▄ █▄▄ ▀▄ ▀ ▀▄ ▀ █  ▄▀█▄▄▄▄  ▄▀▀▀▄▀██▄▀ ▀▄  ▄▄█▀▄▄▄  ▄█▄ ███
██▀▀▄▄█▄▄ ▀█▀ █▀▄  ▀  █▄█▀ ▀▄▀███▀▀█▄ ▄▄█▀█▄▀ ▄ ▄▀▄▄█▀█▄ █▀▀ ▀ █ ▀█▄ ▄ ▄▀ ▀█  ▀   ▄▄▄▀▄▀ ▀▄██
███ ▄▄  ▄ █▄▄ ▄ ▄▄█▀ ▄█▄ ██▄█▀█ ██▀  ▄ ██ ▄▀ █▄▀  ▀██  █▄▄█▀  ▀▄   ▄▀  ▄▄ ▄  █▀▄██ ▄▄  █▄ ▀██
███▄█ ▀▄▄█▄ ▄█▄▀ ▀ ███▄▀▄▀▄▀▀▀█▀█ ▀█ ▀█▀██ ▀▀ ██▄█▄▀▄▀▀█ █ ▄ ▀ ▀ ▀█▄ ▄▀ ██ █▄▀▄▄ ▄▄█ ▀ ▀█▄███
██▀▀▀█▀█▄█▀ █ ▄▄▄█▄▀▀ ██▀▀█ ▄ ▀██ ▀ █ ▄██  ▀█▀▄ ▄ ██▀▄  ▄ █ ▄▀██▀█ █ ▀▄ ▀▄▀ █ ▀▄ ▄▀ █▀ ▀█▄▄██
██ ▄▀ █ ▄▀▀▀▀▀▀▀  ▀▀▀  ▄▄▀▀ ▄█▄▀▀ ▀▄ ▄█ ▀█ ▄ ▄█▄▄▄█ ██ ▀▀▄▀█▀█ █  ▄█ ▀▀ ▀ ▄█ ▀█▀█▀▀██▀ ▀▄ ▄██
███▄▀▀ █▄▀█▄▄▀▄  ▄▀▀▀ ▀█ █▄▀▄ ▄ ▄▄███▀▄▄▀▄▀▀▀█▄▀▀▀▄▄ ▄ ▄▄▄█▀ ▄█▀▄ ██ ▀█ ▄██ ▀▀█ ▄ ▄ █▀▄▀█▄███
██▄█▄▀█ ▄ █▀█ ▀ ██▄ ▄ ▀ ▀▀ ▄▀▀  ▀▀  ▀█ ▄▀  ▄█ ▄▄▀▄█▀▄▄▀ ▀▄ █▀  ▀ ▀█▄▄▄  ▀▀ █▄ █▀█ ▀▀▄ ▄▄▀▀▄██
██▄  ▀█ ▄▀▀ ▀▀▄▀▀▄ ██▄▀█▄██▀██▀ ██ ▄▄ █▄▀▄▀ ▄▀▄▄█▄██▀ ▀▀██▀▀▄▄▄  █▀ ▄▄ █▄▄██▀▀ ▄█▀█▄█▄▀▄█ ▄██
██ ▀ ██▄▄█ ▄██▀▄▀▀ ▄  ▄▄▀ ▄▀ ▀▄▄█▄▄▀  ▄▄▀▀  █▄ ▀ █▄▀▄ ▄▀ █▄    █ ▀██ ▄▀▀▄▀ █ ▄▄▀▄██▄██▄ ▄█▀██
██ ▀█▄▀▀▄█  ▄  ▀█▀   ███  ▀▀▀█▀▀▄▄  ▄▄█ ▀   ███   ▄█▄▄▄ ▀▄  ▄ ▄▄█ ▄  ▄█ ███▀█▀▀ ▄▀▄ ▀█▀▄ ▀▄██
██▄██▄██▄▄ █    ▀█▄▄▄▄ ▄▀█▀ ▄  ▄▄▄  ▄▀█ ▄▄ ▄███   ▀▀▀ ▀█ ▄▄▄ ▄▀▀▄ █▄▄█▀▄█  ▀   ▄▄█ ▄▄▄   █▄██
██ ▄▄▄▄▄ █▀▄▀▀█▄█ █▀█▀▄█ █▀██  █▄█  ▄ ▄██ ▀▀██▀  ▄▀▄█ ▀  █▄█ ▀▀▄   █▀ █▀▀▄▀█  ▄▄█▀ █▄█ █▄▄▄██
██ █   █ █▄▀▀▄█▄▀█▀▄ ▄  ██  ▀▀▄▄▄▄▄█▄██▀ ▄ ▄▀▀▄█▄▀█▀ ▄ ▀ ▄ ▄ ▀▀▀ █▄▄▄▄▀ █▀▀▀█▄▀  ▀▄▄▄▄▄ ▄████
██ █▄▄▄█ █▀▄█▄▄  ▀▄▀▄▄▀▄▀█▀ ▄▄▄▀▀██▀▄ █▄▀▀▀█ █▄ ▄ ▄▄███▀▀ ▀ ▀▀████ ▀▄█▀█ ██▀ ▀█ █▀ ▄██▀█▄ ▄██
██▄▄▄▄▄▄▄█▄█████▄▄▄▄██▄█▄█▄█▄█▄█▄██▄▄▄████▄██▄▄█▄██▄██▄██▄██▄█▄█▄██▄▄████████▄█▄▄▄█▄██▄█▄████
█████████████████████████████████████████████████████████████████████████████████████████████
"          )))
