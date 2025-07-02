;; Cortado String Utilities
;; Implementation of string manipulation functions

(ns core.string)

;; Substring extraction - (subs "hello" 1 3) -> "el" 
(defn subs [s start end]
  (if (or (< start 0) (>= start (str-length s)) (< end start))
    ""
    (let [actual-end (if (> end (str-length s)) (str-length s) end)]
      (defn subs-helper [remaining current-pos result]
        (if (or (empty? remaining) (>= current-pos actual-end))
          result
          (if (>= current-pos start)
            (subs-helper (rest remaining) (+ current-pos 1) 
                        (str result (first remaining)))
            (subs-helper (rest remaining) (+ current-pos 1) result))))
      (subs-helper (str-to-chars s) 0 ""))))

;; Convert string to list of characters (helper function)
(defn str-to-chars [s]
  ;; This is a simplified version - in real implementation would need
  ;; proper string iteration support from Rust
  (if (= (str-length s) 0)
    '()
    ;; For now, return the string as a single "character"
    ;; Real implementation would split properly
    (list s)))

;; Join collection with separator
(defn join [separator coll]
  (if (empty? coll)
    ""
    (if (empty? (rest coll))
      (str (first coll))
      (str (first coll) separator (join separator (rest coll))))))

;; Split string on separator (simplified version)
(defn split [s separator]
  ;; Simplified implementation - just return the string in a list
  ;; Real implementation would need better string parsing from Rust
  (list s))

;; Check if string is empty
(defn empty-string? [s]
  (= (str-length s) 0))

;; String contains substring check (simplified)
(defn contains-str? [s substring]
  ;; Simplified - just check equality for now
  ;; Real implementation needs substring search
  (= s substring))

;; String starts with prefix
(defn starts-with? [s prefix]
  (if (> (str-length prefix) (str-length s))
    false
    (= (subs s 0 (str-length prefix)) prefix)))

;; String ends with suffix  
(defn ends-with? [s suffix]
  (let [s-len (str-length s)
        suffix-len (str-length suffix)]
    (if (> suffix-len s-len)
      false
      (= (subs s (- s-len suffix-len) s-len) suffix))))

;; Convert to uppercase (placeholder - needs Rust implementation)
(defn upper-case [s]
  s) ; Return as-is for now

;; Convert to lowercase (placeholder - needs Rust implementation)  
(defn lower-case [s]
  s) ; Return as-is for now

;; Trim whitespace (placeholder - needs Rust implementation)
(defn trim [s]
  s) ; Return as-is for now

;; Reverse string
(defn reverse-str [s]
  (join "" (reverse (str-to-chars s))))

;; Replace substring (simplified)
(defn replace [s old new]
  ;; Simplified implementation
  (if (= s old) new s))

;; Repeat string n times
(defn repeat-str [s n]
  (if (<= n 0)
    ""
    (str s (repeat-str s (- n 1)))))

;; String interpolation helper
(defn format [template & args]
  ;; Simplified format - just concatenate for now
  (apply str template args))