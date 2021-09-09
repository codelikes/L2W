$currentLocation = Get-Location
$profileSettingsFile = 'profileSettings.json'

. .\L2WUtilsJson.ps1

function Process-Profile-Folder {
    if (Test-Path -Path $profilePathInit) {
        Write-Output 'Path exists!'
    } 
    else {
        New-Item -Path $profilePathInit -ItemType Directory

        $profileSettings = @{};

        $obj = New-Object -TypeName psobject
            $obj | Add-Member -MemberType NoteProperty -Name Login -Value ''
            $obj | Add-Member -MemberType NoteProperty -Name Password -Value ''

        $profileSettings.Add('init', $obj)
    
        $profileSettings | ConvertTo-Json -depth 100 | Out-File $profileSettingsFilePath -Force
    
        Write-Output "$($profilePathInit) path created"
    }
}

function Process-InI-Files {
    $initFiles = Get-ChildItem -Path $(Get-Location) -Filter '*.INI' | Where-Object { $_.Name -ne 'Default.INI' -and $_.Name -ne 'Set.Ini' -and $_.Name -ne 'patcher.ini' }
    
    $initFiles | foreach {
            $name = $_.Name;
            $folderName = $name -replace '^' -replace '\..*'
    
            $profileFolderPath = "$($profilePathInit)\$folderName"
    
            if (Test-Path -Path $profileFolderPath) {
            } 
            else {
                New-Item -Path $profileFolderPath -ItemType Directory 
            }
    
            Move-Item "$currentLocation\$name" -Destination "$profileFolderPath\$name"
    
    
            Write-Output "$name was moved to $profilePathInit"
    }
}

function Process-Profile {
    $items = Get-ChildItem -Path $profilePathInit -Name | Where-Object { $_ -ne $profileSettingsFile }

    Write-Host $items

    $iterator = 1
    
    $itemsGroup = @{}
    
    $message = 'Please enter profile #'
    
    $items | foreach {
        $name = $_;
        Write-Output "$($iterator). $($name)"
        $itemsGroup.Add($iterator.ToString(), $_)
        $iterator++
    }
    
    $profile = Read-Host $message

    Clear-Host

    Process-Setting $itemsGroup[$profile]

    Set-Account-Config $itemsGroup[$profile]
    
    $profilePath = "$profilePathInit\$($itemsGroup[$profile])\$($itemsGroup[$profile]).INI"
    
    Copy-Item $profilePath "$currentLocation\Default.INI"
    
    & "$($currentLocation)\L2Walker.exe" /run /exit /SilentMode

    Clear-Host
}

function Set-Account-Config {
    param($profile)

    $currentLocation = Get-Location
    $settingFilePath = "$currentLocation\profiles\$profileSettingsFile"
    $setIniFile = "$currentLocation\Set.Ini"

    $settings = Get-FromJson $settingFilePath

    $login = $settings[$profile].Login
    $password = $settings[$profile].Password

    $iniContent = Get-Content $setIniFile
    $content = $iniContent -replace '^DefaultAccount.*', "DefaultAccount=$login"
    $content = $content -replace '^DefaultPassWord.*', "DefaultPassWord=$password"

    $content | Out-File $setIniFile
}

function Process-Setting {
    param ($profile)

    Write-Output '1. Load and start'
    Write-Output '2. Set l2 account'

    $option = Read-Host 'Please choose option:'

    Process-Setting-Option $option $profile
}

function Process-Setting-Option {
    param ($option, $profile)

    switch ( $option ) {
        '1'   { 'Loading..' }
        '2'   { Set-Password $profile }
    }
}

function Start-Profile {
    param($profile)

    $currentLocation = Get-Location
    $SetFile = "$currentLocation\Set.Ini"

    

    $info = $accountInfo.Split(';')

    $object = New-Object -TypeName psobject
       $object | Add-Member -MemberType NoteProperty -Name Login -Value $info[0]
       $object | Add-Member -MemberType NoteProperty -Name Password -Value $info[1]

    Save-Settings $profile $object
}

function Set-Password {
    param($profile)

    Clear-Host

    $accountInfo = Read-Host 'Enter information with next pattern login;password (test;qwerty)'

    $info = $accountInfo.Split(';')

    $object = New-Object -TypeName psobject
       $object | Add-Member -MemberType NoteProperty -Name Login -Value $info[0]
       $object | Add-Member -MemberType NoteProperty -Name Password -Value $info[1]

    Save-Settings $profile $object
}

function Save-Settings {
    param($profile, $object)

    $currentLocation = Get-Location
    $profilesLocation = "$currentLocation\profiles"
    $profileSettingsLocation = "$profilesLocation\profileSettings.json"

    $pSettings = Get-FromJson $profileSettingsLocation

    if($pSettings.ContainsKey($profile)) {
        $pSettings[$profile].Login = $object.Login
        $pSettings[$profile].Password = $object.Password
    } 
    else {
        $pSettings.Add($profile, $object)
    }

    $pSettings | ConvertTo-Json -depth 100 | Out-File $profileSettingsLocation
}