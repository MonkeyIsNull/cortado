;; Cortado Standard Library - Utilities Module
;; General utility functions

;; Partial application - create a function with some args pre-filled
(defn partial [f x]
  (fn [y] (f x y)))

(defn partial2 [f x y]
  (fn [z] (f x y z)))

;; Function composition
(defn comp [f g]
  (fn [x] (f (g x))))

;; Pipe value through functions
(defn pipe [x f]
  (f x))

;; Memoization - simple version without state
;; TODO: Implement proper memoization when mutable state is available

;; Generate unique symbols (simplified version using counter)
(def gensym-counter 0)
(defn gensym []
  (def gensym-counter (+ gensym-counter 1))
  (str "G__" gensym-counter))

;; Repeat value n times
(defn repeat [n x]
  (if (= n 0)
    nil
    (cons x (repeat (- n 1) x))))

;; Apply function n times
(defn iterate [f n x]
  (if (= n 0)
    x
    (iterate f (- n 1) (f x))))
