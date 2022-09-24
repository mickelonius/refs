## Test data
```python
import numpy as np
import pandas as pd
df = pd.DataFrame({
   "date": pd.date_range(start="2021-11-20", periods=100, freq="D"),
   "class": ["A","B","C","D"] * 25,
   "amount": np.random.randint(10, 100, size=100)
})
df.head()
```
## Convert datetimes to quarters, etc.
```python
df["month"] = df["date"].dt.to_period("M")
df["quarter"] = df["date"].dt.to_period("Q")
df.head()
```

## Category dtype
```python
df["class_category"] = df["class"].astype("category")
df.memory_usage()
```