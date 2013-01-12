(require 'cl)

;; Draw Celluar automaton with psise.

(defun ca-rulegen (n)
  "Return binary list for Rule n."
  (ca-dec-to-bin n nil))

(defun ca-dec-to-bin (n res)
  "Return binary list."
  (let ((m (/ n 2)))
    (cond
      ((= m 0)
       (let ((x (cons (% n 2) res)))
         (append (make-list (- 8 (length x)) 0) x)))
      (t
       (ca-dec-to-bin m (cons (% n 2) res))))))

(defun ca-simple-init (n)
  "Return list which size is size + 1"
  (append (make-list (/ n 2) 0) '(1) (make-list (/ n 2) 0)))

(defun ca-next-state (world rule)
  "Return new world."
  (loop for (l c r) on (cons nil world) ;; for boundary condition
     if c
     collect (nth (+ (* 4 (or l 0)) (* 2 (or c 0)) (or r 0)) (reverse rule))))

(defun ca (init n step)
  "Collect list of CA."
  (let* ((world init)
         (result (list world))
         (rule (ca-rulegen n))
         (i 0))
    (while (< i step)
      (setq world (ca-next-state world rule))
      (setq result (cons world result))
      (incf i))
    (reverse result)))

(defun ca-draw (worlds)
  "Draw cell-automaton."
  (let* ((d 10) ;; size of cell
         (psise
             `(/cell
               {
               /n exch def
               0 0 moveto
               ,d 0 rlineto
               0 ,d rlineto
               ,d neg 0 rlineto
               closepath
               n setgray
               fill
               } def
               /livecell
               {
               0
               cell
               } def
               /deadcell
               {
               1
               cell
               } def
               200 200 translate
               ,@(loop for world in (reverse worlds)
                    append
                      (append `(0 ,d translate gsave)
                              (loop for i in world
                                 append (if (= i 0)
                                            `(deadcell ,d 0 translate)
                                            `(livecell ,d 0 translate)))
                              '(grestore)))
               showpage)))
    (psise-draw psise)))



  

