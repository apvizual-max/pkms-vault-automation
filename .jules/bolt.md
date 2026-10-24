
## $(date +%Y-%m-%d) - PowerShell Pipeline vs Foreach Loops Overhead
**Learning:** In PowerShell, using idiomatic pipelines like `Get-ChildItem ... | Where-Object { ... }` or `| Measure-Object Length -Sum` introduces massive overhead because each object in the pipeline incurs significant processing time.
**Action:** When working on performance-critical operations involving file system traversals, always replace `Where-Object` and `Measure-Object` pipelines with traditional `foreach ($item in ...) { if (...) { ... } }` loops. This can yield dramatic performance improvements (e.g., executing in ~400ms instead of ~1200ms) without changing behavior. Ensure size sums are accumulated in an `[int64]` variable to prevent overflow on large collections.
