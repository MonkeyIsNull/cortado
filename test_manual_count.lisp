;; Test manual count function
(print "Defining manual-count...")
(defn manual-count [xs] (if (nil? xs) 0 (+ 1 (manual-count (rest xs)))))
(print "Testing manual-count...")
(print (manual-count nil))
(print (manual-count (list 1 2 3)))