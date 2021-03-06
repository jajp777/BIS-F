<#
    .SYNOPSIS
        Personalize Turbo.net Applications for Image Management
	.Description
      	update the turbo subscription
    .EXAMPLE
    .Inputs
    .Outputs
    .NOTES
		Author: Matthias Schlimm
      	Company: Login Consultants Germany GmbH
		
      	History
		Last Change: 22.03.2016 MS: Script created
		Last Change: 
		Last Change: 
	.Link
#>

Begin {

	####################################################################
	# define environment
	$PSScriptFullName = $MyInvocation.MyCommand.Path
	$PSScriptRoot = Split-Path -Parent $PSScriptFullName
	$PSScriptName = [System.IO.Path]::GetFileName($PSScriptFullName)

	#product specified
	$Product = "Turbo.net"
	$ProductInstPath = "$ProgramFilesx86\Spoon\Cmd\Turbo.exe"
	$Tas
	
}

Process {
####################################################################
####### functions #####
####################################################################

function Invoke-TurboSupscriptionUpdate
    {
	    $varTB = Get-Variable -Name LIC_BISF_TurboRun -ValueOnly
		Write-BISFLog -Msg "The Turbo Subscription Update would be set to the Value $($varTB) in the registry"
		
		IF ($varTB -eq "YES")
		{
			Write-BISFLog -Msg "Running Turbo Update Subscription Now"
			invoke-expression (Get-ScheduledTask -TaskPath "\turbo-net\" | Start-ScheduledTask)
			Show-ProgressBar -CheckProcess "Turbo" -ActivityText "Running Turbo Subscription Update"
		}
	}

    
   
	
    
    
####################################################################
####### end functions #####
####################################################################

#### Main Program

	IF (Test-Path ("$ProductInstPath") -PathType Leaf) 

	{
		Write-BISFLog -Msg "Product $Product installed" -ShowConsole -Color Cyan
        Invoke-TurboSupscriptionUpdate
		
	} ELSE {
		Write-BISFLog -Msg "Product $Product not installed"
	}
}

End {
	Add-BISFFinishLine
}


