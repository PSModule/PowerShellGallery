function Get-PowerShellGalleryContext {
    <#
        .SYNOPSIS
        Get the current PowerShell Gallery context.

        .DESCRIPTION
        Get the current PowerShell Gallery context. Returns stored contexts from the vault.

        .EXAMPLE
        Get-PowerShellGalleryContext

        Gets the default PowerShell Gallery context.

        .EXAMPLE
        Get-PowerShellGalleryContext -ID 'MyAccount'

        Gets the PowerShell Gallery context with ID 'MyAccount'.

        .EXAMPLE
        Get-PowerShellGalleryContext -ListAvailable

        Lists all available PowerShell Gallery contexts.
    #>
    [OutputType([System.Object])]
    [CmdletBinding(DefaultParameterSetName = 'Get default context')]
    param(
        # The ID of the context.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Get a named context',
            Position = 0
        )]
        [Alias('Name')]
        [Alias('Context')]
        [string] $ID,

        # List all available contexts.
        [Parameter(
            Mandatory,
            ParameterSetName = 'List all available contexts'
        )]
        [switch] $ListAvailable
    )

    begin {
        Write-Debug '[Get-PowerShellGalleryContext] - Start'
        $null = Get-PowerShellGalleryConfig
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Get a named context' {
                Write-Debug "Get a named context: [$ID]"
            }
            'List all available contexts' {
                Write-Debug "ListAvailable: [$ListAvailable]"
                $ID = '*'
            }
            default {
                Write-Debug 'Getting default context.'
                $ID = $script:PowerShellGallery.Config.DefaultContext
                if ([string]::IsNullOrEmpty($ID)) {
                    Write-Warning "No default PowerShell Gallery context found. Please run 'Connect-PowerShellGallery' to configure a context."
                    return
                }
            }
        }

        Write-Verbose "Getting the context: [$ID]"
        Get-Context -ID $ID -Vault $script:PowerShellGallery.ContextVault | Where-Object { $_.ID -ne $script:PowerShellGallery.DefaultConfig.ID }
    }

    end {
        Write-Debug '[Get-PowerShellGalleryContext] - End'
    }
}
