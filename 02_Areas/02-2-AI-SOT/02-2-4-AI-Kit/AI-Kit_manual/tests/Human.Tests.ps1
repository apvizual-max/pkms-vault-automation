BeforeAll {
    $scriptPath = "$PSScriptRoot/../align-index.ps1"

    # We dynamically extract the function using regex to test the actual code in the file
    $content = Get-Content -Path $scriptPath -Raw
    $functionRegex = '(?s)function Human\(\$b\) \{.*?\r?\n\}'
    if ($content -match $functionRegex) {
        $functionDefinition = $matches[0]
        Invoke-Expression $functionDefinition
    } else {
        throw "Could not find 'function Human' in $scriptPath"
    }
}

Describe "Human Byte Formatter Function Tests" {
    Context "when formatting bytes (under 1KB)" {
        It "should format 0 B correctly" {
            Human 0 | Should -Be "0 B"
        }
        It "should format 500 B correctly" {
            Human 500 | Should -Be "500 B"
        }
        It "should format 1023 B correctly (boundary just below 1KB)" {
            Human 1023 | Should -Be "1023 B"
        }
    }

    Context "when formatting kilobytes (1KB to just under 1MB)" {
        It "should format exactly 1 KB (1024 bytes)" {
            Human 1024 | Should -Be "1 KB"
        }
        It "should round to nearest KB" {
            Human 1500 | Should -Be "1 KB"
            Human 1600 | Should -Be "2 KB"
        }
        It "should format boundary just below 1MB" {
            Human 1048575 | Should -Be "1,024 KB"
        }
    }

    Context "when formatting megabytes (1MB to just under 1GB)" {
        It "should format exactly 1 MB (1048576 bytes)" {
            Human 1048576 | Should -Be "1 MB"
        }
        It "should round to nearest MB" {
            Human 1572864 | Should -Be "2 MB"
            Human 1600000 | Should -Be "2 MB"
        }
        It "should format boundary just below 1GB" {
            Human 1073741823 | Should -Be "1,024 MB"
        }
    }

    Context "when formatting gigabytes (1GB and above)" {
        It "should format exactly 1 GB with 2 decimals (1073741824 bytes)" {
            Human 1073741824 | Should -Be "1.00 GB"
        }
        It "should format 1.5 GB with 2 decimals" {
            Human 1610612736 | Should -Be "1.50 GB"
        }
        It "should format larger GB sizes" {
            Human 10737418240 | Should -Be "10.00 GB"
        }
    }
}
