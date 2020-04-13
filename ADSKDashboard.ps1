Clear-Host
#Initialize
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.ComponentModel') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Data') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null

[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore') | out-null
[System.Reflection.Assembly]::LoadFrom('res\assembly\MahApps.Metro.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('res\assembly\System.Windows.Interactivity.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('res\assembly\MahApps.Metro.IconPacks.dll') | out-null

# When compiled with PS2EXE the variable MyCommand contains no path anymore

if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript") {
    # Powershell script
    $PathShell = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else {
    # PS2EXE compiled script
    $PathShell = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
}

#MARK YEAR that is activ
#2021 Regkey ergänzen
#close to tray?

##############################################################
#                Config                                      #
##############################################################
function New-Config {
    #Checks for target directory and creates if non-existent 
    if (!(Test-Path -Path "$PathShell\res\settings")) {
        New-Item -ItemType Directory -Path "$PathShell\res\settings"
    }
	
    #Setup default preferences	
    #Creates hash table and .clixml config file
    $Config = @{
        'ActiveYear'    = "2020"
        'AlwaysOnTop'   = $false
        'ThemeProperty' = "LightTheme"
    }
    $Config | Export-Clixml -Path "$PathShell\res\settings\options.config"
    Import-Config
} #end function New-Config

function Import-Config {
    #If a config file exists for the current user in the expected location, it is imported
    #and values from the config file are placed into global variables
    if (Test-Path -Path "$PathShell\res\settings\options.config") {
        try {
            #Imports the config file and saves it to variable $Config
            $Config = Import-Clixml -Path "$PathShell\res\settings\options.config"
			
            #Creates global variables for each config property and sets their values
            $global:ActiveYear = $Config.ActiveYear
            $global:AlwaysOnTop = $Config.AlwaysOnTop
            $global:ThemeProperty = $Config.ThemeProperty
            
            #Set Properties depending on Optionfile
            if ($global:ThemeProperty -eq "DarkTheme") {
                $WPFThemeSwitch.IsChecked = $true
                SetTheme("DarkTheme")
            }
            else {
                $WPFThemeSwitch.IsChecked = $false
                SetTheme("LightTheme")
            }

            if ($global:AlwaysOnTop -eq $true) {
                $Form.Topmost = $true
                $WPFOnTop.IsChecked = $true
            }
            else {
                $Form.Topmost = $false
                $WPFOnTop.IsChecked = $false
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred importing your Config file. A new Config file will be generated for you. $_", 'Import Config Error', 'OK', 'Error')
            New-Config
        }
    } #end if config file exists
    else {
        New-Config
    }
} #end function Import-Config

function Update-Config {
    #Creates a new Config hash table with the current preferences set by the user
    $Config = @{
        'ActiveYear'    = $global:ActiveYear
        'ThemeProperty' = $global:ThemeProperty
        'AlwaysOnTop'   = $global:AlwaysOnTop
    }
    #Export the updated config
    $Config | Export-Clixml -Path "$PathShell\res\settings\options.config"
} #end function Update-Config


#===========================================================================
#                          Check for Installation
#===========================================================================

#AutoCAD German
$RKeyACADDE2017 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-0001-0407-1102-CF3F3A09B77D}"
$RKeyACADDE2018 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-1001-0407-1102-CF3F3A09B77D}"
$RKeyACADDE2019 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-2001-0407-1102-CF3F3A09B77D}"
$RKeyACADDE2020 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-3001-0407-1102-CF3F3A09B77D}"

#AutoCAD English
$RKeyACADENU2017 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-0001-0409-1102-CF3F3A09B77D}"
$RKeyACADENU2018 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-1001-0409-1102-CF3F3A09B77D}"
$RKeyACADENU2019 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-2001-0409-1102-CF3F3A09B77D}" 
$RKeyACADENU2020 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-3001-0409-1102-CF3F3A09B77D}"

#AutoCAD Mechanical German
$RKeyACADMDE2017 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-0005-0407-1102-CF3F3A09B77D}"
$RKeyACADMDE2018 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-1005-0407-1102-CF3F3A09B77D}"
$RKeyACADMDE2019 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-2005-0407-1102-CF3F3A09B77D}" 
$RKeyACADMDE2020 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-3005-0407-1102-CF3F3A09B77D}"

