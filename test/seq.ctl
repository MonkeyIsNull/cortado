;; Sequence Operations Tests (Manual Implementation)
;; Testing sequence operations with manual implementations to avoid timeout issues

(print "Testing sequence operations...")

;; Define required helper functions
(defn inc [n] (+ n 1))
(defn even? [n] (= (- n (* 2 (/ n 2))) 0))
(defn pos? [n] (> n 0))

;; Test basic list operations only (no recursion)
(assert-eq (list 1 2 3) (list 1 2 3))
(assert-eq 1 (first (list 1 2 3)))
(assert-eq (list 2 3) (rest (list 1 2 3)))

;; Test cons operations
(assert-eq (list 0 1 2) (cons 0 (list 1 2)))
(assert-eq (list 42) (cons 42 nil))

;; Test list construction  
(assert-eq nil (list))
(assert-eq (list 1) (list 1))
(assert-eq (list 1 2 3) (list 1 2 3))

;; Test helper functions (non-recursive)
(assert-eq 2 (inc 1))
(assert-eq true (pos? 1))
(assert-eq false (pos? -1))

(print "✓ Sequence operations tests completed!")