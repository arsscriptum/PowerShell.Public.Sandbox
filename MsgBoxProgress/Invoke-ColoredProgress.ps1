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
    $FormWidth = $Form.Width
    $FormHeight = $Form.Height

    $form.controls.add($button)
    $Max = 100


    Write-Host "FormWidth $FormWidth"
    Write-Host "FormHeight $FormHeight"
    # create label
    $label1 = New-Object system.Windows.Forms.Label
    $Label1.ForeColor = "#176faa"
    $label1.AutoSize = $true
    $labelTxt = "running tasks. progress 0%"
    $label1.Size = new-object Drawing.Size(230,25)
    $label1.Text = $labelTxt 
    $label1.Font = [System.Drawing.Font]::new("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::Bold)
    Write-Host "Size $($label1.Size)"


    #add the label to the form
    $form.controls.add($label1)


    $guiProgressbar = New-Object System.Windows.Forms.progressbar
    $guiProgressbar.Location = New-Object System.Drawing.Point(0, 60)
    $guiProgressbar.Width = 350
    $guiProgressbar.Height = 15
    $guiProgressbar.Style="Continuous"
    $guiProgressbar.Maximum = 100
    $form.controls.add($guiProgressbar)
    
    $form.BackColor = 'LightBlue'
    
    $guiProgressbar.Value = 0
    $UpdateTimer = New-Object System.Windows.Forms.Timer
    $UpdateTimer.Interval = 60   # for demo 1 second
    $UpdateTimer.Enabled = $false  # disabled at first
    $UpdateTimer.Tag = -1          # store the starting color index. Initialize to -1

    [uint32]$ProgressCounter = 0
    [uint32]$Script:WaitCounter = 0
    $UpdateTimer.Add_Tick({
        
        
        if( $($guiProgressbar.Value) -lt 99){
            $guiProgressbar.Increment(1)
            $ProgressCounter = $($guiProgressbar.Value)
            Write-Verbose "Update Progress $ProgressCounter"
            
            $labelTxt = "running tasks. progress {0:d2}%" -f $ProgressCounter
            
            UpdateLabel( $labelTxt )
            $guiProgressbar.ForeColor = GetColor($ProgressCounter)
            $form.Refresh()
            
        }else{
            [uint32]$Script:WaitCounter++
            if($Script:WaitCounter -lt 10){
                $label1.ForeColor = 'Red'
                UpdateLabel("DONE. Closing...")
            }else{
                Write-Host "close "
                $form.Close()
            }        
        }
    })


    function UpdateLabel([string]$txt){
        $label1.Text = $txt
        $tmp_h = $label1.Size.Height
        $tmp_w = $label1.Size.Width
        $label1_height = ($FormHeight/2)-($tmp_h*2)+10
        $label1_width = ($FormWidth/2)-($tmp_w/2)
        $label1.location = New-Object System.Drawing.Point($label1_width,$label1_height)
    }

    function FormCleanup{
        $form.Dispose()
        $UpdateTimer.Dispose()
    }

    function FormLoaded{
        $form.Activate()
        $UpdateTimer.Enabled = $true
        $UpdateTimer.Start()
    }
      $form.ResumeLayout()
    $form.PerformLayout()

    $form.Add_Shown( { FormLoaded } ) 
    $form.add_FormClosed( { FormCleanup } )
    $form.showdialog() | out-null

     $form.Dispose()
     $UpdateTimer.Dispose()
}


Show-ColoredProgress





