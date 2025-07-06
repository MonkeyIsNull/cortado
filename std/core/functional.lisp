;; Minimal functional utilities
(ns core.functional)

;; Identity function
(defn identity [x]
  x)

;; Constantly - return a function that always returns the same value
(defn constantly [value]
  (fn [x] value))

;; Function composition
(defn comp [f g]
  (fn [x]
    (f (g x))))

;; Function composition for 3 functions
(defn comp3 [f g h]
  (fn [x]
    (f (g (h x)))))

;; Complement - create function that returns opposite boolean result
(defn complement [pred]
  (fn [x]
    (not (pred x))))

;; Check if predicate is true for all elements
(defn every? [pred coll]
  (if (or (nil? coll) (= coll '()))
    true
    (if (pred (first coll))
      (every? pred (rest coll))
      false)))

;; Find first truthy result of predicate applied to collection elements
(defn some [pred coll]
  (if (or (nil? coll) (= coll '()))
    nil
    (if (pred (first coll))
      (pred (first coll))
      (some pred (rest coll)))))

;; Return last element of collection
(defn last [coll]
  (if (or (nil? coll) (= coll '()))
    nil
    (if (or (nil? (rest coll)) (= (rest coll) '()))
      (first coll)
      (last (rest coll)))))

;; Partial application for single argument
(defn partial1 [f arg1]
  (fn [x]
    (f arg1 x)))