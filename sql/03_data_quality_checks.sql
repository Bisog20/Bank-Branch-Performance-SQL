-- 03_data_quality_checks.sql
-- Run each check separately. Checks 1-5 should return 0 rows / 0 counts.
USE BankPerformance;
GO

-- Check 1: duplicate branch/product/month records
SELECT BranchID, ProductID, MonthEnd, COUNT(*) AS Occurrences
FROM dbo.BranchPerformance
GROUP BY BranchID, ProductID, MonthEnd
HAVING COUNT(*) > 1;

-- Check 2: every branch has 6 products x 24 months = 144 rows
SELECT BranchID, COUNT(*) AS RowsPerBranch
FROM dbo.BranchPerformance
GROUP BY BranchID
HAVING COUNT(*) <> 144;

-- Check 3: negative or zero values
SELECT COUNT(*) AS BadRows
FROM dbo.BranchPerformance
WHERE Revenue <= 0 OR DepositAmount < 0 OR LoanAmount < 0;

-- Check 4: orphan records
SELECT COUNT(*) AS OrphanRows
FROM dbo.BranchPerformance bp
LEFT JOIN dbo.Branch  b ON bp.BranchID  = b.BranchID
LEFT JOIN dbo.Product p ON bp.ProductID = p.ProductID
WHERE b.BranchID IS NULL OR p.ProductID IS NULL;

-- Check 5: every branch-month has a target
SELECT DISTINCT bp.BranchID, bp.MonthEnd
FROM dbo.BranchPerformance bp
LEFT JOIN dbo.BranchTarget t
       ON bp.BranchID = t.BranchID AND bp.MonthEnd = t.MonthEnd
WHERE t.TargetID IS NULL;

-- Check 6: date range and data profile
SELECT
    MIN(MonthEnd)            AS FirstMonth,
    MAX(MonthEnd)            AS LastMonth,
    COUNT(DISTINCT MonthEnd) AS DistinctMonths,
    SUM(DepositAmount)       AS TotalDeposits,
    SUM(LoanAmount)          AS TotalLoans,
    SUM(Revenue)             AS TotalRevenue
FROM dbo.BranchPerformance;
