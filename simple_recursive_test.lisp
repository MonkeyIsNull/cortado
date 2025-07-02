;; Simple performance test
(defn count-down [n] 
  (if (= n 0) 
    0 
    (count-down (- n 1))))

(print "Testing count-down 3")
(print (count-down 3))
(print "Testing count-down 10")  
(print (count-down 10))