# Strategic-Plan-Review
Analysis Review
# 📚 Central Library System: Strategic Analysis & Automation

![SQL](https://img.shields.io/badge/Language-SQL-orange) ![MySQL](https://img.shields.io/badge/Database-MySQL-blue) ![Status](https://img.shields.io/badge/Status-Completed-green)

**Author:** Mayowa Adeboye  
**Role:** Strategy Analyst  
**Date:** January 2026  

## 📌 Project Background
The Central Library System was operating with inefficient manual processes, leading to revenue leakage from uncollected fines, long wait times for book returns, and a lack of visibility into branch performance. 

This project involved building a relational database from scratch to digitize operations, automate workflows, and provide data-driven insights for the Q1 2026 strategic plan.

## 🎯 Project Objective
* **Database Design:** Constructed a normalized relational schema connecting 6 distinct datasets.
* **Automation Engineering:** Implemented SQL **Triggers** and **Stored Procedures** to eliminate manual data entry errors.
* **Operational Analysis:** Solved 7 critical business problems ranging from financial recovery to staff productivity.
* **Strategic Insight:** Delivered an executive roadmap for inventory optimization and risk management.

## 📂 Datasets
The database was built using the following raw CSV files:
* `Books.csv`: Inventory data (ISBN, titles, rental prices).
* `Branch.csv`: Branch network details and managers.
* `Emp.csv`: Employee roster, salaries, and positions.
* `IS.csv`: Historical record of issued books.
* `Mem.csv`: Member registry.
* `Rs.csv`: Return status logs (including "Damaged" status).

## 🛠️ Data Engineering (SQL Architecture)
The database architecture was built in **MySQL** using a structured workflow:

1.  **Schema Normalization:** Designed a schema with Primary Keys (`isbn`, `emp_id`) and Foreign Keys to ensure data integrity.
2.  **Type Standardization:** Converted raw text fields into `VARCHAR`, `DATE`, and `DECIMAL` formats.
3.  **Automation Logic:**
    * **Stored Procedure (`issue_book`):** Validates book availability before processing transactions to prevent double-booking.
    * **Trigger (`Update_Book_Status`):** Automatically flips book status from 'No' to 'Yes' immediately upon return.

---

## 🚀 Key Findings (The 7 Problems Solved)

### 1. Financial Recovery (Overdue Crisis)
**Objective:** Identify significant revenue leaks from overdue books.  
**Solution:** Generated a dynamic report using `DATEDIFF` to calculate outstanding fines ($0.50/day).  
**Impact:** Automated billing list generated for immediate recovery.

### 2. Operational Efficiency (Instant Returns)
**Objective:** Eliminate return processing queues.  
**Solution:** Implemented a Database Trigger.  
**Impact:** Reduced manual status update time to **zero**.

### 3. Branch Performance Scorecard
**Objective:** Identify profitable vs. busy branches.  
**Solution:** A complex query aggregating Revenue, Issues, and Returns per branch.  
**Insight:** Identified the top-performing branch for Q1 budget allocation.

### 4. Member Engagement
**Objective:** Stop wasting marketing budget on inactive members.  
**Solution:** Segmented users into **Active** (last 60 days) vs. **Inactive**.  
**Action:** Marketing campaigns now target specific "Inactive" segments.

### 5. Staff Productivity Leaderboard
**Objective:** Replace subjective reviews with data.  
**Solution:** Ranked employees by total transaction volume.  
**Outcome:** "Employee of the Month" is now decided by objective metrics.

### 6. Risk Management (Damaged Books)
**Objective:** Identify members costing the library money.  
**Solution:** Query identified "Serial Offenders" (Members returning >2 damaged books).  
**Action:** Flagged accounts for automated suspension.

### 7. System Integrity (The Smart Guard)
**Objective:** Prevent human error (issuing unavailable books).  
**Solution:** The `issue_book` stored procedure creates a logic gate.  
**Result:** **100% prevention** of double-booking errors.

---

## 📸 Visual Analysis
*(See `/04_Screenshots` folder for full outputs)*

**1. The Branch Performance Scorecard (Problem 3)** ![Strategic-Plan-Review](Problem%202.png)

---

## 💡 Recommendations
1.  **Inventory Strategy:** Shift procurement budgets toward high-velocity categories (e.g., Sci-Fi) based on rental frequency data.
2.  **Automated Policing:** Implement a system lock for any member with >$20 in unpaid fines or repeated damage history.
3.  **Expansion:** Roll out this SQL toolkit to the remaining 3 regional libraries in Q2 2026.

## 💻 How to Use
1.  **Clone the Repo:** `git clone https://github.com/yourusername/Library-System-SQL-P3.git`
2.  **Import Database:** Import `Library_Project_Final_Backup.sql` into MySQL Workbench.
3.  **Run Analysis:** Execute queries in `Library_Project_Queries.sql`.

## 📞 Contact
**Mayowa Adeboye** 📧 Email: Adeboyemayowa86@gmail.com  
🔗 [LinkedIn Profile](https://www.linkedin.com/in/mayowaadeboye)
## Repository Link
[View Project on GitHub]( https://github.com/MayowaDATA/Strategic-Plan-Review)