#AutoCAD Mechanical English 
$RKeyACADMENU2017 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-0005-0409-1102-CF3F3A09B77D}"
$RKeyACADMENU2018 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-1005-0409-1102-CF3F3A09B77D}"
$RKeyACADMENU2019 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-2005-0409-1102-CF3F3A09B77D}"
$RKeyACADMENU2020 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{28B89EEF-3005-0409-1102-CF3F3A09B77D}"

#Inventor German
$RKeyINVDE2017 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7F4DD591-2164-0001-1031-7107D70F3DB4}"
$RKeyINVDE2018 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7F4DD591-2264-0001-1031-7107D70F3DB4}"
$RKeyINVDE2019 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7F4DD591-2364-0001-1031-7107D70F3DB4}"
$RKeyINVDE2020 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7F4DD591-2464-0001-1031-7107D70F3DB4}"

#Inventor English
$RKeyINVENU2017 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7F4DD591-2164-0001-1033-7107D70F3DB4}"
$RKeyINVENU2018 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7F4DD591-2264-0001-1033-7107D70F3DB4}"
$RKeyINVENU2019 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7F4DD591-2364-0001-1033-7107D70F3DB4}"
$RKeyINVENU2020 = Test-Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7F4DD591-2464-0001-1033-7107D70F3DB4}"

Function HideShow($Year) {
    #AutoCAD
    $RKeyACADDE = (Get-Variable -Name "RKeyACADDE$($Year)").Value
    $RKeyACADENU = (Get-Variable -Name "RKeyACADENU$($Year)").Value
    $RKeyACADMDE = (Get-Variable -Name "RKeyACADMDE$($Year)").Value
    $RKeyACADMENU = (Get-Variable -Name "RKeyACADMENU$($Year)").Value
    $RKeyINVDE = (Get-Variable -Name "RKeyINVDE$($Year)").Value
    $RKeyINVENU = (Get-Variable -Name "RKeyINVENU$($Year)").Value

    if ($RKeyACADDE) { $WPFACADDE_BT.Visibility = "visible" }
    else { $WPFACADDE_BT.Visibility = "hidden" }
    
    if ($RKeyACADENU) { $WPFACADENU_BT.Visibility = "visible" }
    else { $WPFACADENU_BT.Visibility = "hidden" }

    #AutoCAD Mechanical
    if ($RKeyACADMDE) { $WPFACADMDE_BT.Visibility = "visible" }
    else { $WPFACADMDE_BT.Visibility = "hidden" }
        
    if ($RKeyACADMENU) { $WPFACADMENU_BT.Visibility = "visible" }
    else { $WPFACADMENU_BT.Visibility = "hidden" }

    #Inventor / Inventor Read Only
    if ($RKeyINVDE) { 
        $WPFINVDE_BT.Visibility = "visible"
        $WPFINVRODE_BT.Visibility = "visible" 
    }
    else { 
        $WPFINVDE_BT.Visibility = "hidden"
        $WPFINVRODE_BT.Visibility = "hidden" 
    }
            
    if ($RKeyINVENU) {
        $WPFINVENU_BT.Visibility = "visible"
        $WPFINVROENU_BT.Visibility = "visible"
    }
    else {
        $WPFINVENU_BT.Visibility = "hidden" 
        $WPFINVROENU_BT.Visibility = "hidden"
    }
}

