﻿function Get-PSGalleryAPI {
    <#
        .SYNOPSIS
        Get the PowerShell Gallery API.
    #>
    [CmdletBinding()]
    param()

    Invoke-RestMethod -Method Get -Uri 'https://www.powershellgallery.com/api/v2/' -ContentType 'application/json'
}
