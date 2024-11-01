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
