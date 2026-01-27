function Switch-PowerShellGalleryContext {
    <#
        .SYNOPSIS
        Switch the default PowerShell Gallery context.

        .DESCRIPTION
        Switch the default PowerShell Gallery context to a different stored context.

        .EXAMPLE
        Switch-PowerShellGalleryContext -ID 'MyAccount'

        Switches the default PowerShell Gallery context to 'MyAccount'.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The ID of the context to set as default.
        [Parameter(Mandatory)]
        [string] $ID
    )

    begin {
        Write-Debug '[Switch-PowerShellGalleryContext] - Start'
        $null = Get-PowerShellGalleryConfig
    }

    process {
        # Verify the context exists
        $context = Get-Context -ID $ID -Vault $script:PowerShellGallery.ContextVault
        if (-not $context) {
            Write-Error "Context [$ID] not found. Use 'Get-PowerShellGalleryContext -ListAvailable' to see available contexts."
            return
        }

        if ($PSCmdlet.ShouldProcess("Default context to [$ID]", 'Switch')) {
            Write-Verbose "Switching default context to [$ID]"
            $script:PowerShellGallery.Config.DefaultContext = $ID
            $null = Set-Context -ID $script:PowerShellGallery.DefaultConfig.ID -Context $script:PowerShellGallery.Config -Vault $script:PowerShellGallery.ContextVault
            Write-Host "✓ Switched to context [$ID]" -ForegroundColor Green
        }
    }

    end {
        Write-Debug '[Switch-PowerShellGalleryContext] - End'
    }
}
