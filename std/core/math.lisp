;; Cortado Math Utilities
;; Additional mathematical functions and utilities

(ns core.math)

;; Random number between 0 and 1 (placeholder - needs Rust implementation)
(defn rand []
  0.5) ; Return fixed value for now

;; Random integer between 0 and n-1 (placeholder - needs Rust implementation)  
(defn rand-int [n]
  0) ; Return 0 for now

;; Mathematical constants
(def PI 3.141592653589793)
(def E 2.718281828459045)

;; Power function - x^n for integer n
(defn pow [x n]
  (if (= n 0)
    1
    (if (= n 1)
      x
      (if (> n 0)
        (* x (pow x (- n 1)))
        (/ 1 (pow x (- n)))))))

;; Integer power of 2
(defn pow2 [n]
  (pow 2 n))

;; Factorial 
(defn factorial [n]
  (if (<= n 1)
    1
    (* n (factorial (- n 1)))))

;; Greatest common divisor
(defn gcd [a b]
  (if (= b 0)
    a
    (gcd b (% a b))))

;; Least common multiple
(defn lcm [a b]
  (/ (* a b) (gcd a b)))

;; Sum of collection
(defn sum [coll]
  (reduce + 0 coll))

;; Product of collection
(defn product [coll]
  (reduce * 1 coll))

;; Average of collection
(defn average [coll]
  (if (empty? coll)
    0
    (/ (sum coll) (count coll))))

;; Median of collection (simplified - assumes sorted)
(defn median [sorted-coll]
  (let [n (count sorted-coll)]
    (if (= n 0)
      0
      (if (odd? n)
        (nth sorted-coll (/ (- n 1) 2))
        (let [mid1 (nth sorted-coll (/ n 2))
              mid2 (nth sorted-coll (- (/ n 2) 1))]
          (/ (+ mid1 mid2) 2))))))

;; Check if number is integer
(defn integer? [n]
  (= n (floor n)))

;; Floor function (simplified)
(defn floor [n]
  ;; Simplified implementation - just truncate for positive numbers
  (if (>= n 0)
    (- n (% n 1))
    (- (- n (% n 1)) 1)))

;; Ceiling function (simplified)
(defn ceil [n]
  (if (= n (floor n))
    n
    (+ (floor n) 1)))

;; Round to nearest integer
(defn round [n]
  (let [f (floor n)]
    (if (>= (- n f) 0.5)
      (+ f 1)
      f)))

;; Sign function
(defn sign [n]
  (if (> n 0) 1
      (if (< n 0) -1
          0)))

;; Clamp value between min and max
(defn clamp [value min-val max-val]
  (if (< value min-val)
    min-val
    (if (> value max-val)
      max-val
      value)))

;; Linear interpolation
(defn lerp [start end t]
  (+ start (* t (- end start))))

;; Check if number is within range
(defn in-range? [value min-val max-val]
  (and (>= value min-val) (<= value max-val)))

;; Distance between two points (2D)
(defn distance [x1 y1 x2 y2]
  (let [dx (- x2 x1)
        dy (- y2 y1)]
    (sqrt (+ (* dx dx) (* dy dy)))))

;; Square root approximation using Newton's method
(defn sqrt [n]
  (if (<= n 0) 0
      (defn sqrt-iter [guess]
        (let [new-guess (/ (+ guess (/ n guess)) 2)]
          (if (< (abs (- new-guess guess)) 0.0001)
            new-guess
            (sqrt-iter new-guess))))
      (sqrt-iter 1.0)))

;; Check if number is prime (simple implementation)
(defn prime? [n]
  (if (< n 2)
    false
    (defn check-divisors [i]
      (if (> (* i i) n)
        true
        (if (= (% n i) 0)
          false
          (check-divisors (+ i 1)))))
    (check-divisors 2)))

;; Generate list of prime numbers up to n
(defn primes-up-to [n]
  (filter prime? (range 2 (+ n 1))))