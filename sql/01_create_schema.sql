-- 01_create_schema.sql
-- Creates the BankPerformance database and its four tables.
CREATE DATABASE BankPerformance;
GO

USE BankPerformance;
GO

-- Dimension: branches
CREATE TABLE dbo.Branch (
    BranchID     INT IDENTITY(1,1) PRIMARY KEY,
    BranchName   VARCHAR(100) NOT NULL,
    Region       VARCHAR(50)  NOT NULL,
    OpenDate     DATE         NOT NULL
);

-- Dimension: products
CREATE TABLE dbo.Product (
    ProductID    INT IDENTITY(1,1) PRIMARY KEY,
    ProductName  VARCHAR(100) NOT NULL,
    Category     VARCHAR(50)  NOT NULL   -- Deposit, Loan, or Service
);

-- Fact: monthly performance per branch and product
CREATE TABLE dbo.BranchPerformance (
    PerformanceID  INT IDENTITY(1,1) PRIMARY KEY,
    BranchID       INT           NOT NULL REFERENCES dbo.Branch(BranchID),
    ProductID      INT           NOT NULL REFERENCES dbo.Product(ProductID),
    MonthEnd       DATE          NOT NULL,
    DepositAmount  DECIMAL(18,2) NOT NULL DEFAULT 0,
    LoanAmount     DECIMAL(18,2) NOT NULL DEFAULT 0,
    Revenue        DECIMAL(18,2) NOT NULL DEFAULT 0
);

-- Targets: monthly revenue target per branch
CREATE TABLE dbo.BranchTarget (
    TargetID       INT IDENTITY(1,1) PRIMARY KEY,
    BranchID       INT           NOT NULL REFERENCES dbo.Branch(BranchID),
    MonthEnd       DATE          NOT NULL,
    RevenueTarget  DECIMAL(18,2) NOT NULL
);
GO

-- Verify: expect Branch, BranchPerformance, BranchTarget, Product
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
