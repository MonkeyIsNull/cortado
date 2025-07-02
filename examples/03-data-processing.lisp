#!/usr/bin/env cortado

;; Data Processing with Cortado
;; Advanced data transformation pipelines and analysis

(print "=== Data Processing Pipelines ===")
(print)

;; Load required modules
(require [core.seq :as s])
(require [core.threading :as t])
(require [core.functional :as fn])
(require [core.sequences :as seq])

;; === SAMPLE DATA ===
(print "1. Sample Data Sets")

;; Sales data
(def sales-data '(
  {:id 1 :product "Laptop" :price 999 :quantity 2 :region "North"}
  {:id 2 :product "Mouse" :price 25 :quantity 10 :region "South"}
  {:id 3 :product "Keyboard" :price 75 :quantity 5 :region "North"}
  {:id 4 :product "Monitor" :price 300 :quantity 3 :region "East"}
  {:id 5 :product "Laptop" :price 999 :quantity 1 :region "West"}
  {:id 6 :product "Mouse" :price 25 :quantity 8 :region "North"}
  {:id 7 :product "Headphones" :price 150 :quantity 4 :region "South"}
))

;; Employee data
(def employees '(
  {:name "Alice" :department "Engineering" :salary 85000 :years 3}
  {:name "Bob" :department "Sales" :salary 65000 :years 5}
  {:name "Carol" :department "Engineering" :salary 95000 :years 7}
  {:name "Dave" :department "Marketing" :salary 55000 :years 2}
  {:name "Eve" :department "Sales" :salary 70000 :years 4}
  {:name "Frank" :department "Engineering" :salary 110000 :years 10}
))

;; Sensor readings
(def sensor-data '(
  {:timestamp 1001 :temperature 22.5 :humidity 45 :sensor "A1"}
  {:timestamp 1002 :temperature 23.1 :humidity 47 :sensor "A1"}
  {:timestamp 1003 :temperature 21.8 :humidity 43 :sensor "A2"}
  {:timestamp 1004 :temperature 24.2 :humidity 50 :sensor "A1"}
  {:timestamp 1005 :temperature 22.0 :humidity 44 :sensor "A2"}
))

(print "Loaded sample data sets:")
(print "- Sales data:" (s/length sales-data) "records")
(print "- Employee data:" (s/length employees) "records") 
(print "- Sensor data:" (s/length sensor-data) "readings")
(print)

;; === BASIC DATA EXTRACTION ===
(print "2. Basic Data Extraction")

;; Extract specific fields
(defn get-field [field] (fn [record] (get record field)))

(def product-names (s/map-list (get-field :product) sales-data))
(def employee-names (s/map-list (get-field :name) employees))

(print "Products:" product-names)
(print "Employees:" employee-names)
(print)

;; === FILTERING AND SELECTION ===
(print "3. Filtering and Selection")

;; High-value sales (price > 100)
(def high-value-sales 
  (s/filter-list (fn [sale] (> (:price sale) 100)) sales-data))

(print "High-value sales (>$100):")
(s/map-list (fn [sale] 
              (print "  " (:product sale) "-" (:price sale)))
            high-value-sales)

;; Senior employees (years > 5)
(def senior-employees
  (s/filter-list (fn [emp] (> (:years emp) 5)) employees))

(print "Senior employees (>5 years):")
(s/map-list (fn [emp]
              (print "  " (:name emp) "-" (:years emp) "years"))
            senior-employees)
(print)

;; === AGGREGATION AND CALCULATIONS ===
(print "4. Aggregation and Calculations")

;; Calculate revenue per sale
(defn calculate-revenue [sale]
  (assoc sale :revenue (* (:price sale) (:quantity sale))))

(def sales-with-revenue 
  (s/map-list calculate-revenue sales-data))

;; Total revenue
(def total-revenue
  (s/reduce-list + 0 
    (s/map-list (get-field :revenue) sales-with-revenue)))

(print "Total revenue: $" total-revenue)

;; Average salary by department
(defn filter-by-dept [dept]
  (s/filter-list (fn [emp] (= (:department emp) dept)) employees))

(defn average-salary [emps]
  (if (empty? emps)
    0
    (/ (s/reduce-list + 0 (s/map-list (get-field :salary) emps))
       (s/length emps))))

(def eng-avg (average-salary (filter-by-dept "Engineering")))
(def sales-avg (average-salary (filter-by-dept "Sales")))

(print "Average Engineering salary: $" eng-avg)
(print "Average Sales salary: $" sales-avg)
(print)

;; === GROUPING AND ANALYSIS ===
(print "5. Grouping and Analysis")

;; Group sales by region (simplified grouping)
(defn sales-by-region [region]
  (s/filter-list (fn [sale] (= (:region sale) region)) sales-data))

(def regions '("North" "South" "East" "West"))

(print "Sales by region:")
(s/map-list (fn [region]
              (let [region-sales (sales-by-region region)
                    count (s/length region-sales)]
                (print "  " region ":" count "sales")))
            regions)

;; Product popularity (count by product)
(defn count-product [product]
  (s/length (s/filter-list (fn [sale] (= (:product sale) product)) sales-data)))

(def unique-products (seq/distinct (s/map-list (get-field :product) sales-data)))

(print "Product popularity:")
(s/map-list (fn [product]
              (print "  " product ":" (count-product product) "sales"))
            unique-products)
(print)

;; === ADVANCED PIPELINES ===
(print "6. Advanced Processing Pipelines")

;; Complex data transformation pipeline
(defn analyze-sales-performance []
  (let [
    ;; Step 1: Add revenue calculation
    with-revenue (s/map-list calculate-revenue sales-data)
    
    ;; Step 2: Filter high-value transactions
    high-value (s/filter-list (fn [sale] (> (:revenue sale) 200)) with-revenue)
    
    ;; Step 3: Extract revenues
    revenues (s/map-list (get-field :revenue) high-value)
    
    ;; Step 4: Calculate statistics
    total (s/reduce-list + 0 revenues)
    count (s/length revenues)
    average (if (> count 0) (/ total count) 0)
  ]
    {:total-revenue total
     :transaction-count count
     :average-revenue average}))

(def performance-stats (analyze-sales-performance))
(print "High-value sales analysis:")
(print "  Total revenue: $" (:total-revenue performance-stats))
(print "  Transaction count:" (:transaction-count performance-stats))
(print "  Average revenue: $" (:average-revenue performance-stats))
(print)

;; === TIME SERIES ANALYSIS ===
(print "7. Time Series Analysis")

;; Analyze sensor data trends
(defn analyze-sensor-trends [sensor-id]
  (let [
    sensor-readings (s/filter-list (fn [reading] (= (:sensor reading) sensor-id)) sensor-data)
    temperatures (s/map-list (get-field :temperature) sensor-readings)
    humidities (s/map-list (get-field :humidity) sensor-readings)
  ]
    {:sensor sensor-id
     :readings (s/length sensor-readings)
     :avg-temp (/ (s/reduce-list + 0 temperatures) (s/length temperatures))
     :avg-humidity (/ (s/reduce-list + 0 humidities) (s/length humidities))}))

(def sensor-a1-analysis (analyze-sensor-trends "A1"))
(def sensor-a2-analysis (analyze-sensor-trends "A2"))

(print "Sensor A1 analysis:")
(print "  Readings:" (:readings sensor-a1-analysis))
(print "  Avg temperature:" (:avg-temp sensor-a1-analysis))
(print "  Avg humidity:" (:avg-humidity sensor-a1-analysis))

(print "Sensor A2 analysis:")
(print "  Readings:" (:readings sensor-a2-analysis))
(print "  Avg temperature:" (:avg-temp sensor-a2-analysis))
(print "  Avg humidity:" (:avg-humidity sensor-a2-analysis))
(print)

;; === DATA VALIDATION ===
(print "8. Data Validation and Cleaning")

;; Validation functions
(defn valid-sale? [sale]
  (and (> (:price sale) 0)
       (> (:quantity sale) 0)
       (not (nil? (:product sale)))))

(defn valid-employee? [emp]
  (and (not (nil? (:name emp)))
       (> (:salary emp) 0)
       (>= (:years emp) 0)))

;; Clean data
(def valid-sales (s/filter-list valid-sale? sales-data))
(def valid-employees (s/filter-list valid-employee? employees))

(print "Data validation:")
(print "  Valid sales:" (s/length valid-sales) "/" (s/length sales-data))
(print "  Valid employees:" (s/length valid-employees) "/" (s/length employees))
(print)

;; === REPORT GENERATION ===
(print "9. Report Generation")

(defn generate-sales-report []
  (print "=== SALES REPORT ===")
  (print "Total transactions:" (s/length sales-data))
  (print "Total revenue: $" total-revenue)
  (print "Average transaction value: $" (/ total-revenue (s/length sales-data)))
  (print)
  
  (print "Top products by quantity sold:")
  ;; This is simplified - real implementation would sort by quantity
  (s/map-list (fn [product]
                (let [sales (s/filter-list (fn [sale] (= (:product sale) product)) sales-data)
                      total-qty (s/reduce-list + 0 (s/map-list (get-field :quantity) sales))]
                  (print "  " product ":" total-qty "units")))
              unique-products)
  (print "=== END REPORT ==="))

(generate-sales-report)
(print)

;; === ADVANCED PATTERNS ===
(print "10. Advanced Processing Patterns")

;; Chain multiple transformations
(defn process-employee-data []
  (s/reduce-list + 0
    (s/map-list (get-field :salary)
      (s/filter-list (fn [emp] (= (:department emp) "Engineering"))
        (s/filter-list (fn [emp] (> (:years emp) 3)) employees)))))

(def eng-senior-total-salary (process-employee-data))
(print "Total salary of senior Engineers: $" eng-senior-total-salary)

;; Data enrichment
(defn enrich-sale-data [sale]
  (let [revenue (* (:price sale) (:quantity sale))
        category (if (> (:price sale) 100) "Premium" "Standard")]
    (assoc sale :revenue revenue :category category)))

(def enriched-sales (s/map-list enrich-sale-data sales-data))
(print "Enriched sales data (first item):")
(print "  " (first enriched-sales))
(print)

(print "=== Data Processing Mastery ===")
(print "You've learned:")
(print "- Data extraction and field access")
(print "- Filtering and selection criteria")
(print "- Aggregation and statistical calculations")
(print "- Grouping and categorization")
(print "- Advanced transformation pipelines")
(print "- Time series analysis techniques")
(print "- Data validation and cleaning")
(print "- Report generation")
(print)
(print "Next: Try examples/04-threading-macros.lisp for cleaner pipelines!")