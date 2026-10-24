## 2026-10-24 - Get-ChildItem Pipeline Overhead vs Direct Loop
**Learning:** In PowerShell, pipelining `Get-ChildItem -Recurse | Where-Object` introduces significant overhead (up to 60-70% execution time increase) due to pipeline mechanics, especially on large file trees (700+ files). Furthermore, in a restricted Linux environment, `[System.IO.Directory]::EnumerateFiles` throws unrecoverable `UnauthorizedAccessException` on restricted system directories, whereas `Get-ChildItem -EA SilentlyContinue` correctly bypasses them.
**Action:** When scanning deep file structures where performance matters, prefer wrapping the `Get-ChildItem -EA SilentlyContinue` call in a `foreach ($f in ...) { if (...) }` loop rather than using `Where-Object`. Avoid `EnumerateFiles` if running in potentially restricted environments like `/tmp`.

## 2026-10-24 - ReadAllLines vs ReadAllText -split
**Learning:** `[System.IO.File]::ReadAllLines($path)` is about 15-20% slower than `[System.IO.File]::ReadAllText($path) -split "\r?\n"` when reading files line-by-line due to array allocations.
**Action:** When micro-optimizing file I/O where arrays of lines are needed, prefer the `ReadAllText -split` approach.

## 2026-10-24 - Cross-platform PowerShell execution fallback
**Learning:** Hardcoding `powershell.exe` alongside `$PSHOME` fails in Linux/CI environments where the binary is `pwsh`. Conversely, checking `$IsWindows` breaks in Windows PowerShell 5.1 because that automatic variable was only introduced in PowerShell Core 6.
**Action:** To safely fall back between modern and legacy PowerShell execution environments cross-platform, use `Get-Command` to test for `pwsh` availability (`$(if (Get-Command 'pwsh' -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell.exe' })`).
