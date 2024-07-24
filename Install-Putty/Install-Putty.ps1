#╔════════════════════════════════════════════════════════════════════════════════╗
#║                                                                                ║
#║   Install-Putty.ps1                                                            ║
#║   Install Putty                                                                ║
#║                                                                                ║
#╟────────────────────────────────────────────────────────────────────────────────╢
#║   Guillaume Plante <guillaume.plante@luminator.com>                            ║
#║   Copyright (C) Luminator Technology Group.  All rights reserved.              ║
#╚════════════════════════════════════════════════════════════════════════════════╝


function Install-Putty {

    [CmdletBinding(SupportsShouldProcess)]
    param(  
        [Parameter(Mandatory=$false,Position=0)]
        [string]$DestinationPath = "$ENV:ProgramsPath"
    )
    try{
    	$PuttyPath = Join-Path $DestinationPath "Putty"

        $u = "https://the.earth.li/~sgtatham/putty/latest/w64/putty.zip"
                
        $o = "$ENV:Temp\putty.zip"
        
        $Res=Invoke-WebRequest -UseBasicParsing -Uri $u -OutFile $o -Passthru
        if($Res.StatusCode -ne 200){throw "error getting putty package"}
        Expand-Archive -Path $o -DestinationPath $PuttyPath -Force
        Remove-Item -Path $o -Force -ErrorAction Ignore | Out-Null

        if(Get-Command "Add-EnvPath"){
            Write-Verbose "Adding `"$PuttyPath`" to environment value"
            Add-EnvPath -Path "$PuttyPath" -Container User  
        }else{
            Write-Verbose "Path NOT added to Environment"
        }
        
    }
    catch{
        Write-Error $_
    }
}
