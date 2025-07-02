;; Cortado Threading Macros - Core productivity enhancers
;; These macros dramatically improve code readability and composition

(ns core.threading)

;; Thread-first macro for single form: insert expr as second element
;; (-> x f) => (f x)
;; (-> x (f a)) => (f x a)
(defmacro -> [expr form]
  (if (list? form)
    ;; Function call: insert expr as second element  
    (cons (first form) (cons expr (rest form)))
    ;; Simple symbol: create function call
    (list form expr)))

;; Thread-first macro for two forms
(defmacro ->2 [expr form1 form2]
  (list 'core.threading/-> (list 'core.threading/-> expr form1) form2))

;; Thread-first macro for three forms  
(defmacro ->3 [expr form1 form2 form3]
  (list 'core.threading/-> (list 'core.threading/->2 expr form1 form2) form3))

;; Thread-last macro for single form: insert expr as last element  
;; (->> x f) => (f x)
;; (->> x (f a)) => (f a x)
(defmacro ->> [expr form]
  (if (list? form)
    ;; Function call: append expr as last element
    (concat form (list expr))
    ;; Simple symbol: create function call
    (list form expr)))

;; Thread-last macro for two forms
(defmacro ->>2 [expr form1 form2]
  (list 'core.threading/->> (list 'core.threading/->> expr form1) form2))

;; Thread-last macro for three forms
(defmacro ->>3 [expr form1 form2 form3]
  (list 'core.threading/->> (list 'core.threading/->>2 expr form1 form2) form3))