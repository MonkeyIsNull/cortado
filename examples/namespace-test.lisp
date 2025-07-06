#!/usr/bin/env cortado

;; Test namespace functionality

(print "=== Testing Namespaces ===")

;; Test basic namespace switching
(print "\n1. Testing basic namespace:")
(ns user)
(print "Current namespace should be user")

(defn user-func [x] (+ x 100))
(print "Defined user-func in user namespace")
(print "user-func(5) =" (user-func 5))

;; Test require and qualified calls
(print "\n2. Testing require:")
(require 'math.arith)
(print "Required math.arith namespace")

;; Try calling function after require
(print "double(10) =" (double 10))
(print "triple(3) =" (triple 3))

;; Test namespace isolation
(print "\n3. Testing namespace isolation:")
(ns test.namespace)
(defn double [x] (* x 4))  ; Different implementation than math.arith
(print "Defined local double in test.namespace")
(print "Local double(10) =" (double 10))
(print "Original double(10) should be:" (double 10))

;; Switch back to user
(print "\n4. Back to user namespace:")
(ns user)
(print "user-func(10) =" (user-func 10))

(print "\n=== Namespace tests completed ===")

"namespace-test-complete"