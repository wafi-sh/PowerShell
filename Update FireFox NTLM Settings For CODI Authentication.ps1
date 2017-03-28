# Title: Update Firefox NTLM Settings For CODI Authentication
# Version: 1.0.0
# Date: 10/14/2016
# Department: Solution technology - Infrastructure
# Author: Wafi AlShareef
# -----------------------------------------------------------


# ------------------------------------------------Detials----------------------------------------------------
# - Based on ticket number 28110 -submitted by SharePoint department- the end users                         -                    
# - are getting a pop up prompts to authenticate when accessing CODI using Firefox,                         -
# - although the end user is authenticated and logged in to Windows AD account.                             -
# - This issue doesn’t present on IE or Chrome.                                                             -
# - This script will:                                                                                       -
# - 1- Check if Firefox installed on the machine                                                            -   
# - 2- If it is installed, then check if Firefox NTLM settings have been configured before or not           -
# - 3- If NTLM settings do not exist, then add the settings; otherwise keep the current settings untouched. -
# - Firefox NTLM settings are:                                                                              -
# - 1- network.negotiate-auth.trusted-uris                                                                  -
# - 2- network.automatic-ntlm-auth.trusted-uris                                                             -
# -----------------------------------------------------------------------------------------------------------
CLS
# check if Firefox installed on the machine
if (Test-Path -Path "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe")
{
    # Fetch all Firefox preferences files for the logged in user
    $ConfFilesArray = Get-childitem -Path $env:APPDATA"\Mozilla\Firefox\Profiles\" -Filter prefs.js -Recurse 
    # For each preferences file check Firefox NTLM settings
    foreach ($ConfFileInfo in $ConfFilesArray)
    {
       # If network.negotiate-auth.trusted-uris does not exist, then add the settings
       if ( ! (Select-String -Path $ConfFileInfo -Pattern 'network.negotiate-auth.trusted-uris')){
            Add-Content -Path $ConfFileInfo.FullName "user_pref(`"network.negotiate-auth.trusted-uris`", `"codiapps.net`");"}
       # If network.automatic-ntlm-auth.trusted-uris does not exist, then add the settings
       if ( ! (Select-String -Path $ConfFileInfo -Pattern 'network.automatic-ntlm-auth.trusted-uris')){
            Add-Content -Path $ConfFileInfo.FullName "user_pref(`"network.automatic-ntlm-auth.trusted-uris`", `"codiapps.net`");"}
    }#foreach
}#if

#$wshell = New-Object -ComObject Wscript.Shell

#$wshell.Popup("Script is running",0,"Done")