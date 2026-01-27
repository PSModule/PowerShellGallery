function Disconnect-PowerShellGallery {
    <#
        .SYNOPSIS
        Disconnect from the PowerShell Gallery by removing a stored context.

        .DESCRIPTION
        Removes a stored PowerShell Gallery context from the vault.

        .EXAMPLE
        Disconnect-PowerShellGallery -Name 'MyAccount'

        Removes the context with name 'MyAccount'.

        .EXAMPLE
        Disconnect-PowerShellGallery

        Removes the default context.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([void])]
    param(
        # The name of the context to remove. If not specified, removes the default context.
        [Parameter()]
        [string] $Name
    )

    begin {
        Write-Debug '[Disconnect-PowerShellGallery] - Start'
        $null = Get-PowerShellGalleryConfig
    }

    process {
        # Determine which context to remove
        if ([string]::IsNullOrEmpty($Name)) {
            $Name = $script:PowerShellGallery.Config.DefaultContext
            if ([string]::IsNullOrEmpty($Name)) {
                Write-Warning 'No default context found. Use -Name to specify a context to remove.'
                return
            }
        }

        # Verify context exists
        $context = Get-Context -ID $Name -Vault $script:PowerShellGallery.ContextVault
        if (-not $context) {
            Write-Error "Context [$Name] not found."
            return
        }

        if ($PSCmdlet.ShouldProcess("Context [$Name]", 'Disconnect')) {
            Remove-PowerShellGalleryContext -ID $Name
            Write-Host "✓ Disconnected from PowerShell Gallery context [$Name]" -ForegroundColor Green
        }
    }

    end {
        Write-Debug '[Disconnect-PowerShellGallery] - End'
    }
}
