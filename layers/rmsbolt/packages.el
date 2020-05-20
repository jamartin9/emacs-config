(defconst rmsbolt-packages
      '(
        rmsbolt
        ))

(defun rmsbolt/init-rmsbolt()
  (use-package rmsbolt
    :init (progn
            (spacemacs/declare-prefix "ar" "rmsbolt")
            (spacemacs/set-leader-keys "ars" 'rmsbolt-mode))
  :commands rmsbolt-mode
  :config
  (progn
    (spacemacs/set-leader-keys "arc" 'rmsbolt-compile))))
