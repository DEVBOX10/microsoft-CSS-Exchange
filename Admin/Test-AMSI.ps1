﻿# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

<#

.SYNOPSIS
	The Windows AntiMalware Scan Interface (AMSI) is a versatile standard that allows applications and services to integrate with any AntiMalware product present on a machine. Seeing that Exchange administrators might not be familiar with AMSI, we wanted to provide a script that would make life a bit easier to test, enable, disable, or Check your AMSI Providers.
.DESCRIPTION
	The Windows AntiMalware Scan Interface (AMSI) is a versatile standard that allows applications and services to integrate with any AntiMalware product present on a machine. Seeing that Exchange administrators might not be familiar with AMSI, we wanted to provide a script that would make life a bit easier to test, enable, disable, or Check your AMSI Providers.
.PARAMETER TestAMSI
	If you want to test to see if AMSI integration is working. You can use a server, server list or FQDN of load balanced array of Client Access servers.
.PARAMETER IgnoreSSL
    If you need to test and ignoring the certificate check.
.PARAMETER CheckAMSIConfig
    If you want to see what AMSI Providers are installed. You can combine with ServerList, AllServers or Sites.
.PARAMETER EnableAMSI
    If you want to enable AMSI. Without any additional parameter it will apply at Organization Level. If combine with ServerList, AllServers or Sites it will apply at server level.
.PARAMETER DisableAMSI
    If you want to disable AMSI. Without any additional parameter it will apply at Organization Level. If combine with ServerList, AllServers or Sites it will apply at server level.
.PARAMETER RestartIIS
    If you want to restart the Internet Information Services (IIS). You can combine with ServerList, AllServers or Sites.
.PARAMETER Force
    If you want to restart the Internet Information Services (IIS) without confirmation.
.PARAMETER ServerList
    If you want to apply to some specific servers.
.PARAMETER AllServers
    If you want to apply to all server.
.PARAMETER Sites
    If you want to apply to all server on a sites or list of sites.


.EXAMPLE
    .\Test-AMSI.ps1 mail.contoso.com
    If you want to test to see if AMSI integration is working in a LB Array

.EXAMPLE
    .\Test-AMSI.ps1 -ServerList server1, server2
    If you want to test to see if AMSI integration is working in list of servers.

.EXAMPLE
    .\Test-AMSI.ps1 -AllServers
    If you want to test to see if AMSI integration is working in all server.

.EXAMPLE
    .\Test-AMSI.ps1 -AllServers -Sites Site1, Site2
    If you want to test to see if AMSI integration is working in all server in a list of sites.

.EXAMPLE
    .\Test-AMSI.ps1 -IgnoreSSL
    If you need to test and ignoring the certificate check.

.EXAMPLE
    .\Test-AMSI.ps1 CheckAMSIConfig
    If you want to see what AMSI Providers are installed on the local machine.

.EXAMPLE
    .\Test-AMSI.ps1 -EnableAMSI
    If you want to enable AMSI at organization level.

.EXAMPLE
    .\Test-AMSI.ps1 -EnableAMSI -ServerList Exch1, Exch2
    If you want to enable AMSI in an Exchange Server or Server List at server level.

.EXAMPLE
    .\Test-AMSI.ps1 -EnableAMSI -AllServers
    If you want to enable AMSI in all Exchange Server at server level.

.EXAMPLE
    .\Test-AMSI.ps1 -EnableAMSI -AllServers -Sites Site1, Site2
    If you want to enable AMSI in all Exchange Server in a site or sites at server level.

.EXAMPLE
    .\Test-AMSI.ps1 -DisableAMSI
    If you want to disable AMSI on the Exchange Server.

.EXAMPLE
    .\Test-AMSI.ps1 -DisableAMSI -ServerList Exch1, Exch2
    If you want to disable AMSI in an Exchange Server or Server List at server level.

.EXAMPLE
    .\Test-AMSI.ps1 -DisableAMSI -AllServers
    If you want to disable AMSI in all Exchange Server at server level.

.EXAMPLE
    .\Test-AMSI.ps1 -DisableAMSI -AllServers -Sites Site1, Site2
    If you want to disable AMSI in all Exchange Server in a site or sites at server level.

.EXAMPLE
    .\Test-AMSI.ps1 -RestartIIS
    If you want to restart the Internet Information Services (IIS).

.EXAMPLE
    .\Test-AMSI.ps1 -RestartIIS -Force
    If you want to restart the Internet Information Services (IIS) without confirmation.

#>

