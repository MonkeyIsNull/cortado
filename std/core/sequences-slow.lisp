;; Minimal sequences for testing
(ns core.sequences)

;; Test a simple function first
(defn test-fn [x] (+ x 1))

;; Helper for mapv - builds list first
(defn mapv-helper [f coll]
  (if (or (nil? coll) (= coll '()))
    '()
    (cons (f (first coll)) (mapv-helper f (rest coll)))))

;; mapv - eager map that returns a list
(defn mapv [f coll]
  (mapv-helper f coll))

;; Helper to get length of collection
(defn length-helper [coll count]
  (if (or (nil? coll) (= coll '()))
    count
    (length-helper (rest coll) (+ count 1))))

;; Helper for partition - take n elements from collection
(defn take-n [n coll]
  (if (or (<= n 0) (nil? coll) (= coll '()))
    '()
    (cons (first coll) (take-n (- n 1) (rest coll)))))

;; Helper for partition - drop n elements from collection
(defn drop-n [n coll]
  (if (or (<= n 0) (nil? coll) (= coll '()))
    coll
    (drop-n (- n 1) (rest coll))))

;; Helper for reverse recursion
(defn reverse-helper [remaining result]
  (if (or (nil? remaining) (= remaining '()))
    result
    (reverse-helper (rest remaining) (cons (first remaining) result))))

;; reverse - helper function
(defn reverse [coll]
  (reverse-helper coll '()))

;; Helper for partition recursion
(defn partition-helper [n coll result]
  (if (or (nil? coll) (= coll '()))
    (reverse result)
    (if (< (length-helper coll 0) n)
      ;; Not enough elements for a full partition
      (reverse result)
      ;; Take n elements and continue
      (partition-helper n 
                       (drop-n n coll) 
                       (cons (take-n n coll) result)))))

;; partition - split collection into chunks of size n
(defn partition [n coll]
  (if (<= n 0)
    '()
    (partition-helper n coll '())))

;; Helper function to check if item is in list
(defn contains-item? [lst item]
  (if (or (nil? lst) (= lst '()))
    false
    (if (= (first lst) item)
      true
      (contains-item? (rest lst) item))))

;; Helper for distinct recursion
(defn distinct-helper [seen remaining result]
  (if (or (nil? remaining) (= remaining '()))
    (reverse result)
    ;; Get first item and check if we've seen it
    (if (contains-item? seen (first remaining))
      ;; Already seen, skip it
      (distinct-helper seen (rest remaining) result)
      ;; Not seen, add it
      (distinct-helper 
        (cons (first remaining) seen) 
        (rest remaining) 
        (cons (first remaining) result)))))

;; distinct - remove duplicate elements, preserving order
(defn distinct [coll]
  (distinct-helper '() coll '()))