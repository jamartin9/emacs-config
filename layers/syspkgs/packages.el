(defconst syspkgs-packages '(system-packages (helm-system-packages :toggle (configuration-layer/package-usedp 'helm))))

(defun syspkgs/init-system-packages ()
  (use-package system-packages
    :ensure t
   ;; :config (progn
   ;;           )
    ))

(defun syspkgs/init-helm-system-packages ()
  (use-package helm-system-packages :commands helm-system-packages))