Function OpenSoftware($SoftwareProduct, $language) {

    #region set parameter for string

    #INVENTOR and INVENTOR READ ONLY
    if ($SoftwareProduct -eq "Inventor" -and $language -eq "Deutsch") {
        $exe = "Inventor.exe"
        $arguments = "/language=DEU"
        $sFolder = "\Bin\"
    }
    elseif ($SoftwareProduct -eq "Inventor Read Only" -and $language -eq "Deutsch") {
        $SoftwareProduct = "Inventor"
        $exe = "InvRO.exe"
        $arguments = "/language=DEU"
        $sFolder = "\Bin\"
    }
    elseif ($SoftwareProduct -eq "Inventor" -and $language -eq "English") {
        $exe = "InvRO.exe"
        $arguments = "/language=ENU"
        $sFolder = "\Bin\"
    }
    elseif ($SoftwareProduct -eq "Inventor Read Only" -and $language -eq "English") {
        $SoftwareProduct = "Inventor"
        $exe = "InvRO.exe"
        $arguments = "/language=ENU"
        $sFolder = "\Bin\"
    }
    #AUTOCAD
    elseif ($SoftwareProduct -eq "AutoCAD" -and $language -eq "Deutsch") {
        $exe = "acad.exe"
        $arguments = "/product ACAD /language de-DE"
        $sFolder = "\"
    }
    elseif ($SoftwareProduct -eq "AutoCAD" -and $language -eq "English") {
        $exe = "acad.exe"
        $arguments = "/product ACAD /language en-US"
        $sFolder = "\"
    }
    #AUTOCAD MECHANICAL
    elseif ($SoftwareProduct -eq "AutoCAD Mechanical" -and $language -eq "Deutsch") {
        $SoftwareProduct = "AutoCAD"
        $exe = "acad.exe"
        $arguments = "/product ACADM /language de-DE"
        $sFolder = "\"
    }
    elseif ($SoftwareProduct -eq "AutoCAD Mechanical" -and $language -eq "English") {
        $SoftwareProduct = "AutoCAD"
        $exe = "acad.exe"
        $arguments = "/product ACADM /language en-US"
        $sFolder = "\"
    }

    #endregion
    
    #Invoke Process
    $pHelp = "C:\Program Files\Autodesk\" + $SoftwareProduct + " " + $global:ActiveYear + $sFolder + $exe 
    Write-Host "Starting Process: " + $pHelp + "with the following arguments: " + $arguments

    Start-Process -FilePath $pHelp -ArgumentList $arguments

    $WPFInfoText.Text = ("{0} {1} - {2} {3}" -f $SoftwareProduct, $global:ActiveYear, $language, "is loading." )
    $WPFInfoDialog.IsOpen = $true  

}

function SetTheme($Themestr) {
    $Theme = [MahApps.Metro.ThemeManager]::DetectAppStyle($Form)
    if ($Themestr -eq "DarkTheme") {
        $global:ThemeProperty = "DarkTheme"
        [MahApps.Metro.ThemeManager]::ChangeAppStyle($Form, $Theme.Item2, [MahApps.Metro.ThemeManager]::GetAppTheme("BaseDark"));
        $Theme = [MahApps.Metro.ThemeManager]::DetectAppStyle($Form)
        [MahApps.Metro.ThemeManager]::ChangeAppStyle($Form, [MahApps.Metro.ThemeManager]::GetAccent("Steel"), $Theme.Item1);
    }
    else {
        $global:ThemeProperty = "LightTheme"
        [MahApps.Metro.ThemeManager]::ChangeAppStyle($Form, $Theme.Item2, [MahApps.Metro.ThemeManager]::GetAppTheme("BaseLight")); 
        $Theme = [MahApps.Metro.ThemeManager]::DetectAppStyle($Form)
        [MahApps.Metro.ThemeManager]::ChangeAppStyle($Form, [MahApps.Metro.ThemeManager]::GetAccent("Cobalt"), $Theme.Item1);
    }
}
#===========================================================================
#                            XAML Reader Region
#===========================================================================

#region XAML Reader

