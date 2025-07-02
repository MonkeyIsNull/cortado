#!/usr/bin/env cortado

;; Threading Macros in Cortado
;; Improve code readability with -> and ->> macros

(print "=== Threading Macros: Write More Readable Code ===")
(print)

;; Load required modules
(require [core.threading :as t])
(require [core.seq :as s])
(require [core.functional :as fn])

;; === THE PROBLEM: NESTED FUNCTION CALLS ===
(print "1. The Problem with Nested Calls")

;; Complex nested expression - hard to read!
(def messy-calculation
  (+ (* (- (/ 100 4) 5) 3) 2))

(print "Messy nested calculation result:" messy-calculation)

;; Step by step (verbose but clear)
(def step1 (/ 100 4))    ; 25
(def step2 (- step1 5))  ; 20
(def step3 (* step2 3))  ; 60
(def step4 (+ step3 2))  ; 62

(print "Step-by-step result:" step4)
(print "Same as nested:" (= messy-calculation step4))
(print)

;; === THREAD-FIRST (->) MACRO ===
(print "2. Thread-First (->): Threading as First Argument")

;; Clean, readable version using thread-first
(def clean-calculation
  (t/->3 100
         (/ 4)      ; 100 / 4 = 25
         (- 5)      ; 25 - 5 = 20  
         (* 3)))    ; 20 * 3 = 60

;; Note: We need one more step for the final +2, but this shows the pattern
(print "Clean threaded calculation (partial):" clean-calculation)

;; String processing with thread-first
(def processed-string
  (t/->3 "hello"
         (str " world")     ; "hello" + " world" = "hello world"
         (str "!")          ; "hello world" + "!" = "hello world!"
         upper-case))       ; upper-case("hello world!")

; Note: upper-case is not implemented, this is conceptual
(print "String processing: hello -> hello world -> hello world! -> HELLO WORLD!")
(print)

;; === THREAD-LAST (->>) MACRO ===  
(print "3. Thread-Last (->>): Threading as Last Argument")

;; Mathematical operations where order matters
(def math-pipeline
  (t/->>3 10
          (* 2)    ; (* 2 10) = 20
          (+ 5)    ; (+ 5 20) = 25  
          (/ 100))) ; (/ 100 25) = 4

(print "Math pipeline result:" math-pipeline)

