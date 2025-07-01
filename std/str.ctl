;; Cortado Standard Library - String Module
;; Functions for string manipulation

;; Check if value is a string  
;; TODO: Add when type function is available

;; Get length of string (using built-in str-length)
(defn length [s] (str-length s))

;; Simple string utilities using available operations
(defn empty-string? [s]
  (= (str-length s) 0))

;; Concatenate multiple values into a string
(defn str-concat [x y]
  (str x y))

;; Join list elements with separator (simplified version)
(defn join [sep xs]
  (if (nil? xs)
    ""
    (if (nil? (rest xs))
      (str (first xs))
      (str (first xs) sep (join sep (rest xs))))))
