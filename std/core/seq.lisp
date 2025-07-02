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