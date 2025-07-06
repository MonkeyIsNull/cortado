;; Cortado Test Framework
;; Following Clojure conventions for testing

;; Test tracking state
(def *test-passes* 0)
(def *test-fails* 0)
(def *test-errors* 0)
(def *current-test-file* "")

;; Core testing function that tracks results
(defn test-assert-eq [expected actual] (if (= expected actual) (do (def *test-passes* (+ *test-passes* 1)) (print "  ✓ PASS:" expected "==" actual) true) (do (def *test-fails* (+ *test-fails* 1)) (print "  ✗ FAIL: expected" expected "but got" actual) false)))

;; Alias for compatibility
(defn assert-eq [expected actual] (test-assert-eq expected actual))

;; Assert not equal function
(defn assert-not-eq [expected actual] (if (not (= expected actual)) (do (def *test-passes* (+ *test-passes* 1)) (print "  ✓ PASS:" expected "!=" actual) true) (do (def *test-fails* (+ *test-fails* 1)) (print "  ✗ FAIL: expected" expected "NOT to equal" actual) false)))

;; Test file runner
(defn run-test-file [filepath] (do (print "\n📋 Testing:" filepath) (def *current-test-file* filepath) (load filepath)))

;; Reset test counters
(defn reset-test-stats [] (do (def *test-passes* 0) (def *test-fails* 0) (def *test-errors* 0)))

;; Get test summary
(defn test-summary [] (str *test-passes* " passed, " *test-fails* " failed, " *test-errors* " errors"))

;; Standard test helpers
(defn is [expr] (if expr (test-assert-eq true true) (test-assert-eq true false)))

(defn is-not [expr] (if expr (test-assert-eq false true) (test-assert-eq false false)))

;; Error handling wrapper
(defn test-error [msg] (do (def *test-errors* (+ *test-errors* 1)) (print "  💥 ERROR:" msg)))