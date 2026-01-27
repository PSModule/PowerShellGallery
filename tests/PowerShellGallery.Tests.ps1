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
        }

        AfterAll {
            # Clean up test context
            try {
                $null = Disconnect-PowerShellGallery -Name $script:TestContextName -Confirm:$false -ErrorAction SilentlyContinue
            } catch {
                # Ignore cleanup errors
            }
        }

        It 'Should accept Name parameter' {
            $secureApiKey = ConvertTo-SecureString -String 'test-api-key-123' -AsPlainText -Force
            { Connect-PowerShellGallery -Name $script:TestContextName -ApiKey $secureApiKey -Silent } | Should -Not -Throw
        }

        It 'Should create a context' {
            $context = Get-PowerShellGalleryContext -ID $script:TestContextName
            $context | Should -Not -BeNullOrEmpty
            $context.Name | Should -Be $script:TestContextName
        }

        It 'Should have PassThru parameter' {
            $secureApiKey = ConvertTo-SecureString -String 'test-api-key-456' -AsPlainText -Force
            $context = Connect-PowerShellGallery -Name "$($script:TestContextName)_2" -ApiKey $secureApiKey -Silent -PassThru
            $context | Should -Not -BeNullOrEmpty
            $context.Name | Should -Be "$($script:TestContextName)_2"
            # Cleanup
            $null = Disconnect-PowerShellGallery -Name "$($script:TestContextName)_2" -Confirm:$false -ErrorAction SilentlyContinue
        }
    }

    Context 'Context Integration - Get-PowerShellGalleryContext' {
        BeforeAll {
            # Setup test context
            $testContextName = 'GetTestContext_' + (Get-Random)
            $script:GetTestContextName = $testContextName
            $secureApiKey = ConvertTo-SecureString -String 'test-get-api-key' -AsPlainText -Force
            Connect-PowerShellGallery -Name $testContextName -ApiKey $secureApiKey -Silent
        }

        AfterAll {
            # Cleanup
            try {
                $null = Disconnect-PowerShellGallery -Name $script:GetTestContextName -Confirm:$false -ErrorAction SilentlyContinue
            } catch {
                # Ignore cleanup errors
            }
        }

        It 'Should retrieve context by ID' {
            $context = Get-PowerShellGalleryContext -ID $script:GetTestContextName
            $context | Should -Not -BeNullOrEmpty
            $context.Name | Should -Be $script:GetTestContextName
        }

        It 'Should list available contexts with -ListAvailable' {
            $contexts = Get-PowerShellGalleryContext -ListAvailable
            $contexts | Should -Not -BeNullOrEmpty
            $contexts.Name | Should -Contain $script:GetTestContextName
        }

        It 'Should return default context when no parameters provided' {
            # This will either return a context or warn about no default
            { Get-PowerShellGalleryContext } | Should -Not -Throw
        }
    }

    Context 'Context Integration - Switch-PowerShellGalleryContext' {
        BeforeAll {
            # Setup test contexts
            $testContextName1 = 'SwitchTestContext1_' + (Get-Random)
            $testContextName2 = 'SwitchTestContext2_' + (Get-Random)
            $script:SwitchTestContextName1 = $testContextName1
            $script:SwitchTestContextName2 = $testContextName2
            
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
                # Ignore cleanup errors
            }
        }

        It 'Should switch to specified context' {
            { Switch-PowerShellGalleryContext -ID $script:SwitchTestContextName1 } | Should -Not -Throw
        }

        It 'Should set context as default' {
            Switch-PowerShellGalleryContext -ID $script:SwitchTestContextName2
            $config = Get-PowerShellGalleryConfig
            $config.DefaultContext | Should -Be $script:SwitchTestContextName2
        }
    }

    Context 'Context Integration - Disconnect-PowerShellGallery' {
        BeforeEach {
            # Setup test context for each test
            $testContextName = 'DisconnectTestContext_' + (Get-Random)
            $script:DisconnectTestContextName = $testContextName
            $secureApiKey = ConvertTo-SecureString -String 'test-disconnect-api-key' -AsPlainText -Force
            Connect-PowerShellGallery -Name $testContextName -ApiKey $secureApiKey -Silent
        }

        It 'Should disconnect specified context' {
            { Disconnect-PowerShellGallery -Name $script:DisconnectTestContextName -Confirm:$false } | Should -Not -Throw
        }

        It 'Should remove context from vault' {
            Disconnect-PowerShellGallery -Name $script:DisconnectTestContextName -Confirm:$false
            $context = Get-PowerShellGalleryContext -ID $script:DisconnectTestContextName -ErrorAction SilentlyContinue
            $context | Should -BeNullOrEmpty
        }
    }

    Context 'Context Integration - Get-PowerShellGalleryAccessToken' {
        BeforeAll {
            # Setup test context
            $testContextName = 'TokenTestContext_' + (Get-Random)
            $script:TokenTestContextName = $testContextName
            $script:TestApiKey = 'test-token-api-key-xyz'
            $secureApiKey = ConvertTo-SecureString -String $script:TestApiKey -AsPlainText -Force
            Connect-PowerShellGallery -Name $testContextName -ApiKey $secureApiKey -Silent
        }

        AfterAll {
            # Cleanup
            try {
                $null = Disconnect-PowerShellGallery -Name $script:TokenTestContextName -Confirm:$false -ErrorAction SilentlyContinue
            } catch {
                # Ignore cleanup errors
            }
        }

        It 'Should retrieve API key as SecureString by default' {
            $token = Get-PowerShellGalleryAccessToken -Context $script:TokenTestContextName
            $token | Should -Not -BeNullOrEmpty
            $token | Should -BeOfType [SecureString]
        }

        It 'Should retrieve API key as plain text with -AsPlainText' {
            $token = Get-PowerShellGalleryAccessToken -Context $script:TokenTestContextName -AsPlainText
            $token | Should -Not -BeNullOrEmpty
            $token | Should -BeOfType [string]
            $token | Should -Be $script:TestApiKey
        }
    }

    Context 'Context Integration - Test-PowerShellGalleryAccess' {
        BeforeAll {
            # Setup test context
            $testContextName = 'AccessTestContext_' + (Get-Random)
            $script:AccessTestContextName = $testContextName
            $secureApiKey = ConvertTo-SecureString -String 'test-access-api-key' -AsPlainText -Force
            Connect-PowerShellGallery -Name $testContextName -ApiKey $secureApiKey -Silent
        }

        AfterAll {
            # Cleanup
            try {
                $null = Disconnect-PowerShellGallery -Name $script:AccessTestContextName -Confirm:$false -ErrorAction SilentlyContinue
            } catch {
                # Ignore cleanup errors
            }
        }

        It 'Should return a result object' {
            $result = Test-PowerShellGalleryAccess -Context $script:AccessTestContextName -ErrorAction SilentlyContinue
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'Success'
            $result.PSObject.Properties.Name | Should -Contain 'Context'
            $result.PSObject.Properties.Name | Should -Contain 'ApiUrl'
        }

        It 'Should accept Context parameter' {
            { Test-PowerShellGalleryAccess -Context $script:AccessTestContextName -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context 'Context Integration - Module Initialization' {
        It 'Initialize-PowerShellGalleryConfig should initialize config' {
            { Initialize-PowerShellGalleryConfig } | Should -Not -Throw
        }

        It 'Get-PowerShellGalleryConfig should return config' {
            $config = Get-PowerShellGalleryConfig
            $config | Should -Not -BeNullOrEmpty
            $config.ID | Should -Be 'Module'
        }
    }
}
