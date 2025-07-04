;; Cortado I/O Module - Minimal
(ns io)

;; File info function
(defn file-info [path]
  {:exists (file-exists? path)
   :size (file-size path)
   :path path})