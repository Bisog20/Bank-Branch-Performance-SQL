-- 02_load_data.sql
-- Loads synthetic sample data. Run ONCE only (re-running duplicates rows).
USE BankPerformance;
GO

INSERT INTO dbo.Branch (BranchName, Region, OpenDate) VALUES
('Lagos Island',   'South West',    '2010-03-15'),
('Ikeja',          'South West',    '2012-07-01'),
('Abuja Central',  'North Central', '2011-05-20'),
('Port Harcourt',  'South South',   '2013-09-10'),
('Kano',           'North West',    '2014-02-03'),
('Ibadan',         'South West',    '2015-06-18'),
('Enugu',          'South East',    '2016-11-25'),
('Kaduna',         'North West',    '2018-04-09');

INSERT INTO dbo.Product (ProductName, Category) VALUES
('Savings Account',        'Deposit'),
('Current Account',        'Deposit'),
('Fixed Deposit',          'Deposit'),
('Personal Loan',          'Loan'),
('SME Loan',               'Loan'),
('Card and Transfer Fees', 'Service');
GO

-- 24 months of performance data (Jan 2024 - Dec 2025)
;WITH Months AS (
    SELECT CAST('2024-01-31' AS DATE) AS MonthEnd, 1 AS MonthNo
    UNION ALL
    SELECT EOMONTH(DATEADD(MONTH, 1, MonthEnd)), MonthNo + 1
    FROM Months
    WHERE MonthNo < 24
)
INSERT INTO dbo.BranchPerformance
    (BranchID, ProductID, MonthEnd, DepositAmount, LoanAmount, Revenue)
SELECT
    b.BranchID,
    p.ProductID,
    m.MonthEnd,
    CASE WHEN p.Category = 'Deposit'
         THEN CAST(x.Base * x.Factor AS DECIMAL(18,2)) ELSE 0 END AS DepositAmount,
    CASE WHEN p.Category = 'Loan'
         THEN CAST(x.Base * x.Factor AS DECIMAL(18,2)) ELSE 0 END AS LoanAmount,
    CAST(x.Base * x.Factor * x.RevRate AS DECIMAL(18,2)) AS Revenue
FROM dbo.Branch b
CROSS JOIN dbo.Product p
CROSS JOIN Months m
CROSS APPLY (
    SELECT
        CASE p.ProductName
            WHEN 'Savings Account'        THEN 120000000.0
            WHEN 'Current Account'        THEN 200000000.0
            WHEN 'Fixed Deposit'          THEN 150000000.0
            WHEN 'Personal Loan'          THEN  90000000.0
            WHEN 'SME Loan'               THEN 140000000.0
            ELSE                               10000000.0
        END AS Base,
        (0.6 + b.BranchID * 0.15)
          * (1 + m.MonthNo * 0.01)
          * (0.85 + (ABS(CHECKSUM(b.BranchID, p.ProductID, m.MonthNo)) % 300) / 1000.0) AS Factor,
        CASE p.Category
            WHEN 'Deposit' THEN 0.010
            WHEN 'Loan'    THEN 0.018
            ELSE                0.300
        END AS RevRate
) x;
GO

-- Monthly revenue targets (92%-112% of actual; a sample-data shortcut)
INSERT INTO dbo.BranchTarget (BranchID, MonthEnd, RevenueTarget)
SELECT
    BranchID,
    MonthEnd,
    CAST(SUM(Revenue) * (0.92 + (ABS(CHECKSUM(BranchID, MonthEnd)) % 200) / 1000.0)
         AS DECIMAL(18,2))
FROM dbo.BranchPerformance
GROUP BY BranchID, MonthEnd;
GO

-- Verify: expect 8, 6, 1152, 192
SELECT 'Branch' AS TableName, COUNT(*) AS TotalRows FROM dbo.Branch
UNION ALL SELECT 'Product',           COUNT(*) FROM dbo.Product
UNION ALL SELECT 'BranchPerformance', COUNT(*) FROM dbo.BranchPerformance
UNION ALL SELECT 'BranchTarget',      COUNT(*) FROM dbo.BranchTarget;
