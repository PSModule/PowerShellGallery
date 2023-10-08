function Get-PSGalleryAPI {
    $response = Invoke-RestMethod -Method Get -Uri https://www.powershellgallery.com/api/v2/ -ContentType 'application/json'
}
