;; PostScript BLUEBOOK pp. 82
(defun mencken ()
  (psise-draw '(/LM 72 def
                    /RM 216 def
                    /ypos 720 def
                    /lineheight 11 def
                    /crlf
                    { ypos lineheight sub
                    /ypos exch def
                    LM ypos moveto } def
                    /prtstr 
                    { dup stringwidth pop
                    currentpoint pop add RM gt
                    { crlf } if
                    show } def
                    /format
                    { { prtstr " " show } forall
                    } def
                    /Times-Italic findfont 10 scalefont setfont
                    LM ypos moveto
                    [ "Concience" "is" "the" "inner" "voice"
                      "that" "warns" "us" "somebody" "may" "be"
                      "looking" " - Mencken" ]
                    format
                    showpage)))
