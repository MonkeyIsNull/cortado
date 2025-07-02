;; Cortado Functional Programming Utilities
;; Simple implementations using basic Cortado features

(ns core.functional)

;; Function composition - (comp f g) creates a function that applies g then f
(defn comp [f g]
  (fn [x]
    (f (g x))))

;; Partial application for single argument
(defn partial1 [f arg1]
  (fn [x]
    (f arg1 x)))

;; Check if predicate is true for all elements
(defn every? [pred coll]
  (if (empty? coll)
    true
    (if (pred (first coll))
      (every? pred (rest coll))
      false)))

;; Find first truthy result of predicate applied to collection elements
(defn some [pred coll]
  (if (empty? coll)
    nil
    (letrec [[result (pred (first coll))]]
      (if result
        result
        (some pred (rest coll))))))

;; Conjoin - add element to collection (prepend for lists)
(defn conj [coll item]
  (cons item coll))

;; Return last element of collection
(defn last [coll]
  (if (empty? coll)
    nil
    (if (empty? (rest coll))
      (first coll)
      (last (rest coll)))))

;; Return all but last element
(defn butlast [coll]
  (if (or (empty? coll) (empty? (rest coll)))
    '()
    (cons (first coll) (butlast (rest coll)))))

;; Take elements while predicate is true
(defn take-while [pred coll]
  (if (or (empty? coll) (not (pred (first coll))))
    '()
    (cons (first coll) (take-while pred (rest coll)))))

;; Drop elements while predicate is true
(defn drop-while [pred coll]
  (if (empty? coll)
    '()
    (if (pred (first coll))
      (drop-while pred (rest coll))
      coll)))

;; Complement - create function that returns opposite boolean result
(defn complement [pred]
  (fn [x]
    (not (pred x))))

;; Identity function
(defn identity [x]
  x)