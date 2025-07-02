#!/usr/bin/env cortado

;; Cortado Namespace Aliasing Demo
;; Demonstrates the new :as aliasing feature

(print "=== Cortado Namespace Aliasing Demo ===")
(print)

;; Load core.seq namespace with a short alias
(require [core.seq :as s])
(print "Loaded core.seq namespace with alias 's'")

;; Sample data
(def numbers '(1 2 3 4 5 6 7 8 9 10))
(print "Sample data:" numbers)
(print)

;; Use aliased functions
(print "Using aliased functions:")

;; Map with alias
(def doubled (s/map-list (fn [x] (* x 2)) numbers))
(print "Doubled:" doubled)

;; Filter with alias  
(def evens (s/filter-list (fn [x] (= (% x 2) 0)) numbers))
(print "Even numbers:" evens)

;; Reduce with alias
(def sum (s/reduce-list + 0 numbers))
(print "Sum:" sum)

;; Length with alias
(def count (s/length numbers))
(print "Count:" count)

;; Reverse with alias
(def backwards (s/reverse-list numbers))
(print "Reversed:" backwards)

(print)
(print "=== Demo Complete ===")
(print "Namespace aliasing makes code more readable!")
(print "Compare 's/map-list' vs 'core.seq/map-list'")