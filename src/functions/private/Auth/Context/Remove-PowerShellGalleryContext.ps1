function Remove-PowerShellGalleryContext {
    <#
        .SYNOPSIS
        Remove a PowerShell Gallery context.

        .DESCRIPTION
        Remove a PowerShell Gallery context from the vault.

        .EXAMPLE
        Remove-PowerShellGalleryContext -ID 'MyAccount'

        Removes the PowerShell Gallery context with ID 'MyAccount'.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The ID of the context to remove.
        [Parameter(Mandatory)]
        [string] $ID
    )

    begin {
        Write-Debug '[Remove-PowerShellGalleryContext] - Start'
        $null = Get-PowerShellGalleryConfig
    }

    process {
        if ($PSCmdlet.ShouldProcess("Context [$ID]", 'Remove')) {
            Write-Verbose "Removing context: [$ID]"
            Remove-Context -ID $ID -Vault $script:PowerShellGallery.ContextVault

            # If this was the default context, clear the default
            if ($script:PowerShellGallery.Config.DefaultContext -eq $ID) {
                Write-Verbose 'Clearing default context'
                $script:PowerShellGallery.Config.DefaultContext = $null
                $null = Set-Context -ID $script:PowerShellGallery.DefaultConfig.ID -Context $script:PowerShellGallery.Config -Vault $script:PowerShellGallery.ContextVault
            }
        }
    }

    end {
        Write-Debug '[Remove-PowerShellGalleryContext] - End'
    }
}
