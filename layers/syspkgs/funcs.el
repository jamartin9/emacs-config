

(defun spacemacs/syspkgs-install ()
  (interactive)
  (let ((pkglist (list "expac" "sudo" "emacs" "zsh" "firefox" "chromium" "veracrypt" "ufw" "gufw" "signal-desktop" "torbrowser-launcher"))
        (system-packages-use-sudo t)
        (system-packages-package-manager 'pacman)
        ) ;; "steam-devices" "python-pip" "emacs-native-comp-git"
    ;;(use-package use-package-ensure-system-package
    ;;  :ensure t)
    (dolist (pkg pkglist)
      (progn
        (system-packages-ensure pkg)
        ))))
