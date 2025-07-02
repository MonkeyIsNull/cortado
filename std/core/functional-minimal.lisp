;; Minimal functional utilities
(ns core.functional-minimal)

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
    (let [result (pred (first coll))]
      (if result
        result
        (some pred (rest coll))))))

;; Return last element of collection
(defn last [coll]
  (if (or (nil? coll) (= coll '()))
    nil
    (if (or (nil? (rest coll)) (= (rest coll) '()))
      (first coll)
      (last (rest coll)))))