$script:PowerShellGallery = @{
    ContextVault  = 'PSModule.PowerShellGallery'
    DefaultConfig = @{
        ID             = 'Module'
        DefaultContext = $null
        GalleryUrl     = 'https://www.powershellgallery.com'
        ApiUrl         = 'https://www.powershellgallery.com/api/v2'
    }
    Config        = $null
}
