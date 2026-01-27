function Get-PowerShellGalleryConfig {
    <#
        .SYNOPSIS
        Get the PowerShell Gallery configuration.

        .DESCRIPTION
        Get the PowerShell Gallery configuration. Initializes if not already loaded.

        .EXAMPLE
        Get-PowerShellGalleryConfig

        Gets the PowerShell Gallery configuration.
    #>
    [OutputType([System.Object])]
    [CmdletBinding()]
    param()

    begin {
        Write-Debug '[Get-PowerShellGalleryConfig] - Start'
    }

    process {
        if ($null -eq $script:PowerShellGallery.Config) {
            Write-Debug 'Config not initialized, initializing...'
            Initialize-PowerShellGalleryConfig
        }
        return $script:PowerShellGallery.Config
    }

    end {
        Write-Debug '[Get-PowerShellGalleryConfig] - End'
    }
}
