(add-to-list 'load-path "~/.emacs.d/elpa")
; Slimmed down config
; TODO: Dired, I-do, helm, flyckeck, org, misc...    
(cua-mode t)				
(global-set-key (kbd "C-c C-c") 'cua-rectangle-mark-mode)
(global-ede-mode t)
;; Set up package manager -- needs emacs 24
(require 'package)
(dolist (source '(("marmalade" . "http://marmalade-repo.org/packages/")
                  ("elpa" . "http://tromey.com/elpa/")
                  ("melpa" . "http://melpa.milkbox.net/packages/")
                  ))
  (add-to-list 'package-archives source t))

(package-initialize)

(when (not package-archive-contents)
 (package-refresh-contents))
(defvar elisp/packages
 '(yasnippet auto-complete iedit expand-region tramp-term))
(dolist (p elisp/packages)
 (when (not (package-installed-p p))
   (package-install p)))

; let me choose
(require 'expand-region)
(global-set-key (kbd "C-f") 'er/expand-region)

; refactor
(require 'iedit)
(define-key global-map (kbd "C-c ;") 'iedit-mode)

; some snippets
(require 'yasnippet)
(yas-global-mode 1)

; complete me
(require 'auto-complete-config)		
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)
; remind me
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")

(semantic-mode 1)
(defun my:add-semantic-to-autocomplete()
  (add-to-list 'ac-sources 'ac-source-semantic)
  )

;; unannoy
(setq inhibit-startup-message t)
(global-visual-line-mode t)
(delete-selection-mode t)
(blink-cursor-mode t)
(show-paren-mode t)
(setq make-backup-file nil)
(setq auto-save-default nil)
(fset 'yes-or-no-p 'y-or-n-p)

;; Compile configuration
;(byte-recompile-directory "~/.emacs.d/lisp/" 0)
(byte-recompile-directory "~/.emacs.d/elpa/" 0)
(byte-recompile-file "~/.emacs.d/init.el" nil 0)


;(add-to-list 'tramp-default-proxies-alist
;                 '("HOSTB" nil "/ssh:USERA@HOSTA:"))
