function Get-PSGalleryResource {
    <#
    .SYNOPSIS
    Get a resource from the PowerShell Gallery.

    .DESCRIPTION
    Long description

    .EXAMPLE
    Get-PSGalleryResource -Name 'MyModule' -Version '1.0.0'

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param (
        # Name of the module.
        [Parameter(Mandatory)]
        [string] $Name,

        # The API key for the PowerShell Gallery.
        [Parameter(Mandatory)]
        [string] $APIKey
    )

    $uri = "https://www.powershellgallery.com/packages/$Name"

    $body = @{
        __RequestVerificationToken = $APIKey
    }

    Invoke-RestMethod -Uri $uri -Method Get -Body $body
}
