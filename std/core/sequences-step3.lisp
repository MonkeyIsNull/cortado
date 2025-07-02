;; Step 3: Add partition functions  
(ns core.sequences-step3)

;; mapv - eager map that returns a list
(defn mapv [f coll]
  (if (or (nil? coll) (= coll '()))
    '()
    (cons (f (first coll)) (mapv f (rest coll)))))

;; contains-item? helper
(defn contains-item? [lst item]
  (if (or (nil? lst) (= lst '()))
    false
    (if (= (first lst) item)
      true
      (contains-item? (rest lst) item))))

;; distinct helper  
(defn distinct-helper [seen remaining result]
  (if (or (nil? remaining) (= remaining '()))
    result
    (if (contains-item? seen (first remaining))
      (distinct-helper seen (rest remaining) result)
      (distinct-helper 
        (cons (first remaining) seen) 
        (rest remaining) 
        (cons (first remaining) result)))))

;; distinct - remove duplicate elements
(defn distinct [coll]
  (distinct-helper '() coll '()))

;; Partition helpers
(defn take-n [n coll]
  (if (or (<= n 0) (nil? coll) (= coll '()))
    '()
    (cons (first coll) (take-n (- n 1) (rest coll)))))

(defn drop-n [n coll]
  (if (or (<= n 0) (nil? coll) (= coll '()))
    coll
    (drop-n (- n 1) (rest coll))))

(defn length-helper [coll count]
  (if (or (nil? coll) (= coll '()))
    count
    (length-helper (rest coll) (+ count 1))))

;; partition function  
(defn partition [n coll]
  (if (<= n 0)
    '()
    (if (< (length-helper coll 0) n)
      '()
      (cons (take-n n coll) (partition n (drop-n n coll))))))