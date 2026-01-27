function Initialize-PowerShellGalleryConfig {
    <#
        .SYNOPSIS
        Initialize the PowerShellGallery module configuration.

        .DESCRIPTION
        Initialize the PowerShellGallery module configuration.

        .EXAMPLE
        Initialize-PowerShellGalleryConfig

        Initializes the PowerShellGallery module configuration.

        .EXAMPLE
        Initialize-PowerShellGalleryConfig -Force

        Forces the initialization of the PowerShellGallery module configuration.
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param (
        # Force the initialization of the PowerShellGallery config.
        [switch] $Force
    )

    begin {
        Write-Debug '[Initialize-PowerShellGalleryConfig] - Start'
    }

    process {
        Write-Debug "Force: [$Force]"
        if ($Force) {
            Write-Debug 'Forcing initialization of PowerShellGalleryConfig.'
            $config = Set-Context -Context $script:PowerShellGallery.DefaultConfig -Vault $script:PowerShellGallery.ContextVault -PassThru
            $script:PowerShellGallery.Config = $config
            return
        }

        if ($null -ne $script:PowerShellGallery.Config) {
            Write-Debug 'PowerShellGalleryConfig already initialized and available in memory.'
            return
        }

        Write-Debug 'Attempt to load the stored PowerShellGalleryConfig from ContextVault'
        $config = Get-Context -ID $script:PowerShellGallery.DefaultConfig.ID -Vault $script:PowerShellGallery.ContextVault
        if ($config) {
            Write-Debug 'PowerShellGalleryConfig loaded into memory.'
            $script:PowerShellGallery.Config = $config
            return
        }

        Write-Debug 'Initializing PowerShellGalleryConfig from defaults'
        $config = Set-Context -Context $script:PowerShellGallery.DefaultConfig -Vault $script:PowerShellGallery.ContextVault -PassThru
        $script:PowerShellGallery.Config = $config
    }

    end {
        Write-Debug '[Initialize-PowerShellGalleryConfig] - End'
    }
}
