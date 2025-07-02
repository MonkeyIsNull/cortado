;; Step 4: Add reverse and test circular dependency
(ns core.sequences-step4)

;; mapv - eager map that returns a list
(defn mapv [f coll]
  (if (or (nil? coll) (= coll '()))
    '()
    (cons (f (first coll)) (mapv f (rest coll)))))

;; Helper for reverse
(defn reverse-helper [remaining result]
  (if (or (nil? remaining) (= remaining '()))
    result
    (reverse-helper (rest remaining) (cons (first remaining) result))))

;; reverse implementation
(defn reverse [coll]
  (reverse-helper coll '()))

;; contains-item? helper
(defn contains-item? [lst item]
  (if (or (nil? lst) (= lst '()))
    false
    (if (= (first lst) item)
      true
      (contains-item? (rest lst) item))))

;; distinct helper - USING REVERSE HERE
(defn distinct-helper [seen remaining result]
  (if (or (nil? remaining) (= remaining '()))
    (reverse result)  ;; This calls reverse!
    (if (contains-item? seen (first remaining))
      (distinct-helper seen (rest remaining) result)
      (distinct-helper 
        (cons (first remaining) seen) 
        (rest remaining) 
        (cons (first remaining) result)))))

;; distinct - remove duplicate elements
(defn distinct [coll]
  (distinct-helper '() coll '()))