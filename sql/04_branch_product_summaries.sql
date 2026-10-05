-- 04_branch_product_summaries.sql
-- Aggregations answering: revenue by branch/product, loan-to-deposit ratio, YoY growth.
-- Note: deposits and loans are treated as monthly flows, so summing is valid.
USE BankPerformance;
GO

-- Query 1: branch scorecard
SELECT
    b.BranchName,
    b.Region,
    SUM(bp.DepositAmount) AS TotalDeposits,
    SUM(bp.LoanAmount)    AS TotalLoans,
    SUM(bp.Revenue)       AS TotalRevenue,
    CAST(100.0 * SUM(bp.Revenue) / SUM(SUM(bp.Revenue)) OVER () AS DECIMAL(5,2)) AS RevenueSharePct,
    CAST(SUM(bp.LoanAmount) / NULLIF(SUM(bp.DepositAmount), 0) AS DECIMAL(6,3))  AS LoanToDepositRatio
FROM dbo.BranchPerformance bp
JOIN dbo.Branch b ON bp.BranchID = b.BranchID
GROUP BY b.BranchName, b.Region
ORDER BY TotalRevenue DESC;

-- Query 2: product performance
SELECT
    p.Category,
    p.ProductName,
    SUM(bp.DepositAmount) AS TotalDeposits,
    SUM(bp.LoanAmount)    AS TotalLoans,
    SUM(bp.Revenue)       AS TotalRevenue,
    CAST(100.0 * SUM(bp.Revenue) / SUM(SUM(bp.Revenue)) OVER () AS DECIMAL(5,2)) AS RevenueSharePct
FROM dbo.BranchPerformance bp
JOIN dbo.Product p ON bp.ProductID = p.ProductID
GROUP BY p.Category, p.ProductName
ORDER BY TotalRevenue DESC;

-- Query 3: branch x product revenue matrix
SELECT
    b.BranchName,
    SUM(CASE WHEN p.ProductName = 'Savings Account'        THEN bp.Revenue ELSE 0 END) AS Savings,
    SUM(CASE WHEN p.ProductName = 'Current Account'        THEN bp.Revenue ELSE 0 END) AS CurrentAcct,
    SUM(CASE WHEN p.ProductName = 'Fixed Deposit'          THEN bp.Revenue ELSE 0 END) AS FixedDeposit,
    SUM(CASE WHEN p.ProductName = 'Personal Loan'          THEN bp.Revenue ELSE 0 END) AS PersonalLoan,
    SUM(CASE WHEN p.ProductName = 'SME Loan'               THEN bp.Revenue ELSE 0 END) AS SMELoan,
    SUM(CASE WHEN p.ProductName = 'Card and Transfer Fees' THEN bp.Revenue ELSE 0 END) AS Fees,
    SUM(bp.Revenue) AS TotalRevenue
FROM dbo.BranchPerformance bp
JOIN dbo.Branch  b ON bp.BranchID  = b.BranchID
JOIN dbo.Product p ON bp.ProductID = p.ProductID
GROUP BY b.BranchName
ORDER BY TotalRevenue DESC;

-- Query 4: year-over-year revenue growth by branch
SELECT
    b.BranchName,
    SUM(CASE WHEN YEAR(bp.MonthEnd) = 2024 THEN bp.Revenue ELSE 0 END) AS Revenue2024,
    SUM(CASE WHEN YEAR(bp.MonthEnd) = 2025 THEN bp.Revenue ELSE 0 END) AS Revenue2025,
    CAST(100.0 * (
        SUM(CASE WHEN YEAR(bp.MonthEnd) = 2025 THEN bp.Revenue ELSE 0 END)
      - SUM(CASE WHEN YEAR(bp.MonthEnd) = 2024 THEN bp.Revenue ELSE 0 END)
    ) / NULLIF(SUM(CASE WHEN YEAR(bp.MonthEnd) = 2024 THEN bp.Revenue ELSE 0 END), 0)
    AS DECIMAL(6,2)) AS GrowthPct
FROM dbo.BranchPerformance bp
JOIN dbo.Branch b ON bp.BranchID = b.BranchID
GROUP BY b.BranchName
ORDER BY GrowthPct DESC;
