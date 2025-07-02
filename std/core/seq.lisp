;; Core sequence operations namespace
(ns core.seq)

(defn map-list [f lst]
  (if (nil? lst)
    nil
    (cons (f (first lst)) (map-list f (rest lst)))))

(defn filter-list [pred lst]
  (if (nil? lst)
    nil
    (if (pred (first lst))
      (cons (first lst) (filter-list pred (rest lst)))
      (filter-list pred (rest lst)))))

(defn reduce-list [f init lst]
  (if (nil? lst)
    init
    (reduce-list f (f init (first lst)) (rest lst))))

(defn length [lst]
  (if (nil? lst)
    0
    (+ 1 (length (rest lst)))))

(defn reverse-list [lst]
  (reduce-list (fn [acc x] (cons x acc)) nil lst))

;; Additional sequence utilities

;; Get nth element (0-indexed) 
(defn nth [coll n]
  (if (or (< n 0) (empty? coll))
    nil
    (if (= n 0)
      (first coll)
      (nth (rest coll) (- n 1)))))

;; Create a range of numbers
(defn range [start end]
  (if (>= start end)
    '()
    (cons start (range (+ start 1) end))))

;; Range with just end (starts from 0)
(defn range-from-zero [end]
  (range 0 end))

;; Interleave two collections
(defn interleave [coll1 coll2]
  (if (or (empty? coll1) (empty? coll2))
    '()
    (cons (first coll1) 
          (cons (first coll2) 
                (interleave (rest coll1) (rest coll2))))))

;; Remove elements matching predicate
(defn remove [pred coll]
  (filter-list (fn [x] (not (pred x))) coll))

;; Repeat element n times
(defn repeat [n item]
  (if (<= n 0)
    '()
    (cons item (repeat (- n 1) item))))

;; Take first n elements
(defn take [n coll]
  (if (or (<= n 0) (empty? coll))
    '()
    (cons (first coll) (take (- n 1) (rest coll)))))

;; Drop first n elements  
(defn drop [n coll]
  (if (or (<= n 0) (empty? coll))
    coll
    (drop (- n 1) (rest coll))))

;; Count elements in collection
(defn count [coll]
  (length coll))