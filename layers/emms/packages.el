(defconst emms-packages '(emms))


(defun emms/init-emms()
  (use-package emms
    :commands (emms-play-file emms-librefm-stream)
    :config
    (progn
      (require 'emms-setup)
      (emms-all)
      (emms-default-players)
      (setq emms-player-list '(emms-player-vlc))
      ;;(require 'emms-librefm-stream)
      ;;(setq emms-librefm-scrobbler-username "foo"
      ;;      emms-librefm-scrobbler-password "bar")
      ;;(require 'emms-librefm-scrobbler)
      ;;(require 'emms-browser)
      ;;(setq emms-source-file-default-directory "~/Music/")
      ;;(setq emms-playlist-buffer-name "*Music*")
      (setq emms-info-asynchronously t)
      (require 'emms-info-libtag)
      (setq emms-info-functions '(emms-info-libtag))
      (require 'emms-mode-line)
      (emms-mode-line 1)
      (require 'emms-playing-time)
      (emms-playing-time 1)
      )))
