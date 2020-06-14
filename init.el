;;; $DOOMDIR/init.el -*- lexical-binding: t; -*-
(doom! :input

       :completion
;       company           ; the ultimate code completion backend

       :ui
       ;(popup +defaults)   ; tame sudden yet inevitable temporary windows
       ;doom-dashboard    ; a nifty splash screen for Emacs
;       (treemacs +lsp)          ; a project drawer, like neotree but cooler

       :tools
;       (debugger +lsp)           ; stepping through code, to help you add bugs
;       (lsp +peek)
       ;tree-sitter

       :lang
;       (scheme +guile)        ; a fully conniving family of lisps
;       (python +lsp)
       ;(rust +lsp)            ; Fe2O3.unwrap().unwrap().unwrap().unwrap()

       :config
       (default +bindings ;+smartparens
                ))
