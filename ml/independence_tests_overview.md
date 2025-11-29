
# Independence Tests for Nonlinear and Nonmonotonic Relationships

This document summarizes a variety of independence tests that are robust to nonlinear and nonmonotonic relationships, including descriptions and a comparison table.

---

## 📌 Tests Overview

### 1. **Maximal Information Coefficient (MIC)**
- **Detects:** General nonlinear and nonmonotonic dependence
- **Pros:** High detection power for various relationship types
- **Cons:** Computationally intensive
- **Library:** `minepy`

### 2. **Hilbert-Schmidt Independence Criterion (HSIC)**
- **Detects:** Any statistical dependence via kernels
- **Pros:** Works well for both linear and nonlinear relationships
- **Cons:** Sensitive to kernel choices
- **Library:** `hyppo`, `dcor`

### 3. **Distance Correlation (dCor)**
- **Detects:** Any dependence structure
- **Pros:** Zero iff independence, multivariate support
- **Cons:** Slightly less interpretable than Pearson
- **Library:** `dcor`

### 4. **Mutual Information (MI)**
- **Detects:** General dependence, including nonmonotonic
- **Pros:** Informational theoretic, intuitive
- **Cons:** Estimation sensitive to method
- **Library:** `sklearn`, `npeet`

### 5. **Randomized Dependence Coefficient (RDC)**
- **Detects:** Nonlinear and nonmonotonic relationships
- **Pros:** Fast, works on high-dimensional inputs
- **Cons:** Random projections can add noise
- **Library:** `rdc` (or approximated)

### 6. **Spearman Rank Correlation**
- **Detects:** Monotonic relationships
- **Pros:** Simple and widely available
- **Cons:** Misses nonmonotonic structure
- **Library:** `scipy`

### 7. **Pearson Correlation**
- **Detects:** Linear relationships only
- **Pros:** Simple, interpretable
- **Cons:** Poor for nonlinear or nonmonotonic

---

## 📊 Comparison Table

| Test                        | Nonlinear | Nonmonotonic | Multivariate | Conditional |
|-----------------------------|-----------|---------------|---------------|--------------|
| MIC / MICe                  | ✅        | ✅            | 🚫            | 🚫           |
| HSIC                        | ✅        | ✅            | ✅            | ❌ (but KCI does) |
| Distance Correlation        | ✅        | ✅            | ✅            | 🚫           |
| Mutual Information (KNN)    | ✅        | ✅            | ✅            | ✅ (via conditional MI) |
| RDC                         | ✅        | ✅            | ✅            | 🚫           |
| Copula-based Tests          | ✅        | ✅            | ✅            | ✅           |
| KCIT / KCI                  | ✅        | ✅            | ✅            | ✅           |
| Lancaster Test              | ✅        | ✅            | ✅            | ✅           |
| Hoeffding’s D               | ✅        | ✅            | 🚫            | 🚫           |

---
