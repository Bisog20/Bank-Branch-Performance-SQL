-- 05_window_functions.sql
-- Running totals, MoM change, moving average, and rankings.
USE BankPerformance;
GO

-- Query 1: YTD and cumulative revenue (one branch; change the name to explore others)
WITH Monthly AS (
    SELECT BranchID, MonthEnd, SUM(Revenue) AS Revenue
    FROM dbo.BranchPerformance
    GROUP BY BranchID, MonthEnd
)
SELECT
    b.BranchName,
    m.MonthEnd,
    m.Revenue,
    SUM(m.Revenue) OVER (
        PARTITION BY m.BranchID, YEAR(m.MonthEnd)
        ORDER BY m.MonthEnd
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RevenueYTD,
    SUM(m.Revenue) OVER (
        PARTITION BY m.BranchID
        ORDER BY m.MonthEnd
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RevenueCumulative
FROM Monthly m
JOIN dbo.Branch b ON m.BranchID = b.BranchID
WHERE b.BranchName = 'Ikeja'
ORDER BY m.MonthEnd;

-- Query 2: month-over-month change and 3-month moving average
WITH Monthly AS (
    SELECT BranchID, MonthEnd, SUM(Revenue) AS Revenue
    FROM dbo.BranchPerformance
    GROUP BY BranchID, MonthEnd
)
SELECT
    b.BranchName,
    m.MonthEnd,
    m.Revenue,
    LAG(m.Revenue) OVER (PARTITION BY m.BranchID ORDER BY m.MonthEnd) AS PrevMonthRevenue,
    CAST(100.0 * (m.Revenue - LAG(m.Revenue) OVER (PARTITION BY m.BranchID ORDER BY m.MonthEnd))
         / NULLIF(LAG(m.Revenue) OVER (PARTITION BY m.BranchID ORDER BY m.MonthEnd), 0)
         AS DECIMAL(6,2)) AS MoMChangePct,
    CAST(AVG(m.Revenue) OVER (
        PARTITION BY m.BranchID
        ORDER BY m.MonthEnd
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS DECIMAL(18,2)) AS MovingAvg3M
FROM Monthly m
JOIN dbo.Branch b ON m.BranchID = b.BranchID
WHERE b.BranchName = 'Ikeja'
ORDER BY m.MonthEnd;

-- Query 3: branch ranking for the latest month
WITH Monthly AS (
    SELECT BranchID, MonthEnd, SUM(Revenue) AS Revenue
    FROM dbo.BranchPerformance
    GROUP BY BranchID, MonthEnd
)
SELECT
    m.MonthEnd,
    b.BranchName,
    m.Revenue,
    RANK() OVER (PARTITION BY m.MonthEnd ORDER BY m.Revenue DESC) AS RevenueRank
FROM Monthly m
JOIN dbo.Branch b ON m.BranchID = b.BranchID
WHERE m.MonthEnd = '2025-12-31'
ORDER BY RevenueRank;

-- Query 4: top revenue product in each branch
WITH ProductRevenue AS (
    SELECT bp.BranchID, bp.ProductID, SUM(bp.Revenue) AS Revenue
    FROM dbo.BranchPerformance bp
    GROUP BY bp.BranchID, bp.ProductID
),
Ranked AS (
    SELECT
        BranchID,
        ProductID,
        Revenue,
        RANK() OVER (PARTITION BY BranchID ORDER BY Revenue DESC) AS ProductRank,
        CAST(100.0 * Revenue / SUM(Revenue) OVER (PARTITION BY BranchID) AS DECIMAL(5,2)) AS BranchSharePct
    FROM ProductRevenue
)
SELECT b.BranchName, p.ProductName, r.Revenue, r.BranchSharePct
FROM Ranked r
JOIN dbo.Branch  b ON r.BranchID  = b.BranchID
JOIN dbo.Product p ON r.ProductID = p.ProductID
WHERE r.ProductRank = 1
ORDER BY r.Revenue DESC;
