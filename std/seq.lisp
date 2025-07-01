;; Cortado Standard Library - Sequence Operations
;; Functions for working with lists and vectors

;; Map function - apply f to each element
(defn map [f xs]
  (if (nil? xs)
    nil
    (if (nil? (rest xs))
      (cons (f (first xs)) nil)
      (cons (f (first xs)) (map f (rest xs))))))

;; Filter function - keep elements where pred is true
(defn filter [pred xs]
  (if (nil? xs)
    nil
    (if (pred (first xs))
      (cons (first xs) (filter pred (rest xs)))
      (filter pred (rest xs)))))

;; Reduce function - fold left
(defn reduce [f init xs]
  (if (nil? xs)
    init
    (reduce f (f init (first xs)) (rest xs))))

;; Take first n elements
(defn take [n xs]
  (if (= n 0)
    nil
    (if (nil? xs)
      nil
      (cons (first xs) (take (- n 1) (rest xs))))))

;; Drop first n elements
(defn drop [n xs]
  (if (= n 0)
    xs
    (if (nil? xs)
      nil
      (drop (- n 1) (rest xs)))))

;; Generate range of numbers
(defn range [start end]
  (if (>= start end)
    nil
    (cons start (range (+ start 1) end))))

;; Get nth element (0-indexed)
(defn nth [xs n]
  (if (= n 0)
    (first xs)
    (nth (rest xs) (- n 1))))

;; Count elements in sequence
(defn count [xs]
  (if (nil? xs)
    0
    (+ 1 (count (rest xs))))

;; Check if sequence is empty
(defn empty? [xs]
  (nil? xs))

;; Reverse a sequence
(defn reverse [xs]
  (reduce (fn [acc x] (cons x acc)) nil xs))
