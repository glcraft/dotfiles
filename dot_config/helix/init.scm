(require "forest/forest.scm")
(require "case.hx/case.scm")
(require (only-in "helix/keymaps.scm" add-global-keybinding))
(require (prefix-in helix.static. "helix/static.scm"))
(require "helix/configuration.scm")

;; Optional: which side the tree renders on ('left by default), and which
;; entry names are always hidden
(forest-configure! 'left #:ignore (list ".git" "target" "__pycache__"))

;; Optional: which explorer UI forest-open uses ('snacks by default)
;; (forest-set-style! style)
(forest-set-style! 'snacks) ; or 'mini

;; Optional (snacks): wrapping j/k inside a folder, and h/l to enter or leave
(forest-snack-circular-keybinds #t)

;; Optional (snacks): give the sidebar its own background per focus state, so the
;; tree stands apart from the buffer.
(forest-set-sidebar-bg! #:focused "#1e1e2e" #:unfocused "#181825")

;; Optional (snacks): color the search box outline. It marks focus by default
;; (orange focused, white unfocused); override the colors, or stop it changing.
(forest-set-search-color! #:focused "#89b4fa" #:unfocused "#585b70")
(forest-set-search-color! #:always "#89b4fa") ; one color, both states
(forest-set-search-color! #:focused "#89b4fa" #:follow-focus? #f) ; never changes

;; New LSP definitions
(define-lsp "steel-language-server" (command "steel-language-server") (args '()))

;; New language definition
(define-language "scheme"
                 (formatter (command "raco") (args '("fmt" "-i")))
                 (auto-format #true)
                 (language-servers '("steel-language-server")))

;; ` enters case mode. l, u and a are helix builtins, the rest come from case.scm.
(define case-mode
  (hash "l"
        "switch_to_lowercase"
        "u"
        "switch_to_uppercase"
        "a"
        "switch_case"
        "c"
        ":switch-to-camel-case"
        "p"
        ":switch-to-pascal-case"
        "s"
        ":switch-to-snake-case"
        "k"
        ":switch-to-kebab-case"
        "C"
        ":switch-to-constant-case"
        "t"
        ":switch-to-title-case"
        "S"
        ":switch-to-sentence-case"))

(define (forest-toggle)
  (if (forest-active?)
      (forest-close)
      (forest-open)))

(add-global-keybinding
 (hash "normal" (hash "e" ":forest-open" "-" case-mode) "select" (hash "-" case-mode)))
