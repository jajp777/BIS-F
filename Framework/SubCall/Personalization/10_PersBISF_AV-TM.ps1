<#
    .SYNOPSIS
        Personalize TrenMicro OfficeScan  for Image Management Software
	.Description
		Create HostID based on MACAddress
    .EXAMPLE
    .Inputs
    .Outputs
    .NOTES
		Author: Matthias Schlimm
      	Company: Login Consultants Germany GmbH
		
		History
      	Last Change: 17.09.2014 MS: Script created
		Last Change: 10.08.2015 MS: define array for TM services for better scripthandling
		Last Change: 06.10.2015 MS: rewritten script with standard .SYNOPSIS
		Last Change: 09.01.2017 MS: change code to get MacAdress to use function Get-BISMACAddress
		Last Change: 01.08.2017 JS: Added the TmPfw (OfficeScan NT Firewall) service to the array
	.Link
#>


Begin {
	$reg_TM_string = "$HKLM_sw_x86\TrendMicro\PC-cillinNTCorp\CurrentVersion"
	$reg_TM_name = "GUID"
	$product = "Trend Micro Office Scan"
	# The main 4 services are:
	# - TmListen (OfficeScan NT Listener)
	# - NTRTScan (OfficeScan NT RealTime Scan)
	# - TmPfw (OfficeScan NT Firewall)
	# - TmProxy (OfficeScan NT Proxy Service)
	$TMServices = @("TmListen","NTRTScan","TmProxy","TmPfw")
	$HostID_Prfx = "00000000-0000-0000-0000-"
	$script_path = $MyInvocation.MyCommand.Path
	$script_dir = Split-Path -Parent $script_path
	$script_name = [System.IO.Path]::GetFileName($script_path)

}

Process 
{

		## Start TM Service
	function StartService
	{
		ForEach ($TMService in $TMServices)
		{
			# check if service exist
			
			$svc = Test-BISFService -ServiceName "$TMService"
			IF ($svc -eq $true)
			{
				Invoke-BISFService -ServiceName "$TMService" -Action Start
			}
		}
	}


	## set HostID in Registry
	function SetHostID
	{
		$mac = Get-BISFMACAddress
		Write-BISFLog -Msg "$reg_SEP_name Prefix: $HostID_Prfx"  
		$regHostID =$HostID_Prfx+$mac
		Write-BISFLog -Msg "set TrendMicro $reg_TM_name in Registry $regHostID_string..."  
		Set-ItemProperty -Path $reg_TM_string -Name $reg_TM_name -value $regHostID -ErrorAction SilentlyContinue
	}
	####################################################################

	#### Main Program
		$svc = Test-BISFService -ServiceName $TMServices[0] -ProductName "$product"
	
	IF ($svc)
	{
		# Note that if the services start before the GUID is set it won't register with the OfficeScan Management Server
		SetHostID
		StartService
	} 

}

End {
Add-BISFFinishLine
}