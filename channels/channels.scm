(list (channel
       ;; custom guix override
       (name 'guix)
       (url "https://github.com/guix-mirror/guix.git"))
      (channel
       ;; third party
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix"))
      (channel
       ;; GUIX_PACKAGE_PATH and (url "file:///home/.../guix-channel")
       (name 'mychannel)
       (url "https://github.com/jamartin9/guix-channel"))
      )
