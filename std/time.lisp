;; Cortado Standard Library - Time Module  
;; Time-related functions using Rust interop

;; Get current time in milliseconds since UNIX epoch
;; (now-ms) is provided by Rust

;; Sleep for specified milliseconds
;; (sleep-ms ms) is provided by Rust

;; Time a function execution
(defn time [f]
  (let [start (now-ms)
        result (f)
        end (now-ms)]
    (print "Elapsed time:" (- end start) "ms")
    result))

;; Create a simple timer
(defn make-timer []
  (let [start (now-ms)]
    (fn [] (- (now-ms) start))))

;; Measure execution time of expression (macro version)
(defmacro time-expr [expr]
  `(let [start (now-ms)
         result ~expr
         end (now-ms)]
     (print "Time:" (- end start) "ms")
     result))
