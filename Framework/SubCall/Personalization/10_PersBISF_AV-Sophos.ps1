<#
    .SYNOPSIS
        Personalize Sophos Sophos Endpoint Security and Control for Image Managemement Software
	.Description
      	Set HostID based on MACAddress and start services
    .EXAMPLE
    .Inputs
    .Outputs
    .NOTES
		Author: Matthias Schlimm
      	Company: Login Consultants Germany GmbH
		
		History
      	Last Change: 09.01.2017 MS: Script created
		Last Change: 18.08.2017 FF: Use $ServiceNames instead of $ServiceName for first Test-BISFService
		Last Change: 28.11.2017 JP: 
	.Link
#>

Begin {
	$Script_Path = $MyInvocation.MyCommand.Path
	$Script_Dir = Split-Path -Parent $Script_Path
	$Script_Name = [System.IO.Path]::GetFileName($Script_Path)

	# Product specific
	$Product = "Sophos Endpoint Security and Control"
	$ProductInstPath = "$ProgramFilesx86\Sophos\Sophos Anti-Virus"
	$ServiceNames = @("Sophos Agent","Sophos AutoUpdate Service","Sophos Message Router")
	$HostID_Prfx = "00000000-0000-0000-0000-00"
	$HostID_File = "$env:ProgramData\Sophos\AutoUpdate\data\machine_ID.txt"
	
}

Process {
####################################################################
####### functions #####
####################################################################

	Function Set-GUID
    {
		Write-BISFLog -Msg "GUID Prefix: $HostID_Prfx"  
		$MAC = Get-BISFMACAddress
		$regHostID =$HostID_Prfx+$MAC
		Write-BISFLog -Msg "Write Sophos GUID $regHostID to file $HostID_File"
		Out-File -Filepath $HostID_File -Inputobject "$regHostID" -Encoding default
	}

    Function Start-Services
    {
		ForEach ($ServiceName in $ServiceNames)
		{
			$svc = Test-BISFService -ServiceName "$ServiceName"
			If ($svc -eq $true) {Invoke-BISFService -ServiceName "$($ServiceName)" -Action Start}
		}
    }

	####################################################################
	####### end functions #####
	####################################################################

	#### Main Program
	$svc = Test-BISFService -ServiceName $ServiceNames[0] -ProductName "$Product"
	If ($svc -eq $true)
	{
		Set-GUID
		Start-Services
	}
}


End {
	Add-BISFFinishLine
}
