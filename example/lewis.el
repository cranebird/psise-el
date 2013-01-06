;; PostScript BLUEBOOK pp. 95
(defun lewis ()
  (psise-draw '(/basefont /Times-Roman findfont def
                          /LM 72 def
                          /newline
                          { currentpoint 13 sub 
                          exch pop LM exch moveto } def
                          9.3 
                          LM 600 moveto
                          basefont [12 0 0 12 0 0] makefont setfont
                          "\"Talking of axes,\"" show newline
                          basefont [17 0 0 12 0 0] makefont setfont
                          "said the Duchess," show newline
                          basefont [7 0 0 12 0 0] makefont setfont
                          "\"Off with her head!\"" show newline
                          basefont [12 0 6.93 12 0 0] makefont setfont
                          " - Lewis Carroll"
                          show
                          showpage)))
