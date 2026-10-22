BeforeAll {
    $sourcePath = "$PSScriptRoot/git-autocommit.ps1"
    $content = Get-Content -Path $sourcePath
    # Extract variable definitions and Test-ContinutSecret function (lines 48 to 121)
    $scriptToRun = $content[48..121] -join "`n"
    $global:SetupPath = Join-Path $PSScriptRoot "test-setup-env.ps1"
    Out-File -FilePath $global:SetupPath -InputObject $scriptToRun -Encoding utf8
    . $global:SetupPath
}

AfterAll {
    if (Test-Path $global:SetupPath) {
        Remove-Item $global:SetupPath -Force
    }
}

Describe "Test-ContinutSecret" {
    Context "File Access & Edge Cases" {
        It "returns empty list if file doesn't exist" {
            $result = @(Test-ContinutSecret -Full "non-existent-file.txt")
            $result.Count | Should -Be 0
        }

        It "returns empty list if path is a directory" {
            $dir = Join-Path $TestDrive "testDir"
            New-Item -ItemType Directory -Path $dir | Out-Null
            $result = @(Test-ContinutSecret -Full $dir)
            $result.Count | Should -Be 0
        }

        It "returns empty list if file is empty" {
            $file = Join-Path $TestDrive "empty.txt"
            New-Item -ItemType File -Path $file | Out-Null
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 0
        }

        It "returns empty list if file has a binary extension" {
            $file = Join-Path $TestDrive "image.png"
            Set-Content -Path $file -Value "some fake binary content"
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 0
        }

        It "returns empty list if file is too large" {
            $file = Join-Path $TestDrive "large.txt"
            $largeContent = New-Object byte[] 512001
            [System.IO.File]::WriteAllBytes($file, $largeContent)
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 0
        }

        It "returns empty list if file contains null byte (disguised binary)" {
            $file = Join-Path $TestDrive "disguised.txt"
            $bytes = [byte[]](65, 66, 0, 67, 68) # A B NUL C D
            [System.IO.File]::WriteAllBytes($file, $bytes)
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 0
        }
    }

    Context "Secret Detection" {
        It "detects a private key" {
            $file = Join-Path $TestDrive "key.txt"
            Set-Content -Path $file -Value "-----BEGIN RSA PRIVATE KEY-----`nMIIEow=="
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 1
            $result[0] | Should -Match "continut:"
        }

        It "detects an AWS key" {
            $file = Join-Path $TestDrive "aws.txt"
            Set-Content -Path $file -Value "AKIAIOSFODNN7EXAMPLE"
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 1
            $result[0] | Should -Match "continut: AKIA"
        }

        It "detects a GitHub token" {
            $file = Join-Path $TestDrive "gh.txt"
            Set-Content -Path $file -Value "ghp_0123456789abcdefghijABCDEFGHIJ"
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 1
            $result[0] | Should -Match "continut:"
        }

        It "detects a hardcoded password" {
            $file = Join-Path $TestDrive "pass.txt"
            Set-Content -Path $file -Value 'password = "Str0ng-SecreT!"'
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 1
            $result[0] | Should -Match "continut:"
        }

        It "detects an API key assignment" {
            $file = Join-Path $TestDrive "apikey.txt"
            Set-Content -Path $file -Value 'api_key: abcd1234efgh5678'
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 1
            $result[0] | Should -Match "continut:"
        }

        It "ignores plain text" {
            $file = Join-Path $TestDrive "plain.txt"
            Set-Content -Path $file -Value "nu comita asta"
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 0
        }

        It "ignores safe use of keywords" {
            $file = Join-Path $TestDrive "safe.txt"
            Set-Content -Path $file -Value "function Get() { return password.Length; }"
            $result = @(Test-ContinutSecret -Full $file)
            $result.Count | Should -Be 0
        }
    }
}