;; List processing - where ->> really shines
(def numbers '(1 2 3 4 5 6 7 8 9 10))

;; Without threading - nested and hard to read
(def nested-result
  (s/reduce-list +
    0
    (s/filter-list even?
      (s/map-list (fn [x] (* x x)) numbers))))

(print "Nested list processing result:" nested-result)

;; With thread-last - reads like a pipeline!
;; Note: This would be ideal, but we're limited to 2-3 steps in current implementation
(def pipeline-step1 (s/map-list (fn [x] (* x x)) numbers))      ; Square each
(def pipeline-step2 (s/filter-list even? pipeline-step1))       ; Keep evens
(def pipeline-step3 (s/reduce-list + 0 pipeline-step2))         ; Sum them

(print "Pipeline result:" pipeline-step3)
(print "Results match:" (= nested-result pipeline-step3))
(print)

;; === WHEN TO USE WHICH ===
(print "4. Thread-First vs Thread-Last: When to Use Which")

(print "Use Thread-First (->) for:")
(print "  - Object-like operations: obj.method1().method2()")
(print "  - Building up values step by step")
(print "  - String processing and transformations")
(print)

(print "Use Thread-Last (->>) for:")
(print "  - Collection processing pipelines")
(print "  - Data flowing through transformations") 
(print "  - Mathematical operations where order matters")
(print)

;; === PRACTICAL EXAMPLES ===
(print "5. Practical Examples")

;; Data processing pipeline
(def raw-data '(1 2 3 4 5 6 7 8 9 10 11 12))

;; Step-by-step approach (what the threading macro does internally)
(print "Processing pipeline:")
(def squared-data (s/map-list (fn [x] (* x x)) raw-data))
(print "  1. Squared:" squared-data)

(def filtered-data (s/filter-list (fn [x] (> x 20)) squared-data))
(print "  2. Filtered (>20):" filtered-data)

(def summed-data (s/reduce-list + 0 filtered-data))
(print "  3. Summed:" summed-data)

;; Using thread-last for the same pipeline (conceptual)
;; (def threaded-result
;;   (t/->>3 raw-data
;;           (s/map-list (fn [x] (* x x)))
;;           (s/filter-list (fn [x] (> x 20)))
;;           (s/reduce-list + 0)))

(print)

;; === BUILDING COMPLEX DATA ===
(print "6. Building Complex Data Structures")

;; Building a user record step by step
(defn add-name [record name]
  (assoc record :name name))

(defn add-age [record age]
  (assoc record :age age))

(defn add-email [record email]
  (assoc record :email email))

(defn activate-user [record]
  (assoc record :active true))

;; Without threading
(def user-nested
  (activate-user
    (add-email
      (add-age
        (add-name {} "Alice")
        25)
      "alice@example.com")))

(print "User built without threading:" user-nested)

;; With thread-first (step by step)
(def user-step1 (add-name {} "Bob"))
(def user-step2 (add-age user-step1 30))
(def user-step3 (add-email user-step2 "bob@example.com"))
(def user-step4 (activate-user user-step3))

(print "User built step by step:" user-step4)

;; With thread-first macro (clean and readable)
(def user-threaded
  (t/->3 {}
         (add-name "Carol")
         (add-age 28)
         (add-email "carol@example.com")))

;; Note: We'd need a 4-step macro for the full pipeline
(def final-user (activate-user user-threaded))
(print "User built with threading:" final-user)
(print)

;; === CONDITIONAL THREADING ===
(print "7. Conditional Processing")

(defn process-if-positive [x]
  (if (> x 0)
    (* x 2)
    x))

(defn process-if-even [x]
  (if (even? x)
    (+ x 10)
    x))

;; Chain conditional processing
(def test-values '(-5 3 4 7))

(print "Conditional processing results:")
(s/map-list (fn [x]
              (let [step1 (process-if-positive x)
                    step2 (process-if-even step1)]
                (print "  " x "->" step1 "->" step2)))
            test-values)
(print)

;; === DEBUGGING THREADED CODE ===
(print "8. Debugging Threaded Pipelines")

;; Add debugging function
(defn debug [label value]
  (print "DEBUG" label ":" value)
  value)

;; Pipeline with debugging
(def debugged-result
  (t/->3 10
         (debug "start")
         (* 3)
         (debug "after multiply")))

(print "Final debugged result:" debugged-result)
(print)

;; === REAL-WORLD EXAMPLE ===
(print "9. Real-World Example: Data Analysis")

;; Sales data analysis
(def sales '(
  {:product "Laptop" :price 999 :quantity 2}
  {:product "Mouse" :price 25 :quantity 10} 
  {:product "Keyboard" :price 75 :quantity 5}
  {:product "Monitor" :price 300 :quantity 3}
))

;; Calculate total revenue per item
(defn add-revenue [sale]
  (assoc sale :revenue (* (:price sale) (:quantity sale))))

;; Analysis pipeline
(def analysis-step1 (s/map-list add-revenue sales))
(print "1. With revenue:" analysis-step1)

(def analysis-step2 (s/filter-list (fn [sale] (> (:revenue sale) 200)) analysis-step1))
(print "2. High-value sales:" analysis-step2)

(def total-high-value (s/reduce-list + 0 (s/map-list (fn [sale] (:revenue sale)) analysis-step2)))
(print "3. Total high-value revenue:" total-high-value)

;; Same analysis with threading (conceptual - would need longer threading macros)
(print "This would be much cleaner with full threading macro support!")
(print)

;; === PERFORMANCE CONSIDERATIONS ===
(print "10. Performance and Best Practices")

(print "Threading macro best practices:")
(print "  - Use for readability, not performance")
(print "  - Thread-first for building up objects")
(print "  - Thread-last for data pipelines")
(print "  - Keep steps simple and focused")
(print "  - Add debugging steps when needed")
(print "  - Don't over-thread simple expressions")
(print)

;; === COMPARISON ===
(print "11. Before and After Comparison")

(print "BEFORE (nested, hard to read):")
(print "(s/reduce-list + 0 (s/filter-list even? (s/map-list inc numbers)))")
(print)

(print "AFTER (threaded, easy to read):")
(print "(->> numbers")
(print "     (s/map-list inc)")
(print "     (s/filter-list even?)")  
(print "     (s/reduce-list + 0))")
(print)

(print "=== Threading Macro Mastery ===")
(print "You've learned:")
(print "- Thread-first (->) for object-like operations")
(print "- Thread-last (->>) for data pipelines")
(print "- When to use which threading macro")
(print "- Debugging threaded expressions")
(print "- Real-world data processing examples")
(print "- Best practices for readable code")
(print)
(print "Threading macros transform hard-to-read nested code")
(print "into clear, linear pipelines that read like prose!")
(print)
(print "Next: Try examples/05-macros.lisp for advanced metaprogramming!")