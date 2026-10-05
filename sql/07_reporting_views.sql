-- 07_reporting_views.sql
-- Reusable reporting layer for Power BI / Excel. CREATE OR ALTER needs SQL Server 2016 SP1+.
USE BankPerformance;
GO

CREATE OR ALTER VIEW dbo.vw_BranchScorecard AS
SELECT
    b.BranchID,
    b.BranchName,
    b.Region,
    SUM(bp.DepositAmount) AS TotalDeposits,
    SUM(bp.LoanAmount)    AS TotalLoans,
    SUM(bp.Revenue)       AS TotalRevenue,
    CAST(100.0 * SUM(bp.Revenue) / SUM(SUM(bp.Revenue)) OVER () AS DECIMAL(5,2)) AS RevenueSharePct,
    CAST(SUM(bp.LoanAmount) / NULLIF(SUM(bp.DepositAmount), 0) AS DECIMAL(6,3))  AS LoanToDepositRatio
FROM dbo.BranchPerformance bp
JOIN dbo.Branch b ON bp.BranchID = b.BranchID
GROUP BY b.BranchID, b.BranchName, b.Region;
GO

CREATE OR ALTER VIEW dbo.vw_MonthlyTargetVsActual AS
WITH Monthly AS (
    SELECT BranchID, MonthEnd, SUM(Revenue) AS Actual
    FROM dbo.BranchPerformance
    GROUP BY BranchID, MonthEnd
)
SELECT
    b.BranchName,
    b.Region,
    m.MonthEnd,
    YEAR(m.MonthEnd) AS ReportYear,
    m.Actual,
    t.RevenueTarget AS Target,
    m.Actual - t.RevenueTarget AS Variance,
    CAST(100.0 * m.Actual / NULLIF(t.RevenueTarget, 0) AS DECIMAL(6,2)) AS AchievementPct,
    CASE WHEN m.Actual >= t.RevenueTarget THEN 'Met' ELSE 'Missed' END AS Status,
    SUM(m.Actual) OVER (PARTITION BY m.BranchID, YEAR(m.MonthEnd)
                        ORDER BY m.MonthEnd
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ActualYTD,
    SUM(t.RevenueTarget) OVER (PARTITION BY m.BranchID, YEAR(m.MonthEnd)
                        ORDER BY m.MonthEnd
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TargetYTD,
    CAST(100.0 * (m.Actual - LAG(m.Actual) OVER (PARTITION BY m.BranchID ORDER BY m.MonthEnd))
         / NULLIF(LAG(m.Actual) OVER (PARTITION BY m.BranchID ORDER BY m.MonthEnd), 0)
         AS DECIMAL(6,2)) AS MoMChangePct
FROM Monthly m
JOIN dbo.BranchTarget t ON m.BranchID = t.BranchID AND m.MonthEnd = t.MonthEnd
JOIN dbo.Branch b       ON m.BranchID = b.BranchID;
GO

CREATE OR ALTER VIEW dbo.vw_ProductSummary AS
SELECT
    p.Category,
    p.ProductName,
    SUM(bp.DepositAmount) AS TotalDeposits,
    SUM(bp.LoanAmount)    AS TotalLoans,
    SUM(bp.Revenue)       AS TotalRevenue,
    CAST(100.0 * SUM(bp.Revenue) / SUM(SUM(bp.Revenue)) OVER () AS DECIMAL(5,2)) AS RevenueSharePct
FROM dbo.BranchPerformance bp
JOIN dbo.Product p ON bp.ProductID = p.ProductID
GROUP BY p.Category, p.ProductName;
GO

CREATE OR ALTER VIEW dbo.vw_BranchProductDetail AS
SELECT
    b.BranchName,
    b.Region,
    p.ProductName,
    p.Category,
    bp.MonthEnd,
    YEAR(bp.MonthEnd)  AS ReportYear,
    MONTH(bp.MonthEnd) AS ReportMonth,
    bp.DepositAmount,
    bp.LoanAmount,
    bp.Revenue
FROM dbo.BranchPerformance bp
JOIN dbo.Branch  b ON bp.BranchID  = b.BranchID
JOIN dbo.Product p ON bp.ProductID = p.ProductID;
GO

-- Verify: every view should reconcile to the same revenue total
SELECT 'vw_BranchScorecard'        AS ViewName, COUNT(*) AS TotalRows, SUM(TotalRevenue) AS RevenueCheck FROM dbo.vw_BranchScorecard
UNION ALL
SELECT 'vw_MonthlyTargetVsActual', COUNT(*), SUM(Actual)       FROM dbo.vw_MonthlyTargetVsActual
UNION ALL
SELECT 'vw_ProductSummary',        COUNT(*), SUM(TotalRevenue) FROM dbo.vw_ProductSummary
UNION ALL
SELECT 'vw_BranchProductDetail',   COUNT(*), SUM(Revenue)      FROM dbo.vw_BranchProductDetail;
