function Connect-PowerShellGallery {
    <#
        .SYNOPSIS
        Connects to the PowerShell Gallery by storing an API key context.

        .DESCRIPTION
        Connects to the PowerShell Gallery by storing an API key in a secure context vault.
        When called without an API key, it opens the user's browser to the PowerShell Gallery
        API key management page and prompts for the key.

        .EXAMPLE
        Connect-PowerShellGallery -Name 'MyAccount'

        Opens browser to API key page and prompts for API key, then stores it with name 'MyAccount'.

        .EXAMPLE
        Connect-PowerShellGallery -Name 'CIAccount' -ApiKey $secureApiKey -Silent

        Stores the provided API key without prompting or informational output.

        .EXAMPLE
        $context = Connect-PowerShellGallery -Name 'MyAccount' -PassThru

        Stores the API key and returns the context object.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'The API key is received as clear text from user input.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '',
        Justification = 'Is the CLI part of the module. Consistent with GitHub module pattern.'
    )]
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    [OutputType([System.Object])]
    param(
        # A friendly name/identifier for this connection context
        [Parameter(Mandatory)]
        [string] $Name,

        # The API key as a SecureString. If not provided, user will be prompted.
        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(Mandatory, ParameterSetName = 'NonInteractive')]
        [SecureString] $ApiKey,

        # Return the context object after creation
        [Parameter()]
        [switch] $PassThru,

        # Suppress informational output
        [Parameter()]
        [switch] $Silent
    )

    begin {
        Write-Debug '[Connect-PowerShellGallery] - Start'
        $null = Get-PowerShellGalleryConfig
    }

    process {
        # Open browser to API key page if interactive
        if ($PSCmdlet.ParameterSetName -eq 'Interactive' -and -not $ApiKey) {
            if (-not $Silent) {
                Write-Host '🌐 Opening PowerShell Gallery API key management page...' -ForegroundColor Cyan
            }

            $apiKeyUrl = 'https://www.powershellgallery.com/account/apikeys'

            # Try to open browser
            try {
                if ($IsWindows -or $PSVersionTable.PSVersion.Major -le 5) {
                    Start-Process $apiKeyUrl
                } elseif ($IsMacOS) {
                    Start-Process 'open' -ArgumentList $apiKeyUrl
                } elseif ($IsLinux) {
                    Start-Process 'xdg-open' -ArgumentList $apiKeyUrl
                }
            } catch {
                Write-Warning "Unable to open browser automatically. Please visit: $apiKeyUrl"
            }

            if (-not $Silent) {
                Write-Host ''
                Write-Host 'Please create or copy your API key from the PowerShell Gallery.' -ForegroundColor Yellow
                Write-Host ''
            }
        }

        # Prompt for API key if not provided
        if (-not $ApiKey) {
            $ApiKey = Read-Host -Prompt 'Enter your PowerShell Gallery API key' -AsSecureString
        }

        # Validate API key is not empty
        if ($null -eq $ApiKey) {
            Write-Error 'API key is required to connect to PowerShell Gallery.'
            return
        }

        # Create context object
        $context = @{
            ID          = $Name
            Name        = $Name
            ApiKey      = $ApiKey
            GalleryUrl  = 'https://www.powershellgallery.com'
            ApiUrl      = 'https://www.powershellgallery.com/api/v2'
            ConnectedAt = Get-Date
        }

        # Store context
        Write-Verbose "Storing context with ID: [$Name]"
        $result = Set-PowerShellGalleryContext -ID $Name -Context $context -Default -PassThru

        if (-not $Silent) {
            Write-Host "✓ Successfully connected to PowerShell Gallery as [$Name]" -ForegroundColor Green
        }

        if ($PassThru) {
            return $result
        }
    }

    end {
        Write-Debug '[Connect-PowerShellGallery] - End'
    }
}
