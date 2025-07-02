;; Fast minimal sequences module for testing
(ns core.sequences-fast)

;; mapv - eager map that returns a list
(defn mapv [f coll]
  (if (or (nil? coll) (= coll '()))
    '()
    (cons (f (first coll)) (mapv f (rest coll)))))

;; distinct - remove duplicate elements
(defn distinct [coll]
  (if (or (nil? coll) (= coll '()))
    '()
    (cons (first coll) (distinct (rest coll)))))

;; reverse - reverse a list
(defn reverse [coll]
  (if (or (nil? coll) (= coll '()))
    '()
    (cons (first (reverse (rest coll))) (reverse (rest coll)))))