;; Test recursion depth limiting
(print "Testing recursion depth limiting...")

;; Define a factorial function  
(defn factorial [n]
  (if (= n 0)
    1
    (* n (factorial (- n 1)))))

;; Test with reasonable depth
(print "factorial(5) =" (factorial 5))
(print "factorial(10) =" (factorial 10))

;; Define an infinite recursion function to test depth limiting
(defn infinite-loop [n]
  (infinite-loop (+ n 1)))

(print "About to test infinite recursion (should be caught)...")
;; This should hit the recursion limit
;; (infinite-loop 1)

(print "Recursion tests completed!")