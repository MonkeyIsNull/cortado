#!/usr/bin/env cortado

;; Data Processing with Cortado
;; Advanced data transformation pipelines and analysis

(print "=== Data Processing Pipelines ===")
(print)

;; Load required modules
(require 'core.seq)
(require 'core.threading)
(require 'core.functional)
; (require 'core.sequences) ; Not available yet

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
(print "- Sales data:" (length sales-data) "records")
(print "- Employee data:" (length employees) "records") 
(print "- Sensor data:" (length sensor-data) "readings")
(print)

;; === BASIC DATA EXTRACTION ===
(print "2. Basic Data Extraction")

;; Extract specific fields
(defn get-field [field] (fn [record] (get record field)))

(def product-names (map-list (get-field :product) sales-data))
(def employee-names (map-list (get-field :name) employees))

(print "Products:" product-names)
(print "Employees:" employee-names)
(print)

;; === FILTERING AND SELECTION ===
(print "3. Filtering and Selection")

;; High-value sales (price > 100)
(def high-value-sales 
  (filter-list (fn [sale] (> (:price sale) 100)) sales-data))

(print "High-value sales (>$100):")
(map-list (fn [sale] 
              (print "  " (:product sale) "-" (:price sale)))
            high-value-sales)

;; Senior employees (years > 5)
(def senior-employees
  (filter-list (fn [emp] (> (:years emp) 5)) employees))

(print "Senior employees (>5 years):")
(map-list (fn [emp]
              (print "  " (:name emp) "-" (:years emp) "years"))
            senior-employees)
(print)

;; === AGGREGATION AND CALCULATIONS ===
(print "4. Aggregation and Calculations")

;; Calculate revenue per sale
(defn calculate-revenue [sale]
  (assoc sale :revenue (* (:price sale) (:quantity sale))))

(def sales-with-revenue 
  (map-list calculate-revenue sales-data))

;; Total revenue
(def total-revenue
  (reduce-list + 0 
    (map-list (get-field :revenue) sales-with-revenue)))

(print "Total revenue: $" total-revenue)

;; Average salary by department
(defn filter-by-dept [dept]
  (filter-list (fn [emp] (= (:department emp) dept)) employees))

(defn average-salary [emps]
  (if (empty? emps)
    0
    (/ (reduce-list + 0 (map-list (get-field :salary) emps))
       (length emps))))

(def eng-avg (average-salary (filter-by-dept "Engineering")))
(def sales-avg (average-salary (filter-by-dept "Sales")))

(print "Average Engineering salary: $" eng-avg)
(print "Average Sales salary: $" sales-avg)
(print)

;; === GROUPING AND ANALYSIS ===
(print "5. Grouping and Analysis")

;; Group sales by region (simplified grouping)
(defn sales-by-region [region]
  (filter-list (fn [sale] (= (:region sale) region)) sales-data))

(def regions '("North" "South" "East" "West"))

(print "Sales by region:")
(map-list (fn [region]
              (let [region-sales (sales-by-region region)
                    count (length region-sales)]
                (print "  " region ":" count "sales")))
            regions)

;; Product popularity (count by product)
(defn count-product [product]
  (length (filter-list (fn [sale] (= (:product sale) product)) sales-data)))

(def unique-products (seq/distinct (map-list (get-field :product) sales-data)))

(print "Product popularity:")
(map-list (fn [product]
              (print "  " product ":" (count-product product) "sales"))
            unique-products)
(print)

;; === ADVANCED PIPELINES ===
(print "6. Advanced Processing Pipelines")

;; Complex data transformation pipeline
(defn analyze-sales-performance []
  (let [
    ;; Step 1: Add revenue calculation
    with-revenue (map-list calculate-revenue sales-data)
    
    ;; Step 2: Filter high-value transactions
    high-value (filter-list (fn [sale] (> (:revenue sale) 200)) with-revenue)
    
    ;; Step 3: Extract revenues
    revenues (map-list (get-field :revenue) high-value)
    
    ;; Step 4: Calculate statistics
    total (reduce-list + 0 revenues)
    count (length revenues)
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
    sensor-readings (filter-list (fn [reading] (= (:sensor reading) sensor-id)) sensor-data)
    temperatures (map-list (get-field :temperature) sensor-readings)
    humidities (map-list (get-field :humidity) sensor-readings)
  ]
    {:sensor sensor-id
     :readings (length sensor-readings)
     :avg-temp (/ (reduce-list + 0 temperatures) (length temperatures))
     :avg-humidity (/ (reduce-list + 0 humidities) (length humidities))}))

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
(def valid-sales (filter-list valid-sale? sales-data))
(def valid-employees (filter-list valid-employee? employees))

(print "Data validation:")
(print "  Valid sales:" (length valid-sales) "/" (length sales-data))
(print "  Valid employees:" (length valid-employees) "/" (length employees))
(print)

;; === REPORT GENERATION ===
(print "9. Report Generation")

(defn generate-sales-report []
  (print "=== SALES REPORT ===")
  (print "Total transactions:" (length sales-data))
  (print "Total revenue: $" total-revenue)
  (print "Average transaction value: $" (/ total-revenue (length sales-data)))
  (print)
  
  (print "Top products by quantity sold:")
  ;; This is simplified - real implementation would sort by quantity
  (map-list (fn [product]
                (let [sales (filter-list (fn [sale] (= (:product sale) product)) sales-data)
                      total-qty (reduce-list + 0 (map-list (get-field :quantity) sales))]
                  (print "  " product ":" total-qty "units")))
              unique-products)
  (print "=== END REPORT ==="))

(generate-sales-report)
(print)

;; === ADVANCED PATTERNS ===
(print "10. Advanced Processing Patterns")

;; Chain multiple transformations
(defn process-employee-data []
  (reduce-list + 0
    (map-list (get-field :salary)
      (filter-list (fn [emp] (= (:department emp) "Engineering"))
        (filter-list (fn [emp] (> (:years emp) 3)) employees)))))

(def eng-senior-total-salary (process-employee-data))
(print "Total salary of senior Engineers: $" eng-senior-total-salary)

;; Data enrichment
(defn enrich-sale-data [sale]
  (let [revenue (* (:price sale) (:quantity sale))
        category (if (> (:price sale) 100) "Premium" "Standard")]
    (assoc sale :revenue revenue :category category)))

(def enriched-sales (map-list enrich-sale-data sales-data))
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
(print "Next: Try example04-threading-macros.lisp for cleaner pipelines!")