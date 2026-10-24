Describe "Normalize-PkmsPath" {
    BeforeAll {
        $null = . "$PSScriptRoot/../paths.ps1"
    }

    It "removes trailing backslashes" {
        Normalize-PkmsPath "C:\MyFolder\" | Should -Be "C:\MyFolder"
    }

    It "removes trailing forward slashes" {
        Normalize-PkmsPath "C:/MyFolder/" | Should -Be "C:/MyFolder"
    }

    It "preserves paths without trailing slashes" {
        Normalize-PkmsPath "C:\MyFolder" | Should -Be "C:\MyFolder"
    }

    It "handles root drive paths (D:\)" {
        Normalize-PkmsPath "D:\" | Should -Be "D:"
    }

    It "handles empty paths" {
        Normalize-PkmsPath "" | Should -Be ""
    }

    It "handles null paths" {
        Normalize-PkmsPath $null | Should -Be ""
    }

    It "handles single slash paths" {
        Normalize-PkmsPath "\" | Should -Be "\"
        Normalize-PkmsPath "/" | Should -Be "/"
    }

    It "handles multiple trailing slashes" {
        Normalize-PkmsPath "C:\MyFolder\\\" | Should -Be "C:\MyFolder"
        Normalize-PkmsPath "C:/MyFolder///" | Should -Be "C:/MyFolder"
    }

    It "handles string containing only multiple slashes" {
        Normalize-PkmsPath "\\\" | Should -Be "\"
        Normalize-PkmsPath "///" | Should -Be "/"
    }
}
