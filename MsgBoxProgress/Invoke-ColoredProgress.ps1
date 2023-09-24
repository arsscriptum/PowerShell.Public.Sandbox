<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


[CmdletBinding(SupportsShouldProcess)]
Param()


function Show-ColoredProgress{
    [CmdletBinding(SupportsShouldProcess)]
    Param()

    function GetColor([uint32]$val){
        if($val -lt 25){
            return [System.Drawing.Color]::Green;
        }elseif($val -lt 50){
            return [System.Drawing.Color]::Yellow;
        }elseif($val -lt 75){
            return [System.Drawing.Color]::Orange;
        }else{
            return [System.Drawing.Color]::Red;
        }
    }

    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

    $form = new-object Windows.Forms.Form    
    $form.Size = new-object Drawing.Size(350,120)
    $form.StartPosition='CenterScreen'
    $button = new-object Windows.Forms.Button
    $button.Location = '130, 10'
    $button.Text = 'Start'
    $form.controls.add($button)
    $Max = 100


    # create label
    $label1 = New-Object system.Windows.Forms.Label
    $label1.Text = "not started"

    $label1.Location  = New-Object System.Drawing.Point(130, 35)
    $label1.Size = new-object Drawing.Size(240,15)
    #adjusted height to accommodate progress bar
   
    $label1.Font= "Verdana"
    #optional to show border
    #$label1.BorderStyle=1

    #add the label to the form
    $form.controls.add($label1)


    $Script:progressbar = New-Object System.Windows.Forms.progressbar
    $Script:progressbar.Location = New-Object System.Drawing.Point(0, 60)
    $Script:progressbar.Width = 350
    $Script:progressbar.Height = 15
    $Script:progressbar.Style="Continuous"
    $Script:progressbar.Maximum = 100
    $form.controls.add($Script:progressbar)
    

    $form.Add_Shown($form.Activate()) 
    $button.Add_Click({
        $i = 0
        $button.Enabled = $False
        $label1.Location  = New-Object System.Drawing.Point(90, 35)
        $Script:progressbar.Value = 0
        1..$Max | ForEach {
            $Script:progressbar.ForeColor = GetColor($i)
            $Script:progressbar.Increment(1)
            Start-Sleep -Milliseconds 50
            $labelTxt = "running tasks. progress {0} %" -f $i
            $label1.Text = $labelTxt 
            $form.Refresh()
            $i++
        }
    }) 
    $form.showdialog() | out-null
}


Show-ColoredProgress





