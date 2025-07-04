#!/usr/bin/env cortado
;; Enhanced I/O Demonstration
;; Shows the new Clojure-inspired I/O features in Cortado

(println "🚀 Cortado Enhanced I/O Demonstration")
(println "=====================================")

;; 1. Enhanced File Operations
(println "\n📁 Enhanced File Operations:")

;; Create a test file using spit (enhanced write-file)
(spit "demo.txt" "Hello from Clojure-inspired I/O!")
(println "✓ Created file with spit")

;; Read it back using slurp (enhanced read-file)  
(def content (slurp "demo.txt"))
(println "✓ Read content with slurp:" content)

;; 2. File System Operations
(println "\n🗂️  File System Operations:")

;; Check file existence and properties
(println "File exists?" (file-exists? "demo.txt"))
(println "File size:" (file-size "demo.txt") "bytes")
(println "Is directory?" (directory? "demo.txt"))
(println "Current dir is directory?" (directory? "."))

;; 3. Directory Operations
(println "\n📂 Directory Operations:")

;; Create a test directory
(create-dir "test-io-dir")
(println "✓ Created directory")

;; List current directory contents (just show it works)
(def dir-contents (list-dir "."))
(println "✓ Listed directory contents successfully")

;; 4. File Manipulation
(println "\n🔧 File Manipulation:")

;; Copy file
(copy-file "demo.txt" "demo-copy.txt")
(println "✓ Copied file")

;; Move file  
(move-file "demo-copy.txt" "demo-moved.txt")
(println "✓ Moved file")

;; Verify the moved file
(println "Moved file exists?" (file-exists? "demo-moved.txt"))
(println "Original copy exists?" (file-exists? "demo-copy.txt"))

;; 5. Stream-like Operations
(println "\n🌊 Stream Operations:")

;; Create readers and writers
(def test-reader (reader "demo.txt"))
(def test-writer (writer "stream-output.txt"))
(println "✓ Created reader and writer streams")

;; Use copy to transfer data
(def bytes-copied (copy "demo.txt" "stream-copy.txt"))
(println "✓ Copied" bytes-copied "bytes using copy function")

;; 6. Standard I/O Enhancement
(println "\n💬 Standard I/O:")

;; Enhanced printing
(println "Using println with multiple args:" "Hello" "Enhanced" "I/O!")
(printf "Using printf: %s has %s functions\n" "Cortado" "many")

;; 7. Cleanup
(println "\n🧹 Cleanup:")
(delete-file "demo.txt")
(delete-file "demo-moved.txt") 
(delete-file "stream-output.txt")
(delete-file "stream-copy.txt")
(delete-dir "test-io-dir")
(println "✓ Cleaned up all test files and directories")

(println "\n🎉 Enhanced I/O demonstration complete!")
(println "Cortado now has robust, Clojure-inspired I/O capabilities:")
(println "  • Polymorphic resource functions (reader, writer, slurp, spit)")
(println "  • File system operations (file-exists?, file-size, copy-file, etc.)")
(println "  • Directory management (list-dir, create-dir, delete-dir)")
(println "  • Enhanced standard I/O (println, printf, read-line)")
(println "  • Stream-like operations with automatic resource handling")