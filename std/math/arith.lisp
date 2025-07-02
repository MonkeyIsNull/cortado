;; Math arithmetic namespace
(ns math.arith)

(defn double [x] 
  (* x 2))

(defn triple [x] 
  (* x 3))

(defn square [x]
  (* x x))

(defn add-squares [x y]
  (+ (square x) (square y)))

(defn power-of-two? [n]
  (and (pos? n) (zero? (% n 2))))

;; Factorial function
(defn factorial [n]
  (if (= n 0)
    1
    (* n (factorial (- n 1)))))