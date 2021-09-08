$currentLocation = Get-Location

. .\L2WUtils.ps1

$profilePathInit = "$($currentLocation)\profiles"
$profileSettings = @()
$profileSettingsFile = "profileSettings.json"
$profileSettingsFilePath = "$profilePathInit\profileSettings.json"

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