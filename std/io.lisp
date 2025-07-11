;; Cortado I/O Module - Minimal
(ns io)

;; File info function
(defn file-info [path]
  {:exists (file-exists? path)
   :size (file-size path)
   :path path})

;; with-open macro - simple resource management
(defmacro with-open [bindings body]
  `(let [~(first bindings) ~(second bindings)]
     (let [result# ~body]
       result#)))