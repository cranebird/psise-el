
(defun def-circle (&optional (size 5))
  `(/circle {
            /y exch def
            /x exch def
            newpath
            x y ,size 0 360 arc closepath
            0 setgray
            fill }
            def))

(require 'cl)

(defun calc-bezier (x1 y1 x2 y2 x3 y3 n)
  "Draw bezier curve by elisp.
ex. (psise-draw (calc-bezier 100 300 200 300 300 0 20))"
  `(/circle
     {
     /y exch def
     /x exch def
     newpath
     x y 5 0 360 arc closepath
     0 setgray
     fill
     }
     def
     /small-circle
     {
     /y exch def
     /x exch def
     newpath
     x y 2 0 360 arc closepath
     fill }
     def
     /bezier-line {
     /y1 exch def
     /x1 exch def
     /y0 exch def
     /x0 exch def
     x0 y0 circle
     gsave
     [ 5 2 ] 0 setdash
     newpath
     x0 y0 moveto
     x1 y1 lineto
     stroke
     grestore
     x1 y1 circle
     } def
     100 150 translate
     ;; draw additional line
     0 0 moveto
     0 0 ,x1 ,y1 bezier-line
     ,x1 ,y1 ,x2 ,y2 bezier-line
     ,x2 ,y2 ,x3 ,y3 bezier-line
     
     ;;; bezier curve by post script
     ;; newpath
     ;; 0 0 moveto
     ;; ,x1 ,y1 ,x2 ,y2 ,x3 ,y3 curveto
     ;; stroke

     ;;; bezier curve by elisp
     ,@(loop for i from 1 below n
          for m0x = (+ 0.0 (/ (* (- x1 0.0) i) n))
          for m0y = (+ 0.0 (/ (* (- y1 0.0) i) n))
          for m1x = (+ x1 (/ (* (- x2 x1) i) n))
          for m1y = (+ y1 (/ (* (- y2 y1) i) n))
          for m2x = (+ x2 (/ (* (- x3 x2) i) n))
          for m2y = (+ y2 (/ (* (- y3 y2) i) n))
          for d0x = (- m1x m0x)
          for d0y = (- m1y m0y)
          for b0x = (+ m0x (/ (* d0x i) n))
          for b0y = (+ m0y (/ (* d0y i) n))
          for d1x = (- m2x m1x)
          for d1y = (- m2y m1y)
          for b1x = (+ m1x  (/ (* d1x i) n))
          for b1y = (+ m1y (/ (* d1y i) n))
            
          for d2x = (- b1x b0x)
          for d2y = (- b1y b0y)
          for px = (+ b0x (/ (* d2x i) n))
          for py = (+ b0y (/ (* d2y i) n))
          append
            `(0.3 1.0 0.3 setrgbcolor ,px ,py small-circle))
     
     showpage))