[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "TestAMSI", HelpUri = "https://microsoft.github.io/CSS-Exchange/Admin/Test-AMSI/")]
param(
    [Parameter(ParameterSetName = 'TestAMSI', Mandatory = $false)]
    [Parameter(ParameterSetName = 'TestAMSIAll', Mandatory = $false)]
    [switch]$TestAMSI,
    [Parameter(ParameterSetName = 'TestAMSI', Mandatory = $false)]
    [Parameter(ParameterSetName = 'TestAMSIAll', Mandatory = $false)]
    [switch]$IgnoreSSL,
    [Parameter(ParameterSetName = 'CheckAMSIConfig', Mandatory = $true)]
    [Parameter(ParameterSetName = 'CheckAMSIConfigAll', Mandatory = $true)]
    [switch]$CheckAMSIConfig,
    [Parameter(ParameterSetName = 'EnableAMSI', Mandatory = $true)]
    [Parameter(ParameterSetName = 'EnableAMSIAll', Mandatory = $true)]
    [switch]$EnableAMSI,
    [Parameter(ParameterSetName = 'DisableAMSI', Mandatory = $true)]
    [Parameter(ParameterSetName = 'DisableAMSIAll', Mandatory = $true)]
    [switch]$DisableAMSI,
    [Parameter(ParameterSetName = 'RestartIIS', Mandatory = $true)]
    [Parameter(ParameterSetName = 'RestartIISAll', Mandatory = $true)]
    [switch]$RestartIIS,
    [Alias("ExchangeServerFQDN")]
    [Parameter(ParameterSetName = 'TestAMSI', Mandatory = $false, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = 'EnableAMSI', Mandatory = $false, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = 'DisableAMSI', Mandatory = $false, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = 'CheckAMSIConfig', Mandatory = $false, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = 'RestartIIS', Mandatory = $false, ValueFromPipeline = $true)]
    [string[]]$ServerList = $null,
    [Parameter(ParameterSetName = 'TestAMSIAll', Mandatory = $true)]
    [Parameter(ParameterSetName = 'CheckAMSIConfigAll', Mandatory = $true)]
    [Parameter(ParameterSetName = 'EnableAMSIAll', Mandatory = $true)]
    [Parameter(ParameterSetName = 'DisableAMSIAll', Mandatory = $true)]
    [Parameter(ParameterSetName = 'RestartIISAll', Mandatory = $true)]
    [switch]$AllServers,
    [Parameter(ParameterSetName = 'TestAMSIAll', Mandatory = $false)]
    [Parameter(ParameterSetName = 'CheckAMSIConfigAll', Mandatory = $false)]
    [Parameter(ParameterSetName = 'EnableAMSIAll', Mandatory = $false)]
    [Parameter(ParameterSetName = 'DisableAMSIAll', Mandatory = $false)]
    [Parameter(ParameterSetName = 'RestartIISAll', Mandatory = $false)]
    [string[]]$Sites = $null,
    [Parameter(ParameterSetName = 'RestartIIS', Mandatory = $false)]
    [Parameter(ParameterSetName = 'RestartIISAll', Mandatory = $false)]
    [switch]$Force,
    [Parameter(ParameterSetName = 'TestAMSI', Mandatory = $false)]
    [Parameter(ParameterSetName = 'TestAMSIAll', Mandatory = $false)]
    [Parameter(ParameterSetName = 'CheckAMSIConfig', Mandatory = $false)]
    [Parameter(ParameterSetName = 'CheckAMSIConfigAll', Mandatory = $false)]
    [Parameter(ParameterSetName = 'EnableAMSI', Mandatory = $false)]
    [Parameter(ParameterSetName = 'EnableAMSIAll', Mandatory = $false)]
    [Parameter(ParameterSetName = 'DisableAMSI', Mandatory = $false)]
    [Parameter(ParameterSetName = 'DisableAMSIAll', Mandatory = $false)]
    [Parameter(ParameterSetName = 'RestartIIS', Mandatory = $false)]
    [Parameter(ParameterSetName = 'RestartIISAll', Mandatory = $false)]
    [switch]$SkipVersionCheck,
    [Parameter(Mandatory = $true, ParameterSetName = "ScriptUpdateOnly")]
    [switch]$ScriptUpdateOnly
)

begin {

    . $PSScriptRoot\..\Shared\Confirm-Administrator.ps1
    . $PSScriptRoot\..\Shared\Confirm-ExchangeShell.ps1
    . $PSScriptRoot\..\Shared\Invoke-ScriptBlockHandler.ps1
    . $PSScriptRoot\..\Shared\CertificateFunctions\Enable-TrustAnyCertificateCallback.ps1
    . $PSScriptRoot\..\Shared\ScriptUpdateFunctions\Test-ScriptVersion.ps1
    . $PSScriptRoot\..\Shared\Get-ExchangeBuildVersionInformation.ps1

    function CheckServerAMSI {
        param(
            [Parameter(Mandatory = $true)]
            [string]$ExchangeServer,
            [Parameter(Mandatory = $false)]
            [switch]$isServer
        )

        try {
            $CookieContainer = New-Object Microsoft.PowerShell.Commands.WebRequestSession
            $Cookie = New-Object System.Net.Cookie("X-BEResource", "a]@$($ExchangeServer):444/ecp/proxyLogon.ecp#~1941997017", "/", "$ExchangeServer")
            $CookieContainer.Cookies.Add($Cookie)
            $testTime = Get-Date
            Write-Host "Starting test at $($testTime -f "yyyy-MM-dd HH:mm:ss")"
            if ($IgnoreSSL -and ![System.Net.ServicePointManager]::ServerCertificateValidationCallback) {
                Enable-TrustAnyCertificateCallback
            }
            Invoke-WebRequest https://$ExchangeServer/ecp/x.js -Method POST -Headers @{ "Host" = "$ExchangeServer" } -WebSession $CookieContainer
        } catch [System.Net.WebException] {
            $Message = ($_.Exception.Message).ToString().Trim()
            $currentForegroundColor = $host.ui.RawUI.ForegroundColor
            if ($_.Exception.Message -eq "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel.") {
                $host.ui.RawUI.ForegroundColor = "Red"
                Write-Host $Message
                $host.ui.RawUI.ForegroundColor = "Yellow"
                Write-Host "You could use the -IgnoreSSL parameter"
                $host.ui.RawUI.ForegroundColor = $currentForegroundColor
            } elseif ($_.Exception.Message -eq "The remote server returned an error: (400) Bad Request.") {
                $host.ui.RawUI.ForegroundColor = "Green"
                Write-Host "We sent an test request to the ECP Virtual Directory of the server requested"
                $host.ui.RawUI.ForegroundColor = "Yellow"
                Write-Host "The remote server returned an error: (400) Bad Request"
                $host.ui.RawUI.ForegroundColor = "Green"
                $host.ui.RawUI.ForegroundColor = "Yellow"
                Write-Host "This may be indicative of a potential block from AMSI"
                $host.ui.RawUI.ForegroundColor = "Green"
                if ($isServer) {
                    $getMSIInstallPathSB = { (Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\v15\Setup -ErrorAction SilentlyContinue).MsiInstallPath }
                    $ExchangePath = Invoke-ScriptBlockHandler -ComputerName $ExchangeServer -ScriptBlock $getMSIInstallPathSB
                    $msgCheckLogs = "You can check your log files located in $($ExchangePath)Logging\HttpRequestFiltering\"
                } else {
                    $msgCheckLogs = "You can check your log files located in %ExchangeInstallPath%\Logging\HttpRequestFiltering\ in all server included in $ExchangeServer endpoint"
                }
                Write-Host $msgCheckLogs
                $host.ui.RawUI.ForegroundColor = $currentForegroundColor
                $msgDetectedTimeStamp = "You should find result around $((Get-Date).ToUniversalTime().ToString("M/d/yyy h:mm:ss tt")) UTC"
                Write-Host $msgDetectedTimeStamp
                if ($isServer) {
                    Write-Host ""
                    Write-Host "Checking logs on $server at $($testTime.ToString("M/d/yyy h:mm:ss tt"))"
                    $HttpRequestFilteringLogFolder = $null

                    if ($ExchangePath) {
                        if ($server.ToLower() -eq $env:COMPUTERNAME.ToLower()) {
                            $HttpRequestFilteringLogFolder = Join-Path $ExchangePath "Logging\HttpRequestFiltering\"
                        } else {
                            $HttpRequestFilteringLogFolder = Join-Path "\\$server\$($ExchangePath.Replace(':','$'))" "Logging\HttpRequestFiltering\"
                        }
                    } else {
                        Write-Host "Cannot get Exchange installation path on $server" -ForegroundColor Red
                    }

                    if (Test-Path $HttpRequestFilteringLogFolder -PathType Container) {
                        $file = $null
                        $timeout = (Get-Date).AddMinutes(1)
                        $detected = $false
                        $marginTime = New-TimeSpan -Seconds 5
                        do {
                            Start-Sleep -Seconds 2
                            $file = $null
                            $file = Get-ChildItem $HttpRequestFilteringLogFolder -Filter "HttpRequestFiltering_*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -Property *
                            if ($file) {
                                $csv = Import-Csv $file.FullName
                                foreach ($line in $csv) {
                                    $DateTime = $null
                                    try {
                                        $DateTime = [DateTime]::ParseExact($line.DateTime, 'M/d/yyyy h:mm:ss tt', $null)
                                    } catch {
                                        Write-Verbose ("We could not parse the date time on: {0}" -f $line)
                                    }
                                    if ($DateTime) {
                                        if (($testTime.ToUniversalTime().Subtract($DateTime) -lt $marginTime) -and
                                            ($testTime.ToUniversalTime().Subtract($DateTime) -gt - $marginTime)) {
                                            if (($line.UrlHost.ToLower() -eq $server.ToLower()) -and
                                                ($line.UrlStem.ToLower() -eq '/ecp/x.js'.ToLower()) -and
                                                ($line.ScanResult.ToLower() -eq 'Detected'.ToLower())) {
                                                Write-Host ""
                                                Write-Host "We found a detection in HttpRequestFiltering logs: " -ForegroundColor Green
                                                Write-Host "$line"
                                                $detected = $true
                                            }
                                        }
                                    }
                                }
                            }
                        } while ((-not $detected) -and ((Get-Date) -lt $timeout))
                        if ((Get-Date) -ge $timeout) {
                            Write-Warning  "We have not found activity on the server in the last minute."
                        }
                        if (-not $detected) {
                            Write-Warning "We have not found a detection."
                        }
                    } else {
                        Write-Host "We could not access HttpRequestFiltering folder on $server" -ForegroundColor Red
                    }
                } else {
                    Write-Host "Check your log files located in %ExchangeInstallPath%\Logging\HttpRequestFiltering\ in all server that provide $server endpoint"
                }
            } elseif ($_.Exception.Message -eq "The remote server returned an error: (500) Internal Server Error.") {
                $host.ui.RawUI.ForegroundColor = "Red"
                Write-Host $msgNewLine
                Write-Host $Message
                Write-Host $msgNewLine
                $host.ui.RawUI.ForegroundColor = "Yellow"
                Write-Host "If you are using Microsoft Defender, RealTime protection could be disabled or then AMSI may be disabled."
                Write-Host "If you are using a 3rd Party AntiVirus Product that may not be AMSI capable (Please Check with your AntiVirus Provider for Exchange AMSI Support)"
                $host.ui.RawUI.ForegroundColor = $currentForegroundColor
            } elseif ($_.Exception.Message.StartsWith("The remote name could not be resolved:")) {
                $host.ui.RawUI.ForegroundColor = "Red"
                Write-Host $msgNewLine
                Write-Host $Message
                Write-Host $msgNewLine
                $host.ui.RawUI.ForegroundColor = $currentForegroundColor
            } else {
                $host.ui.RawUI.ForegroundColor = "Red"
                Write-Host $msgNewLine
                Write-Host $Message
                Write-Host $msgNewLine
                $host.ui.RawUI.ForegroundColor = "Yellow"
                Write-Host "If you are using Microsoft Defender, RealTime protection could be disabled or then AMSI may be disabled."
                Write-Host "If you are using a 3rd Party AntiVirus Product that may not be AMSI capable (Please Check with your AntiVirus Provider for Exchange AMSI Support)"
                $host.ui.RawUI.ForegroundColor = $currentForegroundColor
            }
        } finally {
            if ($IgnoreSSL) {
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
                try {
                    Invoke-WebRequest https://$ExchangeServer -TimeoutSec 1 -ErrorAction SilentlyContinue | Out-Null
                } catch {
                    Write-Verbose "We could not connect to https://$ExchangeServer (Expected)"
                }
            }
        }
        Write-Host "Ended test at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
    }

    function CheckAMSIConfig {
        param(
            [Parameter(Mandatory = $true)]
            [string]$ExchangeServer
        )

        Write-Host ""
        Write-Host "AMSI Providers detection:" -ForegroundColor Green

        $AMSIProvidersSB = {
            $AMSIProviders = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\AMSI\Providers' -Recurse -ErrorAction SilentlyContinue
            if ($AMSIProviders) {
                Write-Host "Providers:"
                $AMSIProviders.Name | Out-Host
                $providerCount = 0
                foreach ($provider in $AMSIProviders) {
                    $provider -match '[0-9A-Fa-f\-]{36}' | Out-Null
                    foreach ($m in $Matches.Values) {
                        $key = "HKLM:\SOFTWARE\Classes\ClSid\{$m}"
                        $providers = $null
                        $providers = Get-ChildItem $key -ErrorAction SilentlyContinue
                        if ($providers) {
                            $providerCount++
                            Write-Host ""
                            Write-Host "Provider $($providerCount):"
                            $providers | Format-Table -AutoSize | Out-Host
                            $path = $null
                            $path = ($providers | Where-Object { $_.PSChildName -eq 'InprocServer32' }).GetValue('')
                            if ($path) {
                                $WindowsDefenderPath = $path.Substring(1, $path.LastIndexOf("\"))
                                if ($WindowsDefenderPath -like '*Windows Defender*') {
                                    Write-Host "Windows Defender with AMSI integration found." -ForegroundColor Green
                                    $checkCmdLet = $null
                                    $checkCmdLet = Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue
                                    if ($null -eq $checkCmdLet) {
                                        Write-Warning "Get-MpComputerStatus cmdLet is not available"
                                    } else {
                                        if ((Get-MpComputerStatus).RealTimeProtectionEnabled) {
                                            Write-Host "Windows Defender has Real Time Protection Enabled" -ForegroundColor Green
                                        } else {
                                            Write-Warning "Windows Defender has Real Time Protection Disabled"
                                        }
                                    }
                                    Write-Host "It should be version 1.1.18300.4 or newest."
                                    if (Test-Path $WindowsDefenderPath -PathType Container) {
                                        $folder = Get-ChildItem  $WindowsDefenderPath | Sort-Object LastWriteTime -Descending | Select-Object -First 1
                                        $process = Join-Path $folder.FullName "MpCmdRun.exe"
                                        if (Test-Path $process -PathType Leaf) {
                                            $DefenderVersion = $null
                                            $DefenderVersion = [System.Version]::new((& $process -SignatureUpdate | Where-Object { $_.StartsWith('Engine Version:') }).Split(' ')[2])
                                            if ($DefenderVersion) {
                                                if (($DefenderVersion.Major -gt 1) -or
                                                     (($DefenderVersion.Major -eq 1) -and ($DefenderVersion.Minor -gt 1)) -or
                                                     (($DefenderVersion.Major -eq 1) -and ($DefenderVersion.Minor -eq 1) -and ($DefenderVersion.Build -gt 18300)) -or
                                                     (($DefenderVersion.Major -eq 1) -and ($DefenderVersion.Minor -eq 1) -and ($DefenderVersion.Build -eq 18300) -and ($DefenderVersion.Revision -ge 4))) {
                                                    Write-Host "Windows Defender version supported for AMSI: $DefenderVersion" -ForegroundColor Green
                                                } else {
                                                    Write-Warning  "Windows Defender version Non-supported for AMSI: $DefenderVersion"
                                                }
                                            } else {
                                                Write-Warning  "We could not get Windows Defender version "
                                            }
                                        } else {
                                            Write-Warning  "We did not find Windows Defender MpCmdRun.exe."
                                        }
                                    } else {
                                        Write-Warning "We did not find Windows Defender Path."
                                    }
                                } else {
                                    Write-Warning "It is not Windows Defender AV, check with your provider."
                                }
                            } else {
                                Write-Warning "We did not find AMSI providers."
                            }
                        } else {
                            Write-Host "We did not find any AMSI provider on ClSid for $m" -ForegroundColor Red
                        }
                    }
                }
            } else {
                Write-Host " We did not find any AMSI provider" -ForegroundColor Red
            }
        }

        Write-Host ""
        "Checking AMSI Provider on $ExchangeServer"
        Write-Host ""
        Invoke-ScriptBlockHandler -ComputerName $ExchangeServer -ScriptBlock $AMSIProvidersSB

        $getSO = $null
        $getSO = Get-SettingOverride -ErrorAction SilentlyContinue | Where-Object {
            ($_.ComponentName.ToLower() -eq 'Cafe'.ToLower()) -and
            ($_.SectionName.ToLower() -eq 'HttpRequestFiltering'.ToLower()) -and
            ($_.Parameters.ToLower() -eq 'Enabled=False'.ToLower()) -and
            ($_.Server.ToLower() -contains $ExchangeServer.ToLower()) }
        if ($getSO) {
            $getSO | Out-Host
            if ($getSO.Status -eq "Accepted") {
                Write-Warning "AMSI is Disabled by $($getSO.Identity) SettingOverride for $ExchangeServer"
            } else {
                Write-Host "We found SettingOverride for $ExchangeServer ($($getSO.Identity))"
                Write-Warning "The Status of $($getSO.Identity) is not Accepted. Should not apply for $ExchangeServer."
            }
        } else {

            $FEEcpWebConfig = $null
            $CAEEcpWebConfig = $null

            $getMSIInstallPathSB = { (Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ExchangeServer\v15\Setup -ErrorAction SilentlyContinue).MsiInstallPath }
            $ExchangePath = Invoke-ScriptBlockHandler -ComputerName $ExchangeServer -ScriptBlock $getMSIInstallPathSB

            if ($ExchangePath) {
                if ($ExchangeServer.ToLower() -eq $env:COMPUTERNAME.ToLower()) {
                    $FEEcpWebConfig = Join-Path $ExchangePath "FrontEnd\HttpProxy\ecp\web.config"
                    $CAEEcpWebConfig = Join-Path $ExchangePath "ClientAccess\ecp\web.config"
                } else {
                    $FEEcpWebConfig = Join-Path "\\$ExchangeServer\$($ExchangePath.Replace(':','$'))" "FrontEnd\HttpProxy\ecp\web.config"
                    $CAEEcpWebConfig = Join-Path "\\$ExchangeServer\$($ExchangePath.Replace(':','$'))" "ClientAccess\ecp\web.config"
                }

                if ($FEEcpWebConfig -and $CAEEcpWebConfig) {
                    if (Test-Path $FEEcpWebConfig -PathType Leaf) {
                        $FEFilterModule = $null
                        $FEFilterModule = Get-Content $FEEcpWebConfig | Select-String '<add name="HttpRequestFilteringModule" type="Microsoft.Exchange.HttpRequestFiltering.HttpRequestFilteringModule, Microsoft.Exchange.HttpRequestFiltering, Version=15.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"'
                        Write-Host ""
                        if ($FEFilterModule) {
                            Write-Host "We found HttpRequestFilteringModule on FrontEnd ECP web.config" -ForegroundColor Green
                            Write-Host "Path: $($ExchangePath)FrontEnd\HttpProxy\ecp\web.config"
                        } else {
                            Write-Warning "We did not find HttpRequestFilteringModule on FrontEnd ECP web.config"
                            Write-Warning "Path: $($ExchangePath)FrontEnd\HttpProxy\ecp\web.config"
                        }
                    } else {
                        Write-Warning "We did not find web.config for FrontEnd ECP"
                        Write-Warning "Path: $($ExchangePath)FrontEnd\HttpProxy\ecp\web.config"
                    }

                    if (Test-Path $FEEcpWebConfig -PathType Leaf) {
                        $CEFilterModule = $null
                        $CEFilterModule = Get-Content $CAEEcpWebConfig | Select-String '<add name="HttpRequestFilteringModule" type="Microsoft.Exchange.HttpRequestFiltering.HttpRequestFilteringModule, Microsoft.Exchange.HttpRequestFiltering, Version=15.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"'
                        Write-Host ""
                        if ($CEFilterModule) {
                            Write-Host "We found HttpRequestFilteringModule on ClientAccess ECP web.config" -ForegroundColor Green
                            Write-Host "Path: $($ExchangePath)ClientAccess\ecp\web.config"
                        } else {
                            Write-Warning "We did not find HttpRequestFilteringModule on ClientAccess ECP web.config"
                            Write-Warning "Path: $($ExchangePath)ClientAccess\ecp\web.config"
                        }
                    } else {
                        Write-Warning "We did not find web.config for ClientAccess ECP"
                        Write-Warning "Path: $($ExchangePath)ClientAccess\ecp\web.config"
                    }
                } else {
                    Write-Host "We could not get FrontEnd or BackEnd Web.config path on $ExchangeServer." -ForegroundColor Red
                }
            } else {
                Write-Host "Cannot get Exchange installation path on $server" -ForegroundColor Red
            }

            Write-Host $msgNewLine
            Write-Host "AMSI is Enabled on Server $ExchangeServer." -ForegroundColor Green
            Write-Host "We did not find any Settings Override that remove AMSI on server $ExchangeServer."
            Write-Host ""
        }
    }
}

process {

    $BuildVersion = ""

    Write-Host ("Test-AMSI.ps1 script version $($BuildVersion)") -ForegroundColor Green

    if ($ScriptUpdateOnly) {
        switch (Test-ScriptVersion -AutoUpdate -VersionsUrl "https://aka.ms/Test-AMSI-VersionsURL" -Confirm:$false) {
        ($true) { Write-Host ("Script was successfully updated") -ForegroundColor Green }
        ($false) { Write-Host ("No update of the script performed") -ForegroundColor Yellow }
            default { Write-Host ("Unable to perform ScriptUpdateOnly operation") -ForegroundColor Red }
        }
        return
    }

    if ((-not($SkipVersionCheck)) -and
    (Test-ScriptVersion -AutoUpdate -VersionsUrl "https://aka.ms/Test-AMSI-VersionsURL" -Confirm:$false)) {
        Write-Host ("Script was updated. Please re-run the command") -ForegroundColor Yellow
        return
    }

    $msgNewLine = "`n"
    if (-not (Confirm-Administrator)) {
        Write-Host $msgNewLine
        Write-Warning "This script needs to be executed in elevated mode. Start the Exchange Management Shell as an Administrator and try again."
        exit
    }

    $exchangeShell = Confirm-ExchangeShell
    if (-not($exchangeShell.ShellLoaded)) {
        Write-Host $msgNewLine
        Write-Warning "Failed to load Exchange Shell Module..."
        exit
    }

    if ((Get-ExchangeServer $env:COMPUTERNAME).IsEdgeServer) {
        Write-Host $msgNewLine
        Write-Warning "This script cannot be executed in an Edge Server."
        exit
    }

    $bar = ""
    1..($Host.UI.RawUI.WindowSize.Width) | ForEach-Object { $bar += "-" }
    Write-Host ""
    Write-Host $bar

    $filterList = @()

    if ($PSCmdlet.ParameterSetName -eq "TestAMSI" -or $PSCmdlet.ParameterSetName -eq "TestAMSIAll") {
        $TestAMSI = $true
    }

    if ($null -eq $ServerList -and ($RestartIIS -or $CheckAMSIConfig -or $TestAMSI) -and (-not $AllServers)) {
        $ServerList = $env:COMPUTERNAME
    }

    Write-Host ""
    Write-Host "AMSI only support on Exchange 2016 CU21 or newer, Exchange 2019 CU10 or newer and running on Windows 2016 or newer" -ForegroundColor Green
    Write-Host ""

    $SupportedExchangeServers = Get-ExchangeServer | Where-Object {
        ($_.IsClientAccessServer) -and
        ((((Get-ExchangeBuildVersionInformation -AdminDisplayVersion ($_.adminDisplayVersion.ToString())).BuildVersion.Minor -eq 1) -and
            ((Get-ExchangeBuildVersionInformation -AdminDisplayVersion ($_.adminDisplayVersion.ToString())).BuildVersion.Build -ge 2308)) -or
          (((Get-ExchangeBuildVersionInformation -AdminDisplayVersion ($_.adminDisplayVersion.ToString())).BuildVersion.Minor -eq 2) -and
            ((Get-ExchangeBuildVersionInformation -AdminDisplayVersion ($_.adminDisplayVersion.ToString())).BuildVersion.Build -ge 922))) } |
        Select-Object Name, Site

    if ($Sites) {
        $uniqueSites = $null
        $uniqueSites = $SupportedExchangeServers.Site.Name | Get-Unique
        foreach ($site in $Sites) {
            if ($uniqueSites -notcontains $site) {
                Write-Warning "We did not find site $site"
            }
        }
        $fullList = ($SupportedExchangeServers | Where-Object { $Sites -contains $_.Site.Name } | Select-Object Name).Name
    } else {
        $fullList = ($SupportedExchangeServers | Select-Object Name).Name
    }

    $Version = $null
    if ($AllServers) {
        foreach ($server in $fullList) {
            $serverName = $server.Split('.')[0]
            if ($SupportedExchangeServers.Name -contains $serverName) {
                $Version = Invoke-ScriptBlockHandler -ComputerName $server -ScriptBlock { [System.Environment]::OSVersion.Version.Major }
                if ($Version) {
                    if ($Version -ge 10) {
                        $filterList += $serverName
                    } else {
                        Write-Warning "$server is not a Windows version with AMSI support."
                    }
                } else {
                    Write-Warning "We could not get Windows version for $server."
                    Write-Warning "Try to run the script locally."
                }
            } else {
                Write-Warning "$server is not an Exchange version with AMSI support."
            }
        }
    } else {
        foreach ($server in $ServerList) {
            $serverName = $server.Split('.')[0]
            if ($fullList -contains $serverName) {
                if ($SupportedExchangeServers.Name -contains $serverName) {
                    $Version = Invoke-ScriptBlockHandler -ComputerName $server -ScriptBlock { [System.Environment]::OSVersion.Version.Major }
                    if ($Version) {
                        if ($Version -ge 10) {
                            $filterList += $serverName
                        } else {
                            Write-Warning "$server is not a Windows version with AMSI support."
                        }
                    } else {
                        Write-Warning "We could not get Windows version for $server."
                        Write-Warning "Try to run the script locally."
                    }
                } else {
                    Write-Warning "$server is not an Exchange version with AMSI support."
                }
            } else {
                Write-Warning "We did not find any Exchange server with name: $server"
                if ($TestAMSI) {
                    $filterList += $server
                }
            }
        }
    }

    if ((($filterList.count -gt 0) -or
            $TestAMSI -or
           (($EnableAMSI -or $DisableAMSI) -and
            -not $ServerList)) -and
        $SupportedExchangeServers.count -gt 0) {

        if ($TestAMSI) {
            foreach ($server in $filterList) {
                Write-Host $bar
                Write-Host ""
                Write-Host "Testing $($server):" -ForegroundColor Magenta
                Write-Host ""
                if ($fullList -contains $server) {
                    CheckServerAMSI -ExchangeServer $server -isServer
                } else {
                    CheckServerAMSI -ExchangeServer $server
                }
                Write-Host ""
            }
        }

        if ($CheckAMSIConfig) {
            if ($filterList) {
                foreach ($server in $filterList) {
                    Write-Host $bar
                    Write-Host ""
                    Write-Host "Checking $($server):" -ForegroundColor Magenta
                    Write-Host ""
                    CheckAMSIConfig -ExchangeServer $server
                    Write-Host ""
                }
            }
            Write-Host $bar
            Write-Host ""
            $getSO = $null
            $getSO = Get-SettingOverride -ErrorAction SilentlyContinue | Where-Object {
                ($_.ComponentName.ToLower() -eq 'Cafe'.ToLower()) -and
                ($_.SectionName.ToLower() -eq 'HttpRequestFiltering'.ToLower()) -and
                ($_.Parameters.ToLower() -eq 'Enabled=False'.ToLower()) -and
                ($null -eq $_.Server) }
            if ($getSO) {
                $getSO | Out-Host
                if ($getSO.Status -eq "Accepted") {
                    Write-Warning "AMSI is Disabled by $($getSO.Identity) SettingOverride at organization Level."
                } else {
                    Write-Host "We found SettingOverride for $ExchangeServer ($($getSO.Identity))"
                    Write-Warning "The Status of $($getSO.Identity) is not Accepted. Should not apply at organization Level."
                }
            } else {
                Write-Host "AMSI is Enabled for Exchange at Organization Level." -ForegroundColor Green
                Write-Host "We did not find any Settings Override that remove AMSI at organization Level."
                Write-Host ""
            }
        }

        $needsRefresh = 0
        if ($EnableAMSI) {
            $getSO = $null
            if ($filterList) {
                foreach ($server in $filterList) {
                    Write-Host $bar
                    Write-Host ""
                    $getSO = $null
                    $getSO = Get-SettingOverride -ErrorAction SilentlyContinue | Where-Object {
                        ($_.ComponentName.ToLower() -eq 'Cafe'.ToLower()) -and
                        ($_.SectionName.ToLower() -eq 'HttpRequestFiltering'.ToLower()) -and
                        ($_.Parameters.ToLower() -eq 'Enabled=False'.ToLower()) -and
                        ($_.Server.ToLower() -contains $server.ToLower()) }
                    if ($null -eq $getSO) {
                        Write-Host "We did not find Get-SettingOverride that disabled AMSI on $server"
                        Write-Warning "AMSI is NOT disabled on $server"
                    } else {
                        if (-not $WhatIfPreference) { Write-Host "Removing SettingOverride $($getSO.Identity)" }
                        Remove-SettingOverride -Identity $getSO.Identity -Confirm:$false -WhatIf:$WhatIfPreference
                        $getSO | Out-Host
                        if (-not $WhatIfPreference) {
                            Write-Host "Removing SettingOverride $($getSO.Identity)"
                            Write-Host "Enabled on $server" -ForegroundColor Green
                            Get-ExchangeDiagnosticInfo -Process Microsoft.Exchange.Directory.TopologyService -Component VariantConfiguration -Argument Refresh -Server $server | Out-Null
                            Write-Host "Refreshed Get-ExchangeDiagnosticInfo on $server"
                            $needsRefresh++
                        }
                    }
                }
            } else {
                Write-Host $bar
                Write-Host ""
                $getSO = $null
                $getSO = Get-SettingOverride -ErrorAction SilentlyContinue | Where-Object {
                    ($_.ComponentName.ToLower() -eq 'Cafe'.ToLower()) -and
                    ($_.SectionName.ToLower() -eq 'HttpRequestFiltering'.ToLower()) -and
                    ($_.Parameters.ToLower() -eq 'Enabled=False'.ToLower()) -and
                    ($null -eq $_.Server) }
                if ($null -eq $getSO) {
                    Write-Host "We did not find Get-SettingOverride that disabled AMSI at Organization level"
                    Write-Warning "AMSI is NOT disabled on Exchange configuration at organization level"
                } else {
                    if (-not $WhatIfPreference) { Write-Host "Removing SettingOverride $($getSO.Identity)" }
                    $getSO | Out-Host
                    Remove-SettingOverride -Identity $getSO.Identity -Confirm:$false -WhatIf:$WhatIfPreference
                    if (-not $WhatIfPreference) {
                        Write-Host "Enabled AMSI at Organization Level" -ForegroundColor Green
                        foreach ($server in $filterList) {
                            Get-ExchangeDiagnosticInfo -Process Microsoft.Exchange.Directory.TopologyService -Component VariantConfiguration -Argument Refresh -Server $server | Out-Null
                            Write-Host "Refreshed Get-ExchangeDiagnosticInfo on $server"
                        }
                        $needsRefresh++
                    }
                }
            }
        }

        if ($DisableAMSI) {
            $getSO = $null
            if ($filterList) {
                foreach ($server in $filterList) {
                    Write-Host $bar
                    Write-Host ""
                    $getSO = $null
                    $getSO = Get-SettingOverride -ErrorAction SilentlyContinue | Where-Object {
                        ($_.ComponentName.ToLower() -eq 'Cafe'.ToLower()) -and
                        ($_.SectionName.ToLower() -eq 'HttpRequestFiltering'.ToLower()) -and
                        ($_.Parameters.ToLower() -eq 'Enabled=False'.ToLower()) -and
                        ($_.Server.ToLower() -contains $server.ToLower()) }
                    if ($null -eq $getSO) {
                        New-SettingOverride -Name "DisablingAMSIScan-$server" -Component Cafe -Section HttpRequestFiltering -Parameters ("Enabled=False") -Reason "Disabled via CSS-Exchange Script" -Server $server -WhatIf:$WhatIfPreference
                        if (-not $WhatIfPreference) {
                            Write-Warning "Disabled on $server by DisablingAMSIScan-$server SettingOverride"
                            Get-ExchangeDiagnosticInfo -Process Microsoft.Exchange.Directory.TopologyService -Component VariantConfiguration -Argument Refresh -Server $server | Out-Null
                            Write-Host "Refreshed Get-ExchangeDiagnosticInfo on $server"
                            $needsRefresh++
                        }
                    } else {
                        Write-Warning "AMSI is already disabled on Exchange configuration for $server by SettingOverride $($getSO.Identity)"
                    }
                }
            } else {
                Write-Host $bar
                Write-Host ""
                $getSO = $null
                $getSO = Get-SettingOverride -ErrorAction SilentlyContinue | Where-Object {
                    ($null -eq $_.Server) -and
                    ($_.ComponentName.ToLower() -eq 'Cafe'.ToLower()) -and
                    ($_.SectionName.ToLower() -eq 'HttpRequestFiltering'.ToLower()) -and
                    ($_.Parameters.ToLower() -eq 'Enabled=False'.ToLower()) }
                if ($null -eq $getSO) {
                    New-SettingOverride -Name DisablingAMSIScan-OrgLevel -Component Cafe -Section HttpRequestFiltering -Parameters ("Enabled=False") -Reason "Disabled via CSS-Exchange Script" -WhatIf:$WhatIfPreference
                    if (-not $WhatIfPreference) {
                        Write-Warning "Disabled AMSI at Organization Level by DisablingAMSIScan-OrgLevel SettingOverride"
                        foreach ($server in $filterList) {
                            Get-ExchangeDiagnosticInfo -Process Microsoft.Exchange.Directory.TopologyService -Component VariantConfiguration -Argument Refresh -Server $server | Out-Null
                            Write-Host "Refreshed Get-ExchangeDiagnosticInfo on $server"
                        }
                        $needsRefresh++
                    }
                } else {
                    Write-Warning "AMSI is already disabled on Exchange configuration by SettingOverride $($getSO.Identity)"
                }
            }
        }

        if ($needsRefresh -gt 0 -and ($SupportedExchangeServers.Site.Name | Get-Unique).count -gt 1) {
            Write-Host ""
            Write-Host $bar
            Write-Host ""
            Write-Warning "You have a multi site environment, confirm that all affected Exchange sites has replicated changes."
            Write-Host "You can push changes on your DCs with: repadmin /syncall /AdeP"
            Write-Host ""
            Write-Warning "Remember to restart IIS to be effective."
            Write-Host "You can accomplish this by running .\Test-AMSI.ps1 -RestartIIS"
            Write-Host ""
        }

        if ($RestartIIS) {
            if ($filterList) {
                $yesToAll = $false
                $noToAll = $false

                if ($Force -or $PSCmdlet.ShouldContinue("Are you sure you want to do it?", "This command wil restart the following IIS servers: $filterList", $true, [ref]$yesToAll, [ref]$noToAll)) {
                    foreach ($server in $filterList) {
                        Write-Host $msgNewLine
                        if ($Force -or $filterList.Count -eq 1 -or $PSCmdlet.ShouldContinue("Are you sure you want to do it?", "You will restart IIS on server $server", $true, [ref]$yesToAll, [ref]$noToAll)) {
                            if (-not $WhatIfPreference) {
                                Get-ExchangeDiagnosticInfo -Process Microsoft.Exchange.Directory.TopologyService -Component VariantConfiguration -Argument Refresh -Server $server | Out-Null
                                Write-Host "Refreshed Get-ExchangeDiagnosticInfo on $server"
                            }
                            if ($server.ToLower() -eq $env:COMPUTERNAME.ToLower()) {
                                if (-not $WhatIfPreference) { Write-Host "Restarting local IIS on $server" }
                                Get-Service W3SVC, WAS | Restart-Service -Force -WhatIf:$WhatIfPreference
                            } else {
                                if (-not $WhatIfPreference) { Write-Host "Restarting Remote IIS on $server" }
                                Get-Service W3SVC, WAS -ComputerName $server | Restart-Service -Force -WhatIf:$WhatIfPreference
                            }
                            if (-not $WhatIfPreference) { Write-Host "$server Restarted" }
                        }
                    }
                }
            }
        }
    } else {
        Write-Warning "We did not find Exchange servers with AMSI support"
    }
    Write-Host $bar
    Write-Host ""
    Write-Host 'You can find additional information at:'
    Write-Host 'https://aka.ms/ExchangeAMSI' -ForegroundColor Cyan
    Write-Host $msgNewLine
}
