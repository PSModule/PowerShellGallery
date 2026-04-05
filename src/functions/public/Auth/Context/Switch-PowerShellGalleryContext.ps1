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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '',
        Justification = 'Is the CLI part of the module. Consistent with GitHub module pattern.'
    )]
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
            $msg = "Context [$ID] not found. Use 'Get-PowerShellGalleryContext -ListAvailable' to see available contexts."
            Write-Error $msg
            return
        }

        if ($PSCmdlet.ShouldProcess("Default context to [$ID]", 'Switch')) {
            Write-Verbose "Switching default context to [$ID]"
            $script:PowerShellGallery.Config.DefaultContext = $ID
            $configID = $script:PowerShellGallery.DefaultConfig.ID
            $vault = $script:PowerShellGallery.ContextVault
            $null = Set-Context -ID $configID -Context $script:PowerShellGallery.Config -Vault $vault
            Write-Host "✓ Switched to context [$ID]" -ForegroundColor Green
        }
    }

    end {
        Write-Debug '[Switch-PowerShellGalleryContext] - End'
    }
}
