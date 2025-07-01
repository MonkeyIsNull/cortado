;; Math utilities module
(defn square [x] (* x x))
(defn cube [x] (* x x x))
(defn factorial [n] (if (= n 0) 1 (* n 1))) ; Simple non-recursive version
(def pi 3.14159)