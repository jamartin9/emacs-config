(register-services

 (make <service>
   #:provides '(emacs)
   #:start (make-system-constructor
            "emacs --daemon")
   #:stop (make-system-destructor
           "emacsclient --eval '(kill-emacs)'"))
)
(action 'shepherd 'daemonize)
(for-each start '(emacs))
