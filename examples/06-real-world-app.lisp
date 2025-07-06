#!/usr/bin/env cortado

;; Real-World Cortado Application
;; A complete task management system demonstrating best practices

(print "=== Task Management System ===")
(print "A real-world Cortado application")
(print)

;; Load required modules
(require 'core.seq)
(require 'core.functional)
(require 'core.threading)
(require 'core.control)

;; === APPLICATION CONFIGURATION ===
(ns app.config)

(def config {
  :app-name "Cortado Task Manager"
  :version "1.0.0"
  :max-tasks 100
  :default-priority :medium
  :valid-statuses '(:todo :in-progress :done :cancelled)
  :valid-priorities '(:low :medium :high :urgent)
})

(print "Application:" (:app-name config) "v" (:version config))
(print)

;; === DATA MODELS ===
(ns app.models)

;; Task data structure
(defn create-task [id title description]
  {:id id
   :title title
   :description description
   :status :todo
   :priority (:default-priority config)
   :created-at (now)
   :updated-at (now)
   :tags '()
   :assignee nil})

;; User data structure
(defn create-user [id name email role]
  {:id id
   :name name
   :email email
   :role role
   :active true
   :tasks '()})

;; Project data structure
(defn create-project [id name description]
  {:id id
   :name name
   :description description
   :tasks '()
   :members '()
   :created-at (now)})

(print "Data models defined: Task, User, Project")
(print)

;; === VALIDATION ===
(ns app.validation)

(defn valid-task? [task]
  (and (not (nil? (:id task)))
       (not (nil? (:title task)))
       (contains? (:valid-statuses config) (:status task))
       (contains? (:valid-priorities config) (:priority task))))

(defn valid-user? [user]
  (and (not (nil? (:id user)))
       (not (nil? (:name user)))
       (not (nil? (:email user)))
       (contains? '(:admin :manager :developer :tester) (:role user))))

(defn valid-priority? [priority]
  (contains? (:valid-priorities config) priority))

(defn valid-status? [status]
  (contains? (:valid-statuses config) status))

(print "Validation functions defined")
(print)

;; === CORE BUSINESS LOGIC ===
(ns app.core)

;; Task operations
(defn add-task [task-list task]
  (if (valid-task? task)
    (if (< (length task-list) (:max-tasks config))
      (cons task task-list)
      (do
        (print "ERROR: Maximum tasks limit reached")
        task-list))
    (do
      (print "ERROR: Invalid task data")
      task-list)))

(defn update-task-status [task new-status]
  (if (valid-status? new-status)
    (assoc task :status new-status :updated-at (now))
    (do
      (print "ERROR: Invalid status" new-status)
      task)))

(defn update-task-priority [task new-priority]
  (if (valid-priority? new-priority)
    (assoc task :priority new-priority :updated-at (now))
    (do
      (print "ERROR: Invalid priority" new-priority)
      task)))

(defn assign-task [task user-id]
  (assoc task :assignee user-id :updated-at (now)))

(defn add-tag [task tag]
  (assoc task :tags (cons tag (:tags task)) :updated-at (now)))

;; Search and filter operations
(defn find-task-by-id [task-list id]
  (filter-list (fn [task] (= (:id task) id)) task-list))

(defn find-tasks-by-status [task-list status]
  (filter-list (fn [task] (= (:status task) status)) task-list))

(defn find-tasks-by-priority [task-list priority]
  (filter-list (fn [task] (= (:priority task) priority)) task-list))

(defn find-tasks-by-assignee [task-list user-id]
  (filter-list (fn [task] (= (:assignee task) user-id)) task-list))

(print "Core business logic defined")
(print)

;; === SAMPLE DATA ===
(ns app.data)

;; Create sample users
(def users (list
  (create-user 1 "Alice Johnson" "alice@example.com" :manager)
  (create-user 2 "Bob Smith" "bob@example.com" :developer)
  (create-user 3 "Carol Davis" "carol@example.com" :developer)
  (create-user 4 "Dave Wilson" "dave@example.com" :tester)))

;; Create sample tasks
(def tasks (list
  (create-task 1 "Setup development environment" "Install and configure development tools")
  (create-task 2 "Design user interface" "Create mockups and wireframes for the application")
  (create-task 3 "Implement authentication" "Add user login and registration functionality")
  (create-task 4 "Write unit tests" "Create comprehensive test suite")
  (create-task 5 "Deploy to staging" "Set up staging environment and deployment pipeline")))

;; Update some tasks with different statuses and assignments
(def task1 (first tasks))
(def updated-task1 (assign-task (update-task-status task1 :in-progress) 2))

(def task2 (first (rest tasks)))
(def updated-task2 (assign-task (update-task-priority task2 :high) 3))

(def task3 (first (rest (rest tasks))))
(def updated-task3 (assign-task (add-tag task3 "backend") 2))

;; Updated task list
(def current-tasks (list updated-task1 updated-task2 updated-task3 
                        (first (rest (rest (rest tasks))))
                        (first (rest (rest (rest (rest tasks)))))))

(print "Sample data created:")
(print "  Users:" (length users))
(print "  Tasks:" (length current-tasks))
(print)

;; === REPORTING AND ANALYTICS ===
(ns app.reports)

(defn generate-status-report [task-list]
  (print "=== TASK STATUS REPORT ===")
  (let [todo-count (length (find-tasks-by-status task-list :todo))
        in-progress-count (length (find-tasks-by-status task-list :in-progress))
        done-count (length (find-tasks-by-status task-list :done))
        total-count (length task-list)]
    (print "TODO:" todo-count)
    (print "IN PROGRESS:" in-progress-count)
    (print "DONE:" done-count)
    (print "TOTAL:" total-count)
    (print "COMPLETION RATE:" (if (> total-count 0) 
                                 (/ (* done-count 100) total-count) 
                                 0) "%")))

(defn generate-priority-report [task-list]
  (print "=== PRIORITY REPORT ===")
  (let [urgent-count (length (find-tasks-by-priority task-list :urgent))
        high-count (length (find-tasks-by-priority task-list :high))
        medium-count (length (find-tasks-by-priority task-list :medium))
        low-count (length (find-tasks-by-priority task-list :low))]
    (print "URGENT:" urgent-count)
    (print "HIGH:" high-count)
    (print "MEDIUM:" medium-count)
    (print "LOW:" low-count)))

(defn generate-assignment-report [task-list user-list]
  (print "=== ASSIGNMENT REPORT ===")
  (map-list (fn [user]
                (let [user-tasks (find-tasks-by-assignee task-list (:id user))
                      task-count (length user-tasks)]
                  (print (:name user) ":" task-count "tasks")))
              user-list)
  
  (let [unassigned-tasks (filter-list (fn [task] (nil? (:assignee task))) task-list)]
    (print "UNASSIGNED:" (length unassigned-tasks) "tasks")))

(print "Reporting functions defined")
(print)

;; === USER INTERFACE (SIMULATION) ===
(ns app.ui)

(defn display-task [task]
  (print "  [" (:id task) "]" (:title task)
         "| Status:" (:status task)
         "| Priority:" (:priority task)
         "| Assignee:" (if (:assignee task) (:assignee task) "Unassigned")))

(defn display-task-list [task-list title]
  (print)
  (print "=== " title " ===")
  (if (empty? task-list)
    (print "  No tasks found")
    (map-list display-task task-list)))

(defn display-user [user]
  (print "  " (:name user) "(" (:email user) ") -" (:role user)))

(defn display-user-list [user-list]
  (print)
  (print "=== USERS ===")
  (map-list display-user user-list))

(print "UI functions defined")
(print)

;; === APPLICATION CONTROLLER ===
(ns app.controller)

(defn show-dashboard []
  (print)
  (print "╔════════════════════════════════════════╗")
  (print "║          TASK MANAGER DASHBOARD        ║")
  (print "╚════════════════════════════════════════╝")
  
  ;; Show current status
  (generate-status-report current-tasks)
  (generate-priority-report current-tasks)
  (generate-assignment-report current-tasks users)
  
  ;; Show task lists
  (display-task-list current-tasks "ALL TASKS")
  (display-task-list (find-tasks-by-status current-tasks :todo) "TODO TASKS")
  (display-task-list (find-tasks-by-status current-tasks :in-progress) "IN PROGRESS")
  (display-task-list (find-tasks-by-priority current-tasks :high) "HIGH PRIORITY")
  
  ;; Show users
  (display-user-list users))

(defn simulate-workflow []
  (print)
  (print "=== SIMULATING WORKFLOW ===")
  
  ;; Create a new task
  (def new-task (create-task 6 "Code review" "Review pull requests from team members"))
  (print "Created new task:" (:title new-task))
  
  ;; Add it to the task list
  (def updated-tasks (add-task current-tasks new-task))
  (print "Added to task list. Total tasks:" (length updated-tasks))
  
  ;; Update task status
  (def task-to-update (first updated-tasks))
  (def completed-task (update-task-status task-to-update :done))
  (print "Completed task:" (:title completed-task))
  
  ;; Show updated statistics
  (generate-status-report updated-tasks))

(print "Controller functions defined")
(print)

;; === UTILITY FUNCTIONS ===
(ns app.utils)

(defn format-timestamp [timestamp]
  ;; Simplified timestamp formatting
  (str "Time:" timestamp))

(defn calculate-task-age [task]
  ;; Simplified age calculation
  (- (now) (:created-at task)))

(defn get-overdue-tasks [task-list days]
  ;; Find tasks older than specified days
  (filter-list (fn [task] 
                   (> (calculate-task-age task) days)) 
                 task-list))

(defn export-tasks-to-csv [task-list]
  ;; Simplified CSV export
  (print "CSV Export (simplified):")
  (print "ID,Title,Status,Priority,Assignee")
  (map-list (fn [task]
                (print (:id task) "," (:title task) "," 
                       (:status task) "," (:priority task) ","
                       (if (:assignee task) (:assignee task) "None")))
              task-list))

(print "Utility functions defined")
(print)

;; === ERROR HANDLING ===
(ns app.errors)

(defn handle-error [error-type message]
  (print "ERROR [" error-type "]:" message))

(defn validate-and-execute [validator data action]
  (if (validator data)
    (action data)
    (handle-error :validation "Invalid data provided")))

(print "Error handling defined")
(print)

;; === MAIN APPLICATION ===
(ns app.main)

(defn start-application []
  (print "Starting" (:app-name config) "version" (:version config))
  (print "═══════════════════════════════════════════════════")
  
  ;; Show dashboard
  (show-dashboard)
  
  ;; Simulate some workflow
  (simulate-workflow)
  
  ;; Export data
  (print)
  (export-tasks-to-csv current-tasks)
  
  (print)
  (print "Application demonstration complete!")
  (print "═══════════════════════════════════════════════════"))

;; === RUN THE APPLICATION ===
(start-application)

(print)
(print "=== REAL-WORLD APPLICATION FEATURES DEMONSTRATED ===")
(print)
(print "Architecture & Organization:")
(print "  ✓ Namespaced modules (config, models, validation, etc.)")
(print "  ✓ Separation of concerns")
(print "  ✓ Configuration management")
(print "  ✓ Data models and structures")
(print)
(print "Business Logic:")
(print "  ✓ Task management operations")
(print "  ✓ User management")
(print "  ✓ Search and filtering")
(print "  ✓ Status and priority updates")
(print "  ✓ Assignment tracking")
(print)
(print "Data Processing:")
(print "  ✓ Functional pipelines")
(print "  ✓ Data transformation")
(print "  ✓ Aggregation and reporting")
(print "  ✓ Statistics calculation")
(print)
(print "Quality & Reliability:")
(print "  ✓ Input validation")
(print "  ✓ Error handling")
(print "  ✓ Data integrity checks")
(print "  ✓ Business rule enforcement")
(print)
(print "User Interface:")
(print "  ✓ Formatted output")
(print "  ✓ Dashboard views")
(print "  ✓ Data export functionality")
(print "  ✓ Interactive simulation")
(print)
(print "This demonstrates how to build robust, maintainable")
(print "applications using Cortado's functional programming")
(print "features and best practices!")
(print)
(print "Key takeaways:")
(print "- Use namespaces to organize code")
(print "- Validate data at boundaries")
(print "- Separate business logic from presentation")
(print "- Use functional pipelines for data processing")
(print "- Handle errors gracefully")
(print "- Write testable, pure functions when possible")