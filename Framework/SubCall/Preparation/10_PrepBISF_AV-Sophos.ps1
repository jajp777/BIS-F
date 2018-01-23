<#
    .SYNOPSIS
        Prepare Sophos AntiVirus for Image Managemement
	.Description
		  Stop antivirus related services
		  Start a full antivirus scan
		  Remove computer specific entries
    .EXAMPLE
    .Inputs
    .Outputs
    .NOTES
		Author: Matthias Schlimm
      	Company: Login Consultants Germany GmbH
		
		History
      	Last Change: 09.01.2017 MS: Script created
		Last Change: 20.02.2017 MS: fix typos to get the right servicename -> $ServiceNames[0]
		Last Change: 06.03.2017 MS: Bugfix read Variable $varCLI = ...
	.Link
#>

Begin {
	$script_path = $MyInvocation.MyCommand.Path
	$script_dir = Split-Path -Parent $script_path
	$script_name = [System.IO.Path]::GetFileName($script_path)

	# Product specific
	$Product = "Sophos Endpoint Security and Control"
	$ProductInstPath = "$ProgramFilesx86\Sophos\Sophos Anti-Virus"
	$ServiceNames = @("Sophos Agent","Sophos AutoUpdate Service","Sophos Message Router")
	
	[array]$ToDelete = @(
        [pscustomobject]@{type="REG";value="HKLM:\SOFTWARE\Wow6432Node\Sophos\Messaging System\Router\Private";data="pkc"},
		[pscustomobject]@{type="REG";value="HKLM:\SOFTWARE\Wow6432Node\Sophos\Messaging System\Router\Private";data="pkp"},
		[pscustomobject]@{type="REG";value="HKLM:\SOFTWARE\Wow6432Node\Sophos\Remote Management System\ManagementAgent\Private";data="pkc"},
		[pscustomobject]@{type="REG";value="HKLM:\SOFTWARE\Wow6432Node\Sophos\Remote Management System\ManagementAgent\Private";data="pkp"},
		[pscustomobject]@{type="FILE";value="C:\ProgramData\Sophos\AutoUpdate\data";data="machine_ID.txt"},
		[pscustomobject]@{type="FILE";value="C:\ProgramData\Sophos\AutoUpdate\data\status";data="status.xml"}
	)	
}

Process {
####################################################################
####### functions #####
####################################################################

	
	function RunFullScan
	{
	
	Write-BISFLog -Msg "Check Silentswitch..."
		$varCLI = $LIC_BISF_CLI_AV
		If (($varCLI -eq "YES") -or ($varCLI -eq "NO")) 
		{
			Write-BISFLog -Msg "Silentswitch would be set to $varCLI"
		} Else {
           	Write-BISFLog -Msg "Silentswitch not defined, show MessageBox"
			$MPFullScan = Show-BISFMessageBox -Msg "Would you like to to run a Full Scan ? " -Title "$Product" -YesNo -Question
        	Write-BISFLog -Msg "$MPFullScan would be choosen [YES = Running Full Scan] [NO = No scan will be performed]"
		}
        If (($MPFullScan -eq "YES" ) -or ($varCLI -eq "YES"))
		{
			Write-BISFLog -Msg "Running Fullscan... please Wait"
			Start-Process -FilePath "$ProductInstPath\sav32cli.exe" -ArgumentList "-f"
			If ($OSBitness -eq "32-bit") {$ScanProcess="sav32cli"} Else {$ScanProcess="sav32cli"}
			Show-BISFProgressBar -CheckProcess "$ScanProcess" -ActivityText "$Product is scanning the system...please wait"
		} Else {
			Write-BISFLog -Msg "No Full Scan would be performed"
		}
	
	}
    
	function deleteData
    {
		Write-BISFLog -Msg "Delete specific items "	
		Foreach ($2Delete in $ToDelete)
		{
			If ($2Delete.type -eq "REG")
			{
				Write-BISFLog -Msg "Processing Registry-Items to delete" -ShowConsole -SubMsg -color DarkCyan
				$Check2Delete = Test-BISFRegistryValue -Path $2Delete.value -Value $2Delete.data
				If ($Check2Delete) {
					Write-BISFLog -Msg "Delete RegistryItem -Path($2Delete.value) -Name($2Delete.data)"
					Remove-ItemProperty -Path $2Delete.value -Name $2Delete.data -ErrorAction SilentlyContinue
				}
			}
			
			If ($2Delete.type -eq "FILE")
			{
				Write-BISFLog -Msg "Processing Files to delete" -ShowConsole -SubMsg -color DarkCyan
				$File2Del = "$2Delete.value\$2Delete.data"
				If (Test-Path ($File2Del) -PathType Leaf)
				{
					Write-BISFLog -Msg "Delete File $File2Del"
					Remove-Item $File2Del | Out-Null
				}
			}
		}
	}


    function StopService
    {
		ForEach ($ServiceName in $ServiceNames)
		{
			$svc = Test-BISFService -ServiceName "$ServiceName"
			If ($svc -eq $true) {Invoke-BISFService -ServiceName "$($ServiceName)" -Action Stop -StartType manual}
		}
    }

	####################################################################
	####### end functions #####
	####################################################################

	#### Main Program
	$svc = Test-BISFService -ServiceName $ServiceNames[0] -ProductName "$product"
	If ($svc -eq $true)
	{
		StopService
		RunFullScan
		deleteData
	}
}


End {
	Add-BISFFinishLine
}
