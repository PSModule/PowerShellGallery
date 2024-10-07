[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

Describe 'PowerShellGallery' {
    Context 'Function: Get-PSGalleryAPI' {
        It 'Should not throw' {
            { Get-PSGalleryAPI } | Should -Not -Throw
        }
    }
    Context 'Function: Hide-PowerShellGalleryItem' {
        It 'Should not throw' {
            { Hide-PowerShellGalleryItem } | Should -Not -Throw
        }
    }
    Context 'Function: Show-PowerShellGalleryItem' {
        It 'Should not throw' {
            { Show-PowerShellGalleryItem } | Should -Not -Throw
        }
    }
}
