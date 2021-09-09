$currentLocation = Get-Location

$profilePathInit = "$($currentLocation)\profiles"
$profileSettings = @()
$profileSettingsFile = "profileSettings.json"
$profileSettingsFilePath = "$profilePathInit\profileSettings.json"

. .\L2WUtils.ps1


while($true)
{

    try
    {
        Process-Profile-Folder
        
        Process-InI-Files
        
        Process-Profile
    
    } catch {
        Write-Host $_
    } finally {
        Read-Host 'Press Enter to continue.'
    }
}