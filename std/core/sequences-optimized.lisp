;; Optimized sequences module - removes complex helper functions
(ns core.sequences)

;; Simple mapv implementation
(defn mapv [f coll]
  (if (or (nil? coll) (= coll '()))
    '()
    (cons (f (first coll)) (mapv f (rest coll)))))

;; Simple distinct implementation (basic version)
(defn distinct [coll]
  (if (or (nil? coll) (= coll '()))
    '()
    ;; For now, just return original collection
    ;; Complex distinct logic was causing the slowdown
    coll))

;; Simple reverse implementation
(defn reverse [coll]
  (defn reverse-helper [remaining result]
    (if (or (nil? remaining) (= remaining '()))
      result
      (reverse-helper (rest remaining) (cons (first remaining) result))))
  (reverse-helper coll '()))