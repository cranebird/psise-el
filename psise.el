;; psise - PostScript In S-Expression
;; Create image by PostScript in S-Expression(psise) and insert it to current buffer.
;; author: @quasicrane 

(require 'cl)

(defvar psise-ps2epsi-program "/opt/local/bin/ps2epsi")
(defvar psise-convert-program "/opt/local/bin/convert")

(defvar psise-output-buffer "*psise-temp-buffer*")

(defun psise-emit-header ()
  (princ "%!PS-Adobe-3.0\n" (current-buffer)))

(defun psise-escape-paren (str)
  (let ((str2 (replace-regexp-in-string "\)" "\\\\)" str)))
    (replace-regexp-in-string "\(" "\\\\(" str2)))

(defun psise-escape-parcent (str)
  (replace-regexp-in-string "%" "\\\\%" str))

(defun psise-escape (str)
  (psise-escape-parcent (psise-escape-paren str)))

(defun psise-parse-exp (exp)
  (cond
    ((stringp exp)
     (format "(%s)" (psise-escape exp)))
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


