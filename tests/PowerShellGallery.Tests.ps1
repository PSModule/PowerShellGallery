[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Test file - converting test data to SecureString for testing purposes only.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '',
    Justification = 'Test file - using Write-Host to provide test output visibility as requested.'
)]
param()

Describe 'PowerShellGallery' {
    Context 'Function: Get-PSGalleryAPI' {
        It 'Should not throw' {
            { Get-PSGalleryAPI } | Should -Not -Throw
        }
    }
    Context 'Function: Hide-PowerShellGalleryItem' {
        It 'Should not throw' {
            { Hide-PowerShellGalleryItem } | Should -Not -Throw
        }
    }
    Context 'Function: Show-PowerShellGalleryItem' {
        It 'Should not throw' {
            { Show-PowerShellGalleryItem } | Should -Not -Throw
        }
    }

    Context 'Context Integration - Connect-PowerShellGallery' {
        BeforeAll {
            # Clean up any existing test contexts
            $testContextName = 'TestContext_' + (Get-Random)
            $script:TestContextName = $testContextName
            Write-Host "Testing Connect-PowerShellGallery with context name: $testContextName" -ForegroundColor Cyan
        }

        AfterAll {
            # Clean up test context
            try {
                $null = Disconnect-PowerShellGallery -Name $script:TestContextName -Confirm:$false -ErrorAction SilentlyContinue
            } catch {
                Write-Verbose "Cleanup error ignored: $_"
            }
        }

        It 'Should accept Name parameter and connect successfully' {
            Write-Host "  → Connecting to PowerShell Gallery with Name parameter" -ForegroundColor Gray
            $secureApiKey = ConvertTo-SecureString -String 'test-api-key-123' -AsPlainText -Force
            { Connect-PowerShellGallery -Name $script:TestContextName -ApiKey $secureApiKey -Silent } | Should -Not -Throw
            Write-Host "  ✓ Connection succeeded" -ForegroundColor Green
        }

        It 'Should create a context with correct properties' {
            Write-Host "  → Retrieving context by ID: $($script:TestContextName)" -ForegroundColor Gray
            $context = Get-PowerShellGalleryContext -ID $script:TestContextName
            $context | Should -Not -BeNullOrEmpty
            $context.Name | Should -Be $script:TestContextName
            Write-Host "  ✓ Context retrieved with Name: $($context.Name), ID: $($context.ID)" -ForegroundColor Green
        }

        It 'Should have PassThru parameter and return context' {
            Write-Host "  → Testing PassThru parameter" -ForegroundColor Gray
            $secureApiKey = ConvertTo-SecureString -String 'test-api-key-456' -AsPlainText -Force
            $context = Connect-PowerShellGallery -Name "$($script:TestContextName)_2" -ApiKey $secureApiKey -Silent -PassThru
            $context | Should -Not -BeNullOrEmpty
            $context.Name | Should -Be "$($script:TestContextName)_2"
            Write-Host "  ✓ PassThru returned context: $($context.Name)" -ForegroundColor Green
            # Cleanup
            $null = Disconnect-PowerShellGallery -Name "$($script:TestContextName)_2" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context 'Context Integration - Get-PowerShellGalleryContext' {
        BeforeAll {
            # Setup test context
            $testContextName = 'GetTestContext_' + (Get-Random)
            $script:GetTestContextName = $testContextName
            Write-Host "Testing Get-PowerShellGalleryContext with context name: $testContextName" -ForegroundColor Cyan
            $secureApiKey = ConvertTo-SecureString -String 'test-get-api-key' -AsPlainText -Force
            Connect-PowerShellGallery -Name $testContextName -ApiKey $secureApiKey -Silent
        }

        AfterAll {
            # Cleanup
            try {
                $null = Disconnect-PowerShellGallery -Name $script:GetTestContextName -Confirm:$false -ErrorAction SilentlyContinue
            } catch {
                Write-Verbose "Cleanup error ignored: $_"
            }
        }

        It 'Should retrieve context by ID' {
            Write-Host "  → Retrieving context by ID: $($script:GetTestContextName)" -ForegroundColor Gray
            $context = Get-PowerShellGalleryContext -ID $script:GetTestContextName
            $context | Should -Not -BeNullOrEmpty
            $context.Name | Should -Be $script:GetTestContextName
            Write-Host "  ✓ Retrieved context: $($context.Name)" -ForegroundColor Green
        }

        It 'Should list available contexts with -ListAvailable' {
            Write-Host "  → Listing all available contexts" -ForegroundColor Gray
            $contexts = Get-PowerShellGalleryContext -ListAvailable
            $contexts | Should -Not -BeNullOrEmpty
            $contexts.Name | Should -Contain $script:GetTestContextName
            Write-Host "  ✓ Found $($contexts.Count) context(s), including: $($script:GetTestContextName)" -ForegroundColor Green
        }

        It 'Should return default context when no parameters provided' {
            Write-Host "  → Getting default context" -ForegroundColor Gray
            # This will either return a context or warn about no default
            { Get-PowerShellGalleryContext } | Should -Not -Throw
            Write-Host "  ✓ Default context query succeeded" -ForegroundColor Green
        }
    }

    Context 'Context Integration - Switch-PowerShellGalleryContext' {
        BeforeAll {
            # Setup test contexts
            $testContextName1 = 'SwitchTestContext1_' + (Get-Random)
            $testContextName2 = 'SwitchTestContext2_' + (Get-Random)
            $script:SwitchTestContextName1 = $testContextName1
            $script:SwitchTestContextName2 = $testContextName2
            Write-Host "Testing Switch-PowerShellGalleryContext with contexts: $testContextName1, $testContextName2" -ForegroundColor Cyan

            $secureApiKey1 = ConvertTo-SecureString -String 'test-switch-api-key-1' -AsPlainText -Force
            $secureApiKey2 = ConvertTo-SecureString -String 'test-switch-api-key-2' -AsPlainText -Force

            Connect-PowerShellGallery -Name $testContextName1 -ApiKey $secureApiKey1 -Silent
            Connect-PowerShellGallery -Name $testContextName2 -ApiKey $secureApiKey2 -Silent
        }

        AfterAll {
            # Cleanup
            try {
                $null = Disconnect-PowerShellGallery -Name $script:SwitchTestContextName1 -Confirm:$false -ErrorAction SilentlyContinue
                $null = Disconnect-PowerShellGallery -Name $script:SwitchTestContextName2 -Confirm:$false -ErrorAction SilentlyContinue
            } catch {
                Write-Verbose "Cleanup error ignored: $_"
            }
        }

        It 'Should switch to specified context' {
            Write-Host "  → Switching to context: $($script:SwitchTestContextName1)" -ForegroundColor Gray
            { Switch-PowerShellGalleryContext -ID $script:SwitchTestContextName1 } | Should -Not -Throw
            Write-Host "  ✓ Switched successfully" -ForegroundColor Green
        }

        It 'Should set context as default and retrieve it' {
            Write-Host "  → Switching to context: $($script:SwitchTestContextName2)" -ForegroundColor Gray
            Switch-PowerShellGalleryContext -ID $script:SwitchTestContextName2

            # Verify by getting the default context
            Write-Host "  → Verifying default context is set correctly" -ForegroundColor Gray
            $defaultContext = Get-PowerShellGalleryContext
            $defaultContext | Should -Not -BeNullOrEmpty
            $defaultContext.ID | Should -Be $script:SwitchTestContextName2
            Write-Host "  ✓ Default context verified: $($defaultContext.ID)" -ForegroundColor Green
        }
    }

    Context 'Context Integration - Disconnect-PowerShellGallery' {
        BeforeEach {
            # Setup test context for each test
            $testContextName = 'DisconnectTestContext_' + (Get-Random)
            $script:DisconnectTestContextName = $testContextName
            Write-Host "  → Creating test context: $testContextName" -ForegroundColor Gray
            $secureApiKey = ConvertTo-SecureString -String 'test-disconnect-api-key' -AsPlainText -Force
            Connect-PowerShellGallery -Name $testContextName -ApiKey $secureApiKey -Silent
        }

        It 'Should disconnect specified context' {
            Write-Host "  → Disconnecting context: $($script:DisconnectTestContextName)" -ForegroundColor Gray
            { Disconnect-PowerShellGallery -Name $script:DisconnectTestContextName -Confirm:$false } | Should -Not -Throw
            Write-Host "  ✓ Disconnected successfully" -ForegroundColor Green
        }

        It 'Should remove context from vault' {
            Write-Host "  → Disconnecting and verifying removal: $($script:DisconnectTestContextName)" -ForegroundColor Gray
            Disconnect-PowerShellGallery -Name $script:DisconnectTestContextName -Confirm:$false
            $context = Get-PowerShellGalleryContext -ID $script:DisconnectTestContextName -ErrorAction SilentlyContinue
            $context | Should -BeNullOrEmpty
            Write-Host "  ✓ Context removed from vault" -ForegroundColor Green
        }
    }

    Context 'Context Integration - Get-PowerShellGalleryAccessToken' {
        BeforeAll {
            # Setup test context
            $testContextName = 'TokenTestContext_' + (Get-Random)
            $script:TokenTestContextName = $testContextName
            $script:TestApiKey = 'test-token-api-key-xyz'
            Write-Host "Testing Get-PowerShellGalleryAccessToken with context: $testContextName" -ForegroundColor Cyan
            $secureApiKey = ConvertTo-SecureString -String $script:TestApiKey -AsPlainText -Force
            Connect-PowerShellGallery -Name $testContextName -ApiKey $secureApiKey -Silent
        }

        AfterAll {
            # Cleanup
            try {
                $null = Disconnect-PowerShellGallery -Name $script:TokenTestContextName -Confirm:$false -ErrorAction SilentlyContinue
            } catch {
                Write-Verbose "Cleanup error ignored: $_"
            }
        }

        It 'Should retrieve API key as SecureString by default' {
            Write-Host "  → Retrieving API key as SecureString" -ForegroundColor Gray
            $token = Get-PowerShellGalleryAccessToken -Context $script:TokenTestContextName
            $token | Should -Not -BeNullOrEmpty
            $token | Should -BeOfType [SecureString]
            Write-Host "  ✓ Retrieved API key as SecureString" -ForegroundColor Green
        }

        It 'Should retrieve API key as plain text with -AsPlainText' {
            Write-Host "  → Retrieving API key as plain text" -ForegroundColor Gray
            $token = Get-PowerShellGalleryAccessToken -Context $script:TokenTestContextName -AsPlainText
            $token | Should -Not -BeNullOrEmpty
            $token | Should -BeOfType [string]
            $token | Should -Be $script:TestApiKey
            Write-Host "  ✓ Retrieved API key as plain text and verified value" -ForegroundColor Green
        }
    }

    Context 'Context Integration - Test-PowerShellGalleryAccess' {
        BeforeAll {
            # Setup test context
            $testContextName = 'AccessTestContext_' + (Get-Random)
            $script:AccessTestContextName = $testContextName
            Write-Host "Testing Test-PowerShellGalleryAccess with context: $testContextName" -ForegroundColor Cyan
            $secureApiKey = ConvertTo-SecureString -String 'test-access-api-key' -AsPlainText -Force
            Connect-PowerShellGallery -Name $testContextName -ApiKey $secureApiKey -Silent
        }

        AfterAll {
            # Cleanup
            try {
                $null = Disconnect-PowerShellGallery -Name $script:AccessTestContextName -Confirm:$false -ErrorAction SilentlyContinue
            } catch {
                Write-Verbose "Cleanup error ignored: $_"
            }
        }

        It 'Should return a result object with expected properties' {
            Write-Host "  → Testing API access and retrieving result object" -ForegroundColor Gray
            $result = Test-PowerShellGalleryAccess -Context $script:AccessTestContextName -ErrorAction SilentlyContinue
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'Success'
            $result.PSObject.Properties.Name | Should -Contain 'Context'
            $result.PSObject.Properties.Name | Should -Contain 'ApiUrl'
            $successMsg = "Result object contains Success=$($result.Success), Context=$($result.Context)"
            Write-Host "  ✓ $successMsg" -ForegroundColor Green
        }

        It 'Should accept Context parameter' {
            Write-Host "  → Testing with explicit Context parameter" -ForegroundColor Gray
            { Test-PowerShellGalleryAccess -Context $script:AccessTestContextName -ErrorAction SilentlyContinue } | Should -Not -Throw
            Write-Host "  ✓ Context parameter accepted" -ForegroundColor Green
        }
    }

    Context 'Context Integration - Module Initialization' {
        It 'Initialize-PowerShellGalleryConfig should initialize without error' {
            Write-Host "  → Testing module initialization" -ForegroundColor Gray
            { Initialize-PowerShellGalleryConfig } | Should -Not -Throw
            Write-Host "  ✓ Module initialized successfully" -ForegroundColor Green
        }
    }
}
