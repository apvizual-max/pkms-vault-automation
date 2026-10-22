BeforeAll {
    # watch.ps1 executes logic when dot-sourced.
    # To test the pure function Fmt-Durata isolated from execution logic, we extract it via AST.
    $scriptPath = Join-Path $PSScriptRoot "watch.ps1"
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$null, [ref]$null)
    $functionAst = $ast.Find({
        param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Fmt-Durata'
    }, $true)

    if (-not $functionAst) {
        throw "Could not find function Fmt-Durata in $scriptPath"
    }

    Invoke-Expression $functionAst.Extent.Text
}

Describe "Fmt-Durata" {
    It "formats values under 60 seconds correctly" {
        Fmt-Durata -sec 0 | Should -Be "0 s"
        Fmt-Durata -sec 15 | Should -Be "15 s"
        Fmt-Durata -sec 45.4 | Should -Be "45 s"
    }

    It "rounds values to the nearest second" {
        Fmt-Durata -sec 45.4 | Should -Be "45 s"
        Fmt-Durata -sec 45.5 | Should -Be "46 s"
    }

    It "formats exactly 60 seconds correctly" {
        Fmt-Durata -sec 60 | Should -Be "1 m 0 s"
        Fmt-Durata -sec 59.6 | Should -Be "1 m 0 s"
    }

    It "formats values over 60 seconds correctly" {
        Fmt-Durata -sec 61 | Should -Be "1 m 1 s"
        Fmt-Durata -sec 125 | Should -Be "2 m 5 s"
        Fmt-Durata -sec 180 | Should -Be "3 m 0 s"
        Fmt-Durata -sec 3605 | Should -Be "60 m 5 s"
    }
}
