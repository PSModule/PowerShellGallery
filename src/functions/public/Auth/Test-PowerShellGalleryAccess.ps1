function Test-PowerShellGalleryAccess {
    <#
        .SYNOPSIS
        Validates the stored API key by testing access to the PowerShell Gallery API.

        .DESCRIPTION
        Tests access to the PowerShell Gallery API using the stored context.
        Attempts to query the API and returns information about the validation.

        .EXAMPLE
        Test-PowerShellGalleryAccess

        Tests access using the default context.

        .EXAMPLE
        Test-PowerShellGalleryAccess -Context 'MyAccount'

        Tests access using the 'MyAccount' context.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '',
        Justification = 'Is the CLI part of the module. Consistent with GitHub module pattern.'
    )]
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        # The context to use. If not specified, uses the default context.
        [Parameter()]
        [string] $Context
    )

    begin {
        Write-Debug '[Test-PowerShellGalleryAccess] - Start'
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

        Write-Verbose "Testing access for context: [$($contextObj.Name)]"

        # Get the API key as plain text for the request
        $apiKey = Get-PowerShellGalleryAccessToken -Context $contextObj.ID -AsPlainText

        if (-not $apiKey) {
            Write-Error 'Failed to retrieve API key from context.'
            return
        }

        # Test by making a request to the PowerShell Gallery API
        # The API key validation can be done by attempting to access the API
        try {
            Write-Verbose 'Testing API connectivity...'

            # Validate API URL is a PowerShell Gallery endpoint for security
            $apiUrl = $contextObj.ApiUrl
            if ($apiUrl -notmatch '^https://.*powershellgallery\.com/') {
                Write-Warning "API URL does not appear to be a PowerShell Gallery endpoint: $apiUrl"
                $result = [PSCustomObject]@{
                    Success     = $false
                    Context     = $contextObj.Name
                    ApiUrl      = $apiUrl
                    TestedAt    = Get-Date
                    Message     = 'API URL validation failed - not a PowerShell Gallery endpoint'
                    ConnectedAt = $contextObj.ConnectedAt
                }
                return $result
            }

            $headers = @{
                'X-NuGet-ApiKey' = $apiKey
            }

            # Test basic API access - just verify we can connect
            $null = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers -ErrorAction Stop

            $result = [PSCustomObject]@{
                Success     = $true
                Context     = $contextObj.Name
                ApiUrl      = $apiUrl
                TestedAt    = Get-Date
                Message     = 'API access validated successfully'
                ConnectedAt = $contextObj.ConnectedAt
            }

            Write-Host "✓ API access validated for context [$($contextObj.Name)]" -ForegroundColor Green
            return $result

        } catch {
            $errorMessage = $_.Exception.Message
            Write-Warning "Failed to validate API access: $errorMessage"

            $result = [PSCustomObject]@{
                Success     = $false
                Context     = $contextObj.Name
                ApiUrl      = $contextObj.ApiUrl
                TestedAt    = Get-Date
                Message     = "API access validation failed: $errorMessage"
                Error       = $_
                ConnectedAt = $contextObj.ConnectedAt
            }

            return $result
        }
    }

    end {
        Write-Debug '[Test-PowerShellGalleryAccess] - End'
    }
}
