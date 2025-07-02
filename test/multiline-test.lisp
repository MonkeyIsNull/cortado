;; Test file for multiline function definitions
;; This should load cleanly with the new read_all_forms implementation

(defn add [a b]
  (+ a b))

(defn square [x]
  (* x x))

(defn factorial [n]
  (if (= n 0)
    1
    (* n (factorial (- n 1)))))

;; Complex nested function
(defn complex-calc [x y]
  (if (> (+ x y) 10)
    (square (* x y))
    (+ (+ x y) (* x y))))

;; Test all functions
(print "Testing multiline functions:")
(print "add(2, 3) =" (add 2 3))
(print "square(4) =" (square 4))
(print "factorial(5) =" (factorial 5))
(print "complex-calc(3, 4) =" (complex-calc 3 4))

;; Return success indicator
"multiline-test-complete"