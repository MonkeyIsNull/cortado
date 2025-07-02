;; Debug test
(print "Step 1: Defining function")
(defn test-fn [x] (+ x 1))
(print "Step 2: Testing non-recursive function")
(print (test-fn 5))
(print "Step 3: Defining recursive function")  
(defn countdown [n] (if (= n 0) 0 (countdown (- n 1))))
(print "Step 4: Testing recursive function")
(print (countdown 3))