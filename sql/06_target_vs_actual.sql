-- 06_target_vs_actual.sql
-- Variance, achievement, and status against monthly revenue targets.
USE BankPerformance;
GO

-- Query 1: monthly target vs actual with YTD (one branch)
WITH Monthly AS (
    SELECT BranchID, MonthEnd, SUM(Revenue) AS Actual
    FROM dbo.BranchPerformance
    GROUP BY BranchID, MonthEnd
),
TvA AS (
    SELECT m.BranchID, m.MonthEnd, m.Actual, t.RevenueTarget AS Target
    FROM Monthly m
    JOIN dbo.BranchTarget t ON m.BranchID = t.BranchID AND m.MonthEnd = t.MonthEnd
)
SELECT
    b.BranchName,
    x.MonthEnd,
    x.Actual,
    x.Target,
    x.Actual - x.Target AS Variance,
    CAST(100.0 * (x.Actual - x.Target) / NULLIF(x.Target, 0) AS DECIMAL(6,2)) AS VariancePct,
    CASE WHEN x.Actual >= x.Target THEN 'Met' ELSE 'Missed' END AS Status,
    SUM(x.Actual) OVER (PARTITION BY x.BranchID, YEAR(x.MonthEnd)
                        ORDER BY x.MonthEnd
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ActualYTD,
    SUM(x.Target) OVER (PARTITION BY x.BranchID, YEAR(x.MonthEnd)
                        ORDER BY x.MonthEnd
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TargetYTD
FROM TvA x
JOIN dbo.Branch b ON x.BranchID = b.BranchID
WHERE b.BranchName = 'Ikeja'
ORDER BY x.MonthEnd;

-- Query 2: full-year 2025 achievement by branch
WITH Monthly AS (
    SELECT BranchID, MonthEnd, SUM(Revenue) AS Actual
    FROM dbo.BranchPerformance
    GROUP BY BranchID, MonthEnd
),
TvA AS (
    SELECT m.BranchID, m.MonthEnd, m.Actual, t.RevenueTarget AS Target
    FROM Monthly m
    JOIN dbo.BranchTarget t ON m.BranchID = t.BranchID AND m.MonthEnd = t.MonthEnd
)
SELECT
    b.BranchName,
    SUM(x.Actual) AS Actual2025,
    SUM(x.Target) AS Target2025,
    SUM(x.Actual) - SUM(x.Target) AS Variance,
    CAST(100.0 * SUM(x.Actual) / NULLIF(SUM(x.Target), 0) AS DECIMAL(6,2)) AS AchievementPct,
    SUM(CASE WHEN x.Actual >= x.Target THEN 1 ELSE 0 END) AS MonthsMet,
    SUM(CASE WHEN x.Actual <  x.Target THEN 1 ELSE 0 END) AS MonthsMissed
FROM TvA x
JOIN dbo.Branch b ON x.BranchID = b.BranchID
WHERE YEAR(x.MonthEnd) = 2025
GROUP BY b.BranchName
ORDER BY AchievementPct DESC;

-- Query 3: latest month ranked by achievement
WITH Monthly AS (
    SELECT BranchID, MonthEnd, SUM(Revenue) AS Actual
    FROM dbo.BranchPerformance
    GROUP BY BranchID, MonthEnd
),
TvA AS (
    SELECT m.BranchID, m.MonthEnd, m.Actual, t.RevenueTarget AS Target
    FROM Monthly m
    JOIN dbo.BranchTarget t ON m.BranchID = t.BranchID AND m.MonthEnd = t.MonthEnd
)
SELECT
    b.BranchName,
    x.Actual,
    x.Target,
    CAST(100.0 * x.Actual / NULLIF(x.Target, 0) AS DECIMAL(6,2)) AS AchievementPct,
    RANK() OVER (ORDER BY x.Actual / NULLIF(x.Target, 0) DESC) AS AchievementRank,
    CASE
        WHEN x.Actual >= x.Target * 1.05 THEN 'Exceeded (5%+)'
        WHEN x.Actual >= x.Target        THEN 'Met'
        WHEN x.Actual >= x.Target * 0.95 THEN 'Slightly below'
        ELSE 'Well below (5%+ short)'
    END AS Status
FROM TvA x
JOIN dbo.Branch b ON x.BranchID = b.BranchID
WHERE x.MonthEnd = '2025-12-31'
ORDER BY AchievementRank;

-- Query 4: 10 worst shortfalls across all branch-months
WITH Monthly AS (
    SELECT BranchID, MonthEnd, SUM(Revenue) AS Actual
    FROM dbo.BranchPerformance
    GROUP BY BranchID, MonthEnd
),
TvA AS (
    SELECT m.BranchID, m.MonthEnd, m.Actual, t.RevenueTarget AS Target
    FROM Monthly m
    JOIN dbo.BranchTarget t ON m.BranchID = t.BranchID AND m.MonthEnd = t.MonthEnd
)
SELECT TOP 10
    b.BranchName,
    x.MonthEnd,
    x.Actual,
    x.Target,
    x.Actual - x.Target AS Shortfall,
    CAST(100.0 * (x.Actual - x.Target) / NULLIF(x.Target, 0) AS DECIMAL(6,2)) AS VariancePct
FROM TvA x
JOIN dbo.Branch b ON x.BranchID = b.BranchID
WHERE x.Actual < x.Target
ORDER BY VariancePct ASC;
