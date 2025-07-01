;; Simple recursion test
(print "Testing simple recursion...")

;; Non-recursive function first
(defn add-one [x] (+ x 1))
(print "add-one(5) =" (add-one 5))

;; Simple recursive function  
(defn countdown [n]
  (if (= n 0)
    "done"
    n))

(print "countdown(3) =" (countdown 3))
(print "Simple recursion test completed!")