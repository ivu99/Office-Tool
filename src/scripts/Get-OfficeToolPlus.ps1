# Enable TLSv1.2 for compatibility with older clients.
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
# Do not display progress for WebRequest.
$ProgressPreference = 'SilentlyContinue'
$Host.UI.RawUI.WindowTitle = "Office Tool Plus | Downloader"

# Localization
$CurrentLang = (Get-WinUserLanguageList)[0].LanguageTag.Replace("-", "_")
$SupportedLanguages = @("en_US", "zh_Hans_CN")
# Fallback to default language if not supported.
if ($SupportedLanguages -notcontains $CurrentLang) {
    $CurrentLang = $SupportedLanguages[0].Replace("-", "_")
}
$AllLanguages = @{
    "ChooseOP"            = [PSCustomObject]@{
        en_US      = "Please enter a number"
        zh_Hans_CN = "请输入序号并回车"
    }
    "GoBack"              = [PSCustomObject]@{
        en_US      = "Back"
        zh_Hans_CN = "返回"
    }
    "HomeSelOP"           = [PSCustomObject]@{
        en_US      = "  Select an option:"
        zh_Hans_CN = "  选择一个选项："
    }
    "HomeOP1"             = [PSCustomObject]@{
        en_US      = "Download now"
        zh_Hans_CN = "立即下载"
    }
    "HomeOP2"             = [PSCustomObject]@{
        en_US      = "Select a edition to download"
        zh_Hans_CN = "选择一个版本下载"
    }
    "HomeOP4"             = [PSCustomObject]@{
        en_US      = "Exit"
        zh_Hans_CN = "退出"
    }
    "OSInfo"              = [PSCustomObject]@{
        en_US      = "OS info:"
        zh_Hans_CN = "系统信息:"
    }
    "SelToDownload"       = [PSCustomObject]@{
        en_US      = "  Select the edition to download:"
        zh_Hans_CN = "  请选择需要下载的版本："
    }
    "DownSelx64Runtime"   = [PSCustomObject]@{
        en_US      = "64-bit with runtime"
        zh_Hans_CN = "64 位（包含框架）"
    }
    "DownSelx86Runtime"   = [PSCustomObject]@{
        en_US      = "32-bit with runtime"
        zh_Hans_CN = "32 位（包含框架）"
    }
    "DownSelArm64Runtime" = [PSCustomObject]@{
        en_US      = "ARM64 with runtime"
        zh_Hans_CN = "ARM64 位（包含框架）"
    }
    "DownSelx64"          = [PSCustomObject]@{
        en_US      = "64-bit"
        zh_Hans_CN = "64 位"
    }
    "DownSelx86"          = [PSCustomObject]@{
        en_US      = "32-bit"
        zh_Hans_CN = "32 位"
    }
    "DownSelArm64"        = [PSCustomObject]@{
        en_US      = "ARM64"
        zh_Hans_CN = "ARM64 位"
    }
    "DownNormal"          = [PSCustomObject]@{
        en_US      = "  The {0} edition of Office Tool Plus will be downloaded."
        zh_Hans_CN = "  将会下载 {0} 版本的 Office Tool Plus。"
    }
    "DownRuntime"         = [PSCustomObject]@{
        en_US      = "  The {0} edition of Office Tool Plus with runtime will be downloaded."
        zh_Hans_CN = "  将会下载 {0} 版本、包含框架的 Office Tool Plus。"
    }
    "SelLocation"         = [PSCustomObject]@{
        en_US      = "  Select the save location for Office Tool Plus:"
        zh_Hans_CN = "  请选择保存 Office Tool Plus 的位置："
    }
    "LocationDesktop"     = [PSCustomObject]@{
        en_US      = "Desktop"
        zh_Hans_CN = "桌面"
    }
    "LocationCustom"      = [PSCustomObject]@{
        en_US      = "Select a folder"
        zh_Hans_CN = "选择一个文件夹"
    }
    "SelLocationTip"      = [PSCustomObject]@{
        en_US      = "  If you don't see the window to select the folder, it may be behind the window."
        zh_Hans_CN = "  如果你看不到选择文件夹的窗口，它可能在后面被挡住了。"
    }
    "Downloading"         = [PSCustomObject]@{
        en_US      = "  Downloading Office Tool Plus, please wait."
        zh_Hans_CN = "  正在下载 Office Tool Plus，请稍等..."
    }
    "Extracting"          = [PSCustomObject]@{
        en_US      = "  Extracting files, please wait."
        zh_Hans_CN = "  正在解压文件，请稍等..."
    }
    "ErrorDownloading"    = [PSCustomObject]@{
        en_US      = "  An error occurred while downloading the file."
        zh_Hans_CN = "  下载文件时发生错误。"
    }
    "RetryDownload"       = [PSCustomObject]@{
        en_US      = "  Do you want to retry? (Y/N)"
        zh_Hans_CN = "  你想重试吗？(Y/N)"
    }
    "RedownloadTip"       = [PSCustomObject]@{
        en_US      = "  Please download Office Tool Plus from https://www.officetool.plus/ or try again."
        zh_Hans_CN = "  请从官网 https://www.officetool.plus/ 下载 Office Tool Plus，或者再试一遍。"
    }
    "DownloadSuccess"     = [PSCustomObject]@{
        en_US      = "  Office Tool Plus was extracted to {0}"
        zh_Hans_CN = "  Office Tool Plus 已保存到 {0}"
    }
    "StartProgram"        = [PSCustomObject]@{
        en_US      = "  Press Enter to start the program, or close the window to exit."
        zh_Hans_CN = "  按下回车键启动程序，或者关闭窗口以退出。"
    }
}

function Get-LString {
    param([string]$Key)

    return $AllLanguages[$Key].$CurrentLang
}

function Get-OTP {
    param([string]$DownloadURL, [string]$SavePath)

    $FileName = "$env:TEMP\Office Tool Plus.zip"
    $DownloadSuccess = $false
    do {
        try {
            Get-LString "Downloading"
            Invoke-WebRequest -Uri $DownloadURL -UseBasicParsing -OutFile $FileName -ErrorAction Stop
            Get-LString "Extracting"
            Expand-Archive -LiteralPath $FileName -DestinationPath $SavePath -Force
            $DownloadSuccess = $true
        }
        catch {
            Get-LString "ErrorDownloading"
            $UserChoice = Read-Host $(Get-LString "RetryDownload")
            if ($UserChoice -ne "Y") {
                Get-LString "RedownloadTip"
                Read-Host
                Exit
            }
        }
        finally {
            if (Test-Path $FileName) {
                $item = Get-Item -LiteralPath $FileName
                $item.Delete()
            }
        }
    } while (-not $DownloadSuccess)
    Clear-Host
    Write-Host "=========================== Office Tool Plus ==========================="
    Write-Host
    Write-Host $([string]::Format($(Get-LString "DownloadSuccess"), "$SavePath\Office Tool"))
    Write-Host
    Get-LString "StartProgram"
    Read-Host
    Start-Process "$SavePath\Office Tool\Office Tool Plus.exe"
    Exit
}

function Get-RuntimeVersion {
    try {
        $DotnetInfo = dotnet --list-runtimes | Select-String -Pattern "Microsoft.WindowsDesktop.App 8"
        $IsX86Version = $DotnetInfo | Select-String -Pattern "(x86)"
        # If x86 version of runtime is installed on system, ignore it. Because we will download x64 version of OTP by default.
        if ($null -ne $IsX86Version) {
            return $false
        }
        if ($null -ne $DotnetInfo) {
            return $true
        }
    }
    catch {
        return $false
    }
    return $false
}

function Get-FolderName {
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # InitialDirectory help description
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Initial Directory for browsing",
            Position = 0)]
        [String]$SelectedPath,

        # Description help description
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Message Box Title")]
        [String]$Description = "Select a folder",

        # ShowNewFolderButton help description
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show New Folder Button when used")]
        [Switch]$ShowNewFolderButton
    )

    # Load Assembly
    Add-Type -AssemblyName System.Windows.Forms

    # Open Class
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog

    # Define Title
    $FolderBrowser.Description = $Description

    # Define Initial Directory
    if (-Not [String]::IsNullOrWhiteSpace($SelectedPath)) {
        $FolderBrowser.SelectedPath = $SelectedPath
    }

    if ($FolderBrowser.ShowDialog() -eq "OK") {
        $Folder += $FolderBrowser.SelectedPath
    }
    return $Folder
}

function Get-SelecFolderPage {
    param([string]$Type, [string]$Architecture)

    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    Clear-Host
    Write-Host "=========================== Office Tool Plus ==========================="
    Write-Host
    Get-LString "SelLocation"
    Write-Host
    Write-Host "    1: $(Get-LString "LocationDesktop")"
    Write-Host "    2: $(Get-LString "LocationCustom")"
    Write-Host "    3: $(Get-LString "GoBack")"
    Write-Host
    $UserChoice = Read-Host "  $(Get-LString -Key "ChooseOP")"

    switch ($UserChoice) {
        "1" { $UserSpecifiedPath = $DesktopPath }
        "2" {
            Get-LString "SelLocationTip"
            $UserSpecifiedPath = Get-FolderName -SelectedPath $DesktopPath
            if ($null -eq $UserSpecifiedPath) {
                Get-SelecFolderPage -Type $Type -Architecture $Architecture
            }
        }
        3 { Get-Homepage }
        default { Get-SelecFolderPage -Type $Type -Architecture $Architecture }
    }
    Write-Host
    Get-OTP -DownloadURL "https://www.officetool.plus/redirect/download.php?type=$Type&arch=$Architecture" -SavePath $UserSpecifiedPath
}

function Get-DownloadPage {
    # Collect system information
    $OsVersion = [System.Environment]::OSVersion.VersionString
    $Arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
    $Arch = if ($Arch -Match "ARM64") { "ARM64" } elseif ($Arch -Match "64") { "x64" } else { "x86" }

    Clear-Host
    Write-Host "=========================== Office Tool Plus ==========================="
    Write-Host
    Write-Host "  $(Get-LString "OSInfo") $OsVersion $Arch"
    Write-Host
    if (Get-RuntimeVersion -eq $true) {
        $Type = "normal"
        Write-Host $([string]::Format($(Get-LString "DownNormal"), $Arch))
    }
    else {
        $Type = "runtime"
        Write-Host $([string]::Format($(Get-LString "DownRuntime"), $Arch))
    }
    Get-SelecFolderPage -Type $Type -Architecture $Arch
}

function Get-SelectEditionPage {
    # Collect system information
    $OsVersion = [System.Environment]::OSVersion.VersionString
    $Arch = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
    $Arch = if ($Arch -Match "ARM64") { "ARM64" } elseif ($Arch -Match "64") { "x64" } else { "x86" }
    $Type = "runtime"

    Clear-Host
    Write-Host "=========================== Office Tool Plus ==========================="
    Write-Host
    Write-Host "  $(Get-LString "OSInfo") $OsVersion $Arch"
    Write-Host
    Get-LString "SelToDownload"
    Write-Host
    Write-Host "    1: $(Get-LString "DownSelx64Runtime")"
    Write-Host "    2: $(Get-LString "DownSelx86Runtime")"
    Write-Host "    3: $(Get-LString "DownSelArm64Runtime")"
    Write-Host "    4: $(Get-LString "DownSelx64")"
    Write-Host "    5: $(Get-LString "DownSelx86")"
    Write-Host "    6: $(Get-LString "DownSelArm64")"
    Write-Host
    Write-Host "    7: $(Get-LString "GoBack")"
    Write-Host
    $UserChoice = Read-Host "  $(Get-LString -Key "ChooseOP")"
    switch ($UserChoice) {
        "1" { $Arch = "x64" }
        "2" { $Arch = "x86" }
        "3" { $Arch = "arm64" }
        "4" {
            $Arch = "x64"
            $Type = "normal"
        }
        "5" {
            $Arch = "x86"
            $Type = "normal"
        }
        "6" {
            $Arch = "arm64"
            $Type = "normal"
        }
        "7" { Get-Homepage }
        default { Get-SelectEditionPage }
    }
    Get-SelecFolderPage -Type $Type -Architecture $Arch
}

function Set-Language {
    Clear-Host
    Write-Host "=========================== Office Tool Plus ==========================="
    Write-Host
    Write-Host "  Please choose a language:"
    Write-Host
    Write-Host "    1: English (United States)"
    Write-Host "    2: 简体中文（中国）"
    Write-Host
    $UserChoice = Read-Host "  Please enter a number"
    switch ($UserChoice) {
        "1" { $CurrentLang = "en_US" }
        "2" { $CurrentLang = "zh_Hans_CN" }
        default { Set-Language }
    }
    Get-Homepage
}

function Get-Homepage {
    Clear-Host
    Write-Host "=========================== Office Tool Plus ==========================="
    Write-Host
    Get-LString -Key "HomeSelOP"
    Write-Host
    Write-Host "    1: $(Get-LString "HomeOP1")"
    Write-Host "    2: $(Get-LString "HomeOP2")"
    Write-Host "    3: Choose language"
    Write-Host "    4: $(Get-LString "HomeOP4")"
    Write-Host
    $UserChoice = Read-Host "  $(Get-LString -Key "ChooseOP")"
    switch ($UserChoice) {
        "1" { Get-DownloadPage }
        "2" { Get-SelectEditionPage }
        "3" { Set-Language }
        "4" { Exit }
        default { Get-Homepage }
    }
}

Get-Homepage
