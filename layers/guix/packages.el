(defconst guix-packages '(guix))

(defun guix/init-guix ()
  (use-package guix
    :commands guix-popup
    :init (with-eval-after-load 'guix-ui-profile
            (setq guix-profiles (append '((expand-file-name (concat (file-name-as-directory "manifests")
                                                               "user.scm")))
                                        (guix-all-profiles))))
    :config
    (progn
      ;; top
      (spacemacs/declare-prefix "aG" "Guix")
      (spacemacs/set-leader-keys "aGg" 'guix)
      ;; packages
      (spacemacs/declare-prefix "aGp" "packages")
      (spacemacs/set-leader-keys "aGpa" 'guix-all-packages)
      (spacemacs/set-leader-keys "aGpu" 'guix-installed-user-packages)
      (spacemacs/set-leader-keys "aGpt" 'guix-installed-system-packages)
      (spacemacs/set-leader-keys "aGpn" 'guix-packages-by-name)
      (spacemacs/set-leader-keys "aGpi" 'guix-packages-by-license)
      (spacemacs/set-leader-keys "aGpl" 'guix-packages-by-location)
      (spacemacs/set-leader-keys "aGpf" 'guix-package-from-file)
      (spacemacs/set-leader-keys "aGps" 'guix-search-by-name)
      (spacemacs/set-leader-keys "aGpr" 'guix-search-by-regexp)
      ;; profiles
      (spacemacs/declare-prefix "aGP" "Profiles")
      (spacemacs/set-leader-keys "aGPp" 'guix-profiles)
      (spacemacs/set-leader-keys "aGPg" 'guix-generations)
      (spacemacs/set-leader-keys "aGPs" 'guix-system-generations)
      ;; services
      (spacemacs/declare-prefix "aGs" "services")
      (spacemacs/set-leader-keys "aGsa" 'guix-all-services)
      (spacemacs/set-leader-keys "aGsn" 'guix-services-by-name)
      (spacemacs/set-leader-keys "aGsr" 'guix-services-by-regexp)
      (spacemacs/set-leader-keys "aGsl" 'guix-services-by-location)
      ;; licenses
      (spacemacs/declare-prefix "aGl" "licenses")
      (spacemacs/set-leader-keys "aGll" 'guix-licenses)
      (spacemacs/set-leader-keys "aGlb" 'guix-browse-license-url)
      (spacemacs/set-leader-keys "aGlf" 'guix-find-license-definition)
      ;; store
      (spacemacs/declare-prefix "aGS" "Store")
      (spacemacs/set-leader-keys "aGSl" 'guix-store-live-items)
      (spacemacs/set-leader-keys "aGSd" 'guix-store-dead-items)
      (spacemacs/set-leader-keys "aGSf" 'guix-store-failures)
      (spacemacs/set-leader-keys "aGSr" 'guix-store-item-referrers)
      (spacemacs/set-leader-keys "aGSc" 'guix-store-item-references)
      (spacemacs/set-leader-keys "aGSq" 'guix-store-item-requisites)
      (spacemacs/set-leader-keys "aGSi" 'guix-store-item-derivers)
      ;; misc
      (spacemacs/declare-prefix "aGm" "misc")
      (spacemacs/set-leader-keys "aGmh" 'guix-help)
      (spacemacs/set-leader-keys "aGma" 'guix-about)
      (spacemacs/set-leader-keys "aGmp" 'guix-pull)
      (spacemacs/set-leader-keys "aGmP" 'guix-prettify-mode)
      (spacemacs/set-leader-keys "aGmb" 'guix-build-log-mode)
      (spacemacs/set-leader-keys "aGmd" 'guix-devel-mode))))
