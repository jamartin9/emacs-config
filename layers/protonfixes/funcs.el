
(defun spacemacs/protonfixes-link-local ()
  (interactive)
  (let (proton-dir localfixes-dir)
    (setq proton-dir (concat (if (getenv "XDG_CONFIG_HOME")
                                (file-name-as-directory (getenv "XDG_CONFIG_HOME"))
                              (file-name-as-directory (concat (file-name-as-directory (getenv "HOME"))
                                                              ".config")))
                            "protonfixes"))
    (setq localfixes-dir (concat (file-name-as-directory proton-dir)
                                "localfixes"))
    (if (not (file-exists-p proton-dir))
        (make-directory proton-dir))
    (if (not (or (file-exists-p localfixes-dir) (file-symlink-p localfixes-dir)))
        (make-symbolic-link (concat dotspacemacs-directory
                                    (file-name-as-directory "layers")
                                    (file-name-as-directory "protonfixes")
                                    (file-name-as-directory "localfixes"))
                            localfixes-dir))))
