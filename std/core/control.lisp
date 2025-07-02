;; Control Flow Macros for Cortado
(ns core.control)

;; when-not - execute body when condition is false
(defmacro when-not [test body]
  (list 'if test nil body))

;; if-not - if with inverted condition
(defmacro if-not [test then else]
  (list 'if test else then))

;; Simple case macro for 2 alternatives + default
(defmacro case [expr val1 result1 val2 result2 default]
  (list 'if (list '= expr val1) 
        result1 
        (list 'if (list '= expr val2) 
              result2 
              default)))

;; cond - conditional with 2 conditions + default
(defmacro cond [cond1 result1 cond2 result2 default]
  (list 'if cond1 
        result1 
        (list 'if cond2 
              result2 
              default)))

;; condp - conditional with predicate (simplified)
(defmacro condp [pred expr val1 result1 val2 result2 default]
  (list 'if (list pred val1 expr) 
        result1 
        (list 'if (list pred val2 expr) 
              result2 
              default)))

;; or - logical or for 2 arguments
(defmacro or [arg1 arg2]
  (list 'if arg1 arg1 arg2))

;; and - logical and for 2 arguments  
(defmacro and [arg1 arg2]
  (list 'if arg1 arg2 false))