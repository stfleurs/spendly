# Spendly Ledger Governance

This document defines the immutable architectural rules for the Spendly financial ledger. All developers and AI assistants MUST adhere to these rules to ensure data integrity and scalability.

## 1. Atomic Singularities (Write-Batch Only)
- **Rule**: ALL Firestore mutations (add, update, set, delete) MUST occur within an atomic `WriteBatch` or `Transaction`.
- **Forbidden**: Standalone calls like `_collection.add()`, `doc().update()`, etc., are strictly prohibited in repository classes.
- **Rationale**: Prevents partial writes, race conditions, and duplicate transaction hazards.

## 2. Integer-Safe Accounting
- **Rule**: Never use floating-point numbers (`double`) for money math. All amounts must be stored and manipulated as `int` (cents/smallest unit).
- **Rule**: Exchange rates must use **Scaled Integer Math**.
  - Rate Scale: `1,000,000`
  - Formula: `baseAmount = (amount * (rate * 1,000,000).round()) ~/ 1,000,000`
- **Rationale**: Eliminates rounding drift and ensures deterministic reconciliation across all platforms.

## 3. Zero-Read Write Paths
- **Rule**: Transaction write operations MUST be optimized for O(1) performance.
- **Rule**: NEVER perform O(N) transaction scans (e.g., `_collection.where('accountId', ...).get()`) during a write or validation path.
- **Rule**: Validate against account snapshots (`currentBalance`).
- **Rationale**: Ensures the system remains fast and Firestore costs remain predictable as users grow their transaction history.

## 4. Immutable Normalized Truth
- **Rule**: Once a transaction is written, its `amountInBaseCurrency` and `exchangeRate` are immutable historical facts.
- **Rule**: Historical reports MUST NOT be recalculated using current exchange rates.
- **Rationale**: Protects audit trails and prevents "Report Drift."

## 5. Namespaced Monthly Aggregates
- **Rule**: The `currencyBreakdown` in `MonthlySummary` must be namespaced by transaction type.
  - Format: `income.CURRENCY` or `expense.CURRENCY`
- **Rationale**: Prevents mixing of cash flows in raw-currency metadata, ensuring clear auditability.

## 6. Audit Metadata Requirement
- **Rule**: Every cross-currency transaction must store:
  - `originalAmount` & `originalCurrency`
  - `baseCurrency` & `amountInBaseCurrency`
  - `exchangeRate`, `scaledRate`, & `rateScale`
  - `rateSource`
- **Rationale**: Provides a complete forensic trail for every currency conversion.