# where is the XAML file?
#$xamlFile = $path + "\res\MainWindow.xaml"
$xamlFile = "H:\Dropbox (Data)\TWIProgrammierung\Autodesk\ADSKDashboard\ADSKDashboard\MainWindow.xaml"
$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $Form = [Windows.Markup.XamlReader]::Load( $reader )
}
catch {
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
$wpfElement = @()
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { "trying item $($_.Name)";
    try {
        Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop 
        $wpfElement += (Get-Variable -Name "WPF$($_.Name)").Value
    }
    
    catch { throw }
}

Function Get-FormVariables {
    if ($global:ReadmeDisplay -ne $true) { Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow; $global:ReadmeDisplay = $true }
    write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
    get-variable WPF*
}
#Print foun variables 
Get-FormVariables
#endregion XAML Reader


#region Icon and Image Source
$Form.Icon = $PathShell + "\res\ADSKDashboard_Icon.png"
$WPFY2021Tab_IMG.Source = $PathShell + "\res\YButton2021.png"
$WPFY2020Tab_IMG.Source = $PathShell + "\res\YButton2020.png"
$WPFY2019Tab_IMG.Source = $PathShell + "\res\YButton2019.png"
$WPFY2018Tab_IMG.Source = $PathShell + "\res\YButton2018.png"
$WPFY2017Tab_IMG.Source = $PathShell + "\res\YButton2017.png"

$WPFINVDE_IMG.Source = $PathShell + "\res\Inventor_DE.png"
$WPFINVENU_IMG.Source = $PathShell + "\res\Inventor_ENU.png"
$WPFINVRODE_IMG.Source = $PathShell + "\res\Inventor_DE.png"
$WPFINVROENU_IMG.Source = $PathShell + "\res\Inventor_ENU.png"

$WPFACADDE_IMG.Source = $PathShell + "\res\AutoCAD_DE.png"
$WPFACADENU_IMG.Source = $PathShell + "\res\AutoCAD_ENU.png"

$WPFACADMDE_IMG.Source = $PathShell + "\res\AutoCAD_DE.png"
$WPFACADMENU_IMG.Source = $PathShell + "\res\AutoCAD_ENU.png"

#Hide all at start
foreach ($item in $wpfElement) {
    if ($item.name -like "*_BT") {
        $item.Visibility = "hidden"
    }
}
#endregion

#Initialize / Import config
Import-Config

if ($global:ActiveYear -eq "2021")
{ HideShow 2021 }
if ($global:ActiveYear -eq "2020")
{ HideShow 2020 }
elseif ($global:ActiveYear -eq "2019")
{ HideShow 2019 }
elseif ($global:ActiveYear -eq "2018")
{ HideShow 2018 }
elseif ($global:ActiveYear -eq "2017") 
{ HideShow 2017 }

#===========================================================================
#                            Button Click Events
#===========================================================================
#region Tabs
$WPFY2021Tab.Add_click( {
        Write-Host "2021"
        HideShow 2021
        $global:ActiveYear = "2021"
    })

$WPFY2020Tab.Add_click( {
        Write-Host "2020"
        HideShow 2020
        $global:ActiveYear = "2020"
    })

$WPFY2019Tab.Add_click( {
        Write-Host "2019"
        HideShow 2019
        $global:ActiveYear = "2019"
    })

$WPFY2018Tab.Add_click( {
        Write-Host "2018"
        HideShow 2018
        $global:ActiveYear = "2018"
    })

$WPFY2017Tab.Add_click( {
        Write-Host "2017"
        HideShow 2017
        $global:ActiveYear = "2017"
    })
#endregion

#region Software Buttons
#INVENTOR
$WPFINVDE_BT.Add_click( {
        OpenSoftware "Inventor" "Deutsch"
    })
$WPFINVENU_BT.Add_click( {
        OpenSoftware "Inventor" "English"
    })

#INVENTOR READ ONLY
$WPFINVRODE_BT.Add_click( {
        OpenSoftware "Inventor Read Only" "Deutsch"
    })
$WPFINVROENU_BT.Add_click( {
        OpenSoftware "Inventor Read Only" "English"
    })

#AUTOCAD
$WPFACADDE_BT.Add_click( {
        OpenSoftware "AutoCAD" "Deutsch"
    })
$WPFACADENU_BT.Add_click( {
        OpenSoftware "AutoCAD" "English"
    })

#AUTOCAD MECHANICAL 
$WPFACADMDE_BT.Add_click( {
        OpenSoftware "AutoCAD Mechanical" "Deutsch"
    })
$WPFACADENU_BT.Add_click( {
        OpenSoftware "AutoCAD Mechanical" "English"
    })

#endregion

#===========================================================================
#                            Settings Click Events
#===========================================================================

$WPFSettingsButton.Add_click( {
        $WPFFlyOutContent.IsOpen = $true
    })

$WPFHelpButton.Add_click( {
        start "https://github.com/TWiesendanger/ADSKDashboardPS"
    })

$WPFOnTop.Add_click( {
        if ($WPFOnTop.IsChecked -eq $true) {
            $Form.Topmost = $true
            $global:AlwaysOnTop = $true
            Update-Config
        }
        else {
            $Form.Topmost = $false
            $global:AlwaysOnTop = $false
            Update-Config
        }
    })

$WPFThemeSwitch.Add_Click( {
        if ($WPFThemeSwitch.IsChecked -eq $true) {
            #BaseDark
            SetTheme("DarkTheme")
            Update-Config
        }
        else {
            SetTheme("LightTheme")
            Update-Config
        }
    })

$Form.ShowDialog() | out-null