;; psise - PostScript In S-Expression
;; Create image by PostScript in S-Expression(psise) and insert it to current buffer.
;; author: @quasicrane 

(require 'cl)

(defun psise-emit-header ()
  (princ "%!PS-Adobe-3.0\n" (current-buffer)))

(defun psise-escape-paren (str)
  (let ((str2 (replace-regexp-in-string "\)" "\\\\)" str)))
    (replace-regexp-in-string "\(" "\\\\(" str2)))

(defun psise-parse-exp (exp)
  (cond
    ((stringp exp)
     (format "(%s)" (psise-escape-paren exp)))
    ((atom exp)
     (prin1-to-string exp))
    (t
     (error "Unkown form: %s" exp))))

(defun psise-emit (token)
  "Emit token."
  (princ token (current-buffer))
  (princ " \n" (current-buffer)))

(defun psise-write-psise (psise)
  "Write PSISE to temp-file and return temp-file name."
  (let* ((ps (make-temp-file "psise" nil ".ps"))
         (buf (create-file-buffer ps)))
    (save-current-buffer
      (set-buffer buf)
      (loop for e in psise
         initially
           (psise-emit-header)
         do
           (psise-emit (psise-parse-exp e)))
      (write-file ps)
      ps)))

(defvar psise-output-buffer "*psise-temp-buffer*")
(defvar psise-ps2epsi-program "/opt/local/bin/ps2epsi")
(defvar psise-convert-program "/opt/local/bin/convert")

(defun psise-ps-to-png (ps)
  "Convert PostScript file to PNG."
  (let ((eps (make-temp-file "psise" nil ".eps"))
        (png (make-temp-file "psise" nil ".png"))
        (buf (get-buffer-create psise-output-buffer)))
    (let ((status (call-process psise-ps2epsi-program nil buf nil ps eps)))
      ;; Note: To trim the figure, use ps2epsi command.
      (message "psise ps2epsi:%s" status)
      (unless (= 0 status)
        (pop-to-buffer buf)
        (error "psise gs error"))
      (let ((status2 (call-process psise-convert-program nil nil nil eps png)))
        (message "psise convert:%s" status2)
        (unless (= 0 status2)
          (pop-to-buffer buf)
          (error "psise convert error"))
        (message "psise png: %s" png)
        png))))

(defun psise-draw (psise)
  "Create image by PostScript in S-Expression(psise) and insert it to current buffer."
  (let ((ps (psise-write-psise psise)))
    (let ((png (psise-ps-to-png ps)))
      (insert-image (find-image (list (list :file png :type 'png))) "psise"))))

(defun pythagoras (r0 theta) ;; 
  "Example. (pythagoras 30 60)"
  (let ((defbox
         '(/box {
           /w exch def
           0 w rlineto
           w 0 rlineto
           0 0 w sub rlineto
           closepath } def)))
    (psise-draw
     `(,@defbox
          /dashline { [ 6 3 ] 3 setdash } def
          /orgline { [] 0 setdash } def
          
          /r0 ,r0 def
          /r2 2 r0 mul def
          /theta ,theta def
          /x0 r0 def ;; (x0, y0) center of circle = (r0, 2 r0)
          /y0 r0 2 mul def
          /x1 r0 theta cos mul x0 add def ;; r0 cos theta + x0
          /y1 r0 theta sin mul y0 add def
          /l1 x1 2 exp y1 r2 sub 2 exp add sqrt def ;; sqrt (x1^2 + (y1 - 2r0)^2)
          /l2 r2 x1 sub 2 exp y1 r2 sub 2 exp add sqrt def ;; sqrt ((2r0-x1)^2 + (y1 - 2r0)^2)

          100 100 translate 
          
          newpath
          orgline
          0 0 moveto
          r0 2 mul box
          stroke
          ;; draw triangle
          newpath
          orgline
          0 r0 2 mul moveto
          x1 y1 lineto
          r0 2 mul r0 2 mul lineto
          stroke

          ;; draw box
          gsave
          newpath
          orgline
          0 r0 2 mul translate
          0 0 moveto
          theta 2 div rotate
          l1 box
          0.7 setgray
          fill
          grestore

          gsave
          newpath
          orgline
          x1 y1 translate
          0 0 moveto
          90 theta 2 div sub neg rotate
          l2 box
          0.4 setgray
          fill
          grestore

          gsave
          newpath
          dashline
          x1 y1 moveto
          x1 0 lineto
          stroke
          grestore

          showpage))))
