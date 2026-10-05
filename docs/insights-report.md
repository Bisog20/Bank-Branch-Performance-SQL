# Branch and Product Performance Review (Jan 2024 to Dec 2025)

*Analysis built in T-SQL (SQL Server). Scripts are in the [`sql/`](../sql) folder. All data is synthetic; see the limitations section.*

## 1. Headline

Across 8 branches and 24 months, the bank mobilised **₦129.16bn in deposits**, disbursed **₦61.81bn in loans**, and earned **₦3.22bn in revenue**. The overall loan-to-deposit ratio is **0.48**.

In 2025, the bank earned ₦1.698bn against a target of ₦1.726bn: **98.4% achievement**, a shortfall of ₦28.3m. **No branch reached its full-year target**, and branches met their monthly target in only 43 of 96 branch-months (45%).

## 2. Branch performance

| Rank | Branch | Region | Revenue | Share |
|---|---|---|---|---|
| 1 | Kaduna | North West | ₦551.0m | 17.1% |
| 2 | Enugu | South East | ₦487.0m | 15.1% |
| 3 | Ibadan | South West | ₦458.7m | 14.3% |
| 4 | Kano | North West | ₦431.8m | 13.4% |
| 5 | Port Harcourt | South South | ₦400.7m | 12.5% |
| 6 | Abuja Central | North Central | ₦365.4m | 11.4% |
| 7 | Ikeja | South West | ₦297.4m | 9.2% |
| 8 | Lagos Island | South West | ₦226.3m | 7.0% |

- The top three branches generate **46.5%** of revenue. The bottom two (Ikeja and Lagos Island) generate 16.3%.
- Kaduna earns about 2.4 times what Lagos Island earns.
- The South West region is split: Ibadan ranks 3rd while Ikeja and Lagos Island rank 7th and 8th.

## 3. Product mix

| Category | Revenue | Share |
|---|---|---|
| Deposit products | ₦1,291.6m | 40.1% |
| Loan products | ₦1,112.6m | 34.6% |
| Card and transfer fees | ₦814.0m | 25.3% |

- **Fees are the single largest revenue line** at 25.3%, ahead of every individual deposit or loan product.
- **SME Loans are the top lending product** (₦676.1m, 21.0%), earning about 1.5 times as much as Personal Loans (₦436.5m).
- **Current Accounts lead on deposits** (₦549.8m), ahead of Fixed Deposits (₦407.7m) and Savings (₦334.1m).

## 4. Lending efficiency (loan-to-deposit ratio)

Most branches sit in a tight band of 0.48 to 0.51, but two stand out:

- **Kaduna: 0.404.** It holds the most deposits (₦24.2bn) but lends proportionally the least. At the 0.51 ratio most peers reach, Kaduna would have disbursed about ₦2.6bn more in loans.
- **Lagos Island: 0.427.** At 0.51, the gap would be about ₦0.8bn.

Kaduna is the revenue leader, so the likely upside there is unused deposit capacity rather than a performance problem.

## 5. Target performance (2025)

| Branch | Actual | Target | Achievement | Months met |
|---|---|---|---|---|
| Kaduna | ₦290.1m | ₦290.5m | 99.89% | 8 of 12 |
| Port Harcourt | ₦211.2m | ₦212.2m | 99.49% | 6 of 12 |
| Lagos Island | ₦118.2m | ₦119.8m | 98.73% | 5 of 12 |
| Abuja Central | ₦192.5m | ₦195.1m | 98.68% | 5 of 12 |
| Ibadan | ₦241.7m | ₦246.9m | 97.90% | 5 of 12 |
| Ikeja | ₦157.3m | ₦160.8m | 97.81% | 5 of 12 |
| Enugu | ₦259.3m | ₦266.6m | 97.27% | 4 of 12 |
| Kano | ₦227.5m | ₦234.3m | 97.11% | 5 of 12 |

- **Enugu and Kano have the largest shortfalls** (₦7.3m and ₦6.8m), together about **50% of the bank's total shortfall**.
- Enugu met target in only 4 of 12 months, the weakest consistency of any branch.
- The misses are small in size (every branch is within 3% of target) but widespread.

## 6. Recommendations

1. **Review lending at Kaduna and Lagos Island.** Their loan-to-deposit ratios (0.40 and 0.43) trail a peer level near 0.51. Investigate whether the cause is weak loan demand, tight credit criteria, or pipeline gaps.
2. **Prioritise Enugu and Kano for target recovery.** They hold half the bank's 2025 shortfall, so fixing them closes most of the gap.
3. **Protect and grow fee income and SME lending.** They are the two largest revenue lines (46% combined), so a small improvement there moves the total most.
4. **Check target-setting.** Missing 55% of branch-months while every branch lands within 3% of target suggests targets may be set slightly too high, or the process lacks a mid-year adjustment.

## 7. Assumptions and limitations

- **The data is synthetic.** Branch rankings come from how the sample was generated (branch size rises with branch ID) and do not reflect real branches.
- **Revenue rates are built in.** Revenue was generated as a fixed percentage of volume per category plus a fee base, so the product shares in section 3 reflect those assumptions.
- **Targets were generated, not budgeted.** They were set at 92% to 112% of actual revenue, so the target pattern in section 5 comes from the generation method. With real data, actual budgets would be used.
- **Deposits and loans are treated as monthly flows**, not month-end balances, so the loan-to-deposit ratio is a flow ratio. A balance-sheet ratio would use outstanding balances.
- **Achievement is total actual divided by total target**, not an average of monthly percentages, so larger months carry more weight.

The value of this project is the method: the schema design, quality checks, window-function analysis, and reporting views are reusable on real branch data.
