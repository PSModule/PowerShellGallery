function Get-PowerShellGalleryAccessToken {
    <#
        .SYNOPSIS
        Retrieve the API key from a stored context.

        .DESCRIPTION
        Retrieves the PowerShell Gallery API key from the specified context.
        Returns as SecureString by default, or as plain text with -AsPlainText.

        SECURITY NOTE: Using -AsPlainText exposes the API key in plain text in memory.
        This should only be used when necessary for API calls, and the plain text
        value should be cleared from memory as soon as possible after use.

        .EXAMPLE
        Get-PowerShellGalleryAccessToken

        Gets the API key from the default context as a SecureString.

        .EXAMPLE
        Get-PowerShellGalleryAccessToken -Context 'MyAccount' -AsPlainText

        Gets the API key from 'MyAccount' context as plain text.
        WARNING: This exposes the API key in plain text - use with caution.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Converting from stored SecureString.'
    )]
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        # The context name to retrieve the API key from. If not specified, uses the default context.
        [Parameter()]
        [string] $Context,

        # Return the API key as plain text instead of SecureString
        [Parameter()]
        [switch] $AsPlainText
    )

    begin {
        Write-Debug '[Get-PowerShellGalleryAccessToken] - Start'
        $null = Get-PowerShellGalleryConfig
    }

    process {
        # Get the context
        if ([string]::IsNullOrEmpty($Context)) {
            $contextObj = Get-PowerShellGalleryContext
        } else {
            $contextObj = Get-PowerShellGalleryContext -ID $Context
        }

        if (-not $contextObj) {
            Write-Error 'No context found. Use Connect-PowerShellGallery to create a context.'
            return
        }

        # Get the API key
        $apiKey = $contextObj.ApiKey
        if (-not $apiKey) {
            Write-Error "No API key found in context [$($contextObj.Name)]"
            return
        }

        # Return as plain text if requested
        if ($AsPlainText) {
            if ($apiKey -is [SecureString]) {
                return ConvertFrom-SecureString -SecureString $apiKey -AsPlainText
            } else {
                return $apiKey
            }
        }

        # Ensure it's a SecureString
        if ($apiKey -is [SecureString]) {
            return $apiKey
        } else {
            return ConvertTo-SecureString -String $apiKey -AsPlainText -Force
        }
    }

    end {
        Write-Debug '[Get-PowerShellGalleryAccessToken] - End'
    }
}
