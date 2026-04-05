function Set-PowerShellGalleryContext {
    <#
        .SYNOPSIS
        Sets the PowerShell Gallery context and stores it in the context vault.

        .DESCRIPTION
        This function sets the PowerShell Gallery context and stores it in the context vault.
        The context is used to authenticate with the PowerShell Gallery API.

        .EXAMPLE
        $context = @{
            ID          = 'MyAccount'
            Name        = 'MyAccount'
            ApiKey      = $secureApiKey
            GalleryUrl  = 'https://www.powershellgallery.com'
            ConnectedAt = Get-Date
        }
        Set-PowerShellGalleryContext -Context $context

        Sets the PowerShell Gallery context with the specified settings as a hashtable.
    #>
    [OutputType([System.Object])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The ID of the context.
        [Parameter(Mandatory)]
        [string] $ID,

        # The PowerShell Gallery context to save in the vault.
        [Parameter(Mandatory)]
        [hashtable] $Context,

        # Set as the default context.
        [Parameter()]
        [switch] $Default,

        # Pass the context through the pipeline.
        [Parameter()]
        [switch] $PassThru
    )

    begin {
        Write-Debug '[Set-PowerShellGalleryContext] - Start'
        $null = Get-PowerShellGalleryConfig
    }

    process {
        Write-Debug "Setting context: [$ID]"
        # Create a copy of the context hashtable to avoid modifying the original
        $contextObj = $Context.Clone()
        $contextObj['ID'] = $ID

        if ($PSCmdlet.ShouldProcess("Context [$ID]", 'Set')) {
            $vault = $script:PowerShellGallery.ContextVault
            $result = Set-Context -ID $ID -Context $contextObj -Vault $vault -PassThru

            if ($Default) {
                Write-Debug "Setting [$ID] as default context"
                $script:PowerShellGallery.Config.DefaultContext = $ID
                $configID = $script:PowerShellGallery.DefaultConfig.ID
                $null = Set-Context -ID $configID -Context $script:PowerShellGallery.Config -Vault $vault
            }

            if ($PassThru) {
                return $result
            }
        }
    }

    end {
        Write-Debug '[Set-PowerShellGalleryContext] - End'
    }
}
