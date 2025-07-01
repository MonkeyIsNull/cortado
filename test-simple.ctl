;; Simple test without stdlib dependencies
(print "Simple test starting...")

;; Basic arithmetic
(print "Testing arithmetic...")
(print (+ 1 2))
(print (- 5 3))

;; Basic functions  
(defn add-one [x] (+ x 1))
(print (add-one 5))

(print "Simple test completed!")