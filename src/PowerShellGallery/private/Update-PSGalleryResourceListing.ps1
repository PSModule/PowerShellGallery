function Update-PSGalleryResourceListing {
    <#
        .SYNOPSIS
        Updates the listing status of a module on the PowerShell Gallery.

        .EXAMPLE
        Update-PSGalleryResourceListing -Name 'MyModule' -Version '1.0.0' -Listed $true -APIKey 'myapikey'
    #>
    [CmdletBinding()]
    param (
        # Name of the module.
        [Parameter(Mandatory)]
        [string] $Name,

        # Version of the module.
        [Parameter(Mandatory)]
        [string] $Version,

        # Whether the module is listed on the PowerShell Gallery.
        [Parameter(Mandatory)]
        [bool] $Listed,

        # API key for the PowerShell Gallery.
        [Parameter(Mandatory)]
        [string] $APIKey
    )

    $uri = "https://www.powershellgallery.com/packages/$Name/$Version/UpdateListed"

    $body = @{
        __RequestVerificationToken = $APIKey
        Version                    = $Version
        Listed                     = $Listed
    }

    Invoke-RestMethod -Uri $uri -Method Post -Body $body
}
