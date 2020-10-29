(TeX-add-style-hook
 "braidchains"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "12pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "margin=1in")))
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "href")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art12"
    "geometry"
    "amsmath"
    "amsthm"
    "amssymb"
    "graphicx"
    "hyperref"
    "cleveref"
    "enumitem")
   (LaTeX-add-labels
    "eq:1"
    "eq:2")
   (LaTeX-add-environments
    '("definition" LaTeX-env-args ["argument"] 1)
    '("corollary" LaTeX-env-args ["argument"] 1)
    '("question" LaTeX-env-args ["argument"] 1)
    '("conjecture" LaTeX-env-args ["argument"] 1)
    '("lemma" LaTeX-env-args ["argument"] 1)
    '("theorem" LaTeX-env-args ["argument"] 1))
   (LaTeX-add-enumitem-newlists
    '("steps" "enumerate")))
 :latex)

