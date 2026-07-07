#Requires -Modules @{ ModuleName = 'Pester'; ModuleVersion = '6.0.0'; MaximumVersion = '6.*'; GUID = 'a699dea5-2c73-4616-a270-1f7abb777e71' }

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
