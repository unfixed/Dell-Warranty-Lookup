#requires -version 2.0

# Warranty Lookup Tool for Dell Systems
# Created by Arslan Gondal


function Get-DellWarranty {
	param (
    	#[parameter()] [switch]$verbose,
		[parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Enter Dell Service Tag")]
        [string[]]$ServiceTag
        )
    BEGIN {
        $GUID = New-Object GUID('12345678-1234-1234-1234-123456789012')
        $AppName = 'Warranty Lookup Tool for Dell Systems'
        try {$proxy = New-WebServiceProxy -URI 'http://xserv.dell.com/services/assetservice.asmx'}
    	catch {[system.exception] "Failed to connect to dell asset service"}
        
        $Systems = @()
        #if($verbose){Write-Host "Querying information for servicetag: "}
    }
    PROCESS {
		
        $Data = $proxy.GetAssetInformation($GUID, $AppName, $ServiceTag)

        $HeaderInfo = ($Data | Select-Object -ExpandProperty AssetHeaderData)
		$WarrantyDates = @()
        foreach ($item in ($Data |Select-Object -ExpandProperty Entitlements))
        {
                $WarrantyDates += $item.EndDate
        }

        #calculate latest date in warranties
        $latest = [datetime] 0
        foreach ($datetime in $WarrantyDates) {
            if ($datetime.ticks -ge $latest.ticks) {
                $latest = $datetime
                }
            }
		
        $SystemInformation = New-Object System.Object
        $SystemInformation | Add-Member -membertype NoteProperty -name Model -value ($HeaderInfo.SystemType+' '+$HeaderInfo.SystemModel)
        $SystemInformation | Add-Member -membertype NoteProperty -name ServiceTag -value $HeaderInfo.ServiceTag
        $SystemInformation | Add-Member -membertype NoteProperty -name ShipDate -value $HeaderInfo.SystemShipDate.ToShortDateString()
        $SystemInformation | Add-Member -membertype NoteProperty -name WarrantyDate -value $latest.Date.ToShortDateString()
        $Systems = $Systems + $SystemInformation
    }
    END {
        Return $Systems
    }
}


function Import-ServiceTags{
	param (
        [string]$filepath
      )
	$serials = Import-Csv $filepath
	
    $ServiceTags = @()
	foreach ($serial in $serials) {
		$ServiceTags += ($serial.serialtag)
		}
	$Systems = ($ServiceTags | Get-DellWarranty)
	$filepath = $filepath.TrimEnd('.csv') + '_parsed.csv'

	$Systems | Export-Csv -Path $filepath -NoTypeInformation
	return $true
}


function LookupForm
	{
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	[void] [System.Windows.Forms.Application]::EnableVisualStyles()
	
	$ImportForm = New-Object System.Windows.Forms.Form
	$ImportForm.Text = "Warranty Lookup Tool for Dell Systems"
	$ImportForm.Size = New-Object System.Drawing.Size(600,500)
	$ImportForm.StartPosition = "CenterScreen"
	$ImportForm.SizeGripStyle = "Hide"
	$ImportForm.MaximizeBox = $false
	$ImportForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog


	$ImportInfo = New-Object System.Windows.Forms.Label
	$ImportInfo.Location = New-Object System.Drawing.Size(50,20)
	$ImportInfo.Size = New-Object System.Drawing.Size(300,30)
	$ImportInfo.Text = "Please Select a Method to Lookup Dell Service Tag(s)."
	$ImportForm.Controls.Add($ImportInfo)


	$RadioBtnCSV = New-Object System.Windows.Forms.RadioButton
	$RadioBtnTag = New-Object System.Windows.Forms.RadioButton
	
	$RadioBtnCSV.Text = "Lookup Warranties Using a .CSV file (Recommended for Large Volumes)"
	$RadioBtnCSV.Name = "$RadioBtn_CSV"
	$RadioBtnTag.Text = "Lookup Warranty Using a Service Tag"
	$RadioBtnTag.Name = "$RadioBtn_ServiceTag"
		
	$Drawing_Size = New-Object System.Drawing.Size
	$Drawing_Size.Width = 220
	$Drawing_Size.Height = 30
	$RadioBtnCSV.Size = $Drawing_Size
	$RadioBtnTag.Size = $Drawing_Size
	$RadioBtnCSV.UseVisualStyleBackColor = $True
	$RadioBtnTag.UseVisualStyleBackColor = $True

	$Drawing_Point = New-Object System.Drawing.Point
	$Drawing_Point.X = 50
	$Drawing_Point.Y = 270
	$RadioBtnTag.Location = $Drawing_Point
	$Drawing_Point.X = 50
	$Drawing_Point.Y = 50
	$RadioBtnCSV.Location = $Drawing_Point
	
	$RadioBtnCSV.DataBindings.DefaultDataSourceUpdateMode = 0
	$RadioBtnCSV.TabStop = $True

	$ImportForm.Controls.Add($RadioBtnCSV)
	$ImportForm.Controls.Add($RadioBtnTag)
	
	
	$SubmitBtn = New-Object System.Windows.Forms.Button
	$SubmitBtn.Location = New-Object System.Drawing.Size(500,430)
	$SubmitBtn.Size = New-Object System.Drawing.Size(75,23)
	$SubmitBtn.Text = "OK"
	

	$TextServiceTag = New-Object System.Windows.Forms.TextBox
	$Drawing_Size.Width = 150
	$Drawing_Size.Height = 30
	$TextServiceTag.Size = $Drawing_Size
	$Drawing_Point.X = 50
	$Drawing_Point.Y = 320
	$TextServiceTag.Location = $Drawing_Point
	
	
	$TextServiceTag.DataBindings.DefaultDataSourceUpdateMode = 0
	$TextServiceTag.Text = "Enter Service Tag Here"
	$TextServiceTag.Name = "TextBox_ServiceTag"
	$ImportForm.Controls.Add($TextServiceTag)
	
	#$LabelModel
	$LabelModel = New-Object System.Windows.Forms.Label
	$Drawing_Size.Width = 40
	$Drawing_Size.Height = 30
	$LabelModel.Size = $Drawing_Size
	$Drawing_Point.X = 290
	$Drawing_Point.Y = 320
	$LabelModel.Location = $Drawing_Point
	$LabelModel.DataBindings.DefaultDataSourceUpdateMode = 0
	$LabelModel.Text = "Model:"
	$LabelModel.Name = "Label_Model"
	$ImportForm.Controls.Add($LabelModel)
	#$TextModel
	$TextModel = New-Object System.Windows.Forms.TextBox
	$Drawing_Size.Width = 150
	$Drawing_Size.Height = 30
	$TextModel.Size = $Drawing_Size
	$Drawing_Point.X = 330
	$Drawing_Point.Y = 320
	$TextModel.Location = $Drawing_Point
	$TextModel.DataBindings.DefaultDataSourceUpdateMode = 0
	$TextModel.Text = ""
	$TextModel.Name = "TextBox_WarrantyDate"
	$ImportForm.Controls.Add($TextModel)
	
	#$LabelShipDate
	$LabelShipDate = New-Object System.Windows.Forms.Label
	$Drawing_Size.Width = 58
	$Drawing_Size.Height = 30
	$LabelShipDate.Size = $Drawing_Size
	$Drawing_Point.X = 272
	$Drawing_Point.Y = 350
	$LabelShipDate.Location = $Drawing_Point
	$LabelShipDate.DataBindings.DefaultDataSourceUpdateMode = 0
	$LabelShipDate.Text = "Ship Date:"
	$LabelShipDate.Name = "Label_ShipDate"
	$ImportForm.Controls.Add($LabelShipDate)
	#$TextShipDate
	$TextShipDate = New-Object System.Windows.Forms.TextBox
	$Drawing_Size.Width = 150
	$Drawing_Size.Height = 30
	$TextShipDate.Size = $Drawing_Size
	$Drawing_Point.X = 330
	$Drawing_Point.Y = 350
	$TextShipDate.Location = $Drawing_Point
	$TextShipDate.DataBindings.DefaultDataSourceUpdateMode = 0
	$TextShipDate.Text = ""
	$TextShipDate.Name = "TextBox_WarrantyDate"
	$ImportForm.Controls.Add($TextShipDate)
	
	#$LabelWarrantyDate
	$LabelWarrantyDate = New-Object System.Windows.Forms.Label
	$Drawing_Size.Width = 80
	$Drawing_Size.Height = 30
	$LabelWarrantyDate.Size = $Drawing_Size
	$Drawing_Point.X = 250
	$Drawing_Point.Y = 380
	$LabelWarrantyDate.Location = $Drawing_Point
	$LabelWarrantyDate.DataBindings.DefaultDataSourceUpdateMode = 0
	$LabelWarrantyDate.Text = "Warranty Date:"
	$LabelWarrantyDate.Name = "Label_WarrantyDate"
	$ImportForm.Controls.Add($LabelWarrantyDate)
	#$TextWarrantyDate
	$TextWarrantyDate = New-Object System.Windows.Forms.TextBox
	$Drawing_Size.Width = 150
	$Drawing_Size.Height = 30
	$TextWarrantyDate.Size = $Drawing_Size
	$Drawing_Point.X = 330
	$Drawing_Point.Y = 380
	$TextWarrantyDate.Location = $Drawing_Point
	$TextWarrantyDate.DataBindings.DefaultDataSourceUpdateMode = 0
	$TextWarrantyDate.Text = ""
	$TextWarrantyDate.Name = "TextBox_WarrantyDate"
	$ImportForm.Controls.Add($TextWarrantyDate)






	$FileImport = New-Object System.Windows.Forms.Label
	$FileImport.Location = New-Object System.Drawing.Size(50,80)
	$FileImport.Size = New-Object System.Drawing.Size(300,30)
	$FileImport.Text = ""
	$ImportForm.Controls.Add($FileImport)
	
	#$FileResult
	$FileResult = New-Object System.Windows.Forms.Label
	$FileResult.Location = New-Object System.Drawing.Size(80,110)
	$FileResult.Size = New-Object System.Drawing.Size(200,30)
	$FileResult.Text = ""
	$ImportForm.Controls.Add($FileResult)

	#$TagResult
	$TagResult = New-Object System.Windows.Forms.Label
	$TagResult.Location = New-Object System.Drawing.Size(50,350)
	$TagResult.Size = New-Object System.Drawing.Size(200,30)
	$TagResult.Text = ""
	$ImportForm.Controls.Add($TagResult)

	$Browse = new-object windows.Forms.OpenFileDialog
	$Browse.ShowHelp = $true
	$BrowseButton = New-Object System.Windows.Forms.Button
	$BrowseButton.Location = New-Object System.Drawing.Size(300,55)
	$BrowseButton.Size = New-Object System.Drawing.Size(75,23)
	$BrowseButton.Text = "Browse"
	$BrowseButton.Add_Click( {
							if($Browse.ShowDialog() -eq "OK") {
								$FileImport.Text = $Browse.FileName
								}
							 })
	$ImportForm.Controls.Add($BrowseButton)

	$SubmitBtn.Add_Click({
	
						if ($RadioBtnCSV.Checked) {
							if ( $FileImport.Text.EndsWith(".csv") ) {
									if (Import-ServiceTags $FileImport.Text) {$FileResult.Text = 'Results Written to: '+[io.path]::GetFileNameWithoutExtension($FileImport.Text) +'_parsed.csv'}
									else {$FileResult.Text = 'Something went wrong.'}
								}
							else {$FileResult.Text = 'A valid file was not selected. Make sure the file selected is formated as a csv with the proper extension.'}
							}
						elseif ($RadioBtnTag.Checked) {
							if ( $TextServiceTag.Text.Length -eq 7 ) {
									if ($LookupInfo = Get-DellWarranty $TextServiceTag.Text)  {
										$TextModel.Text = $LookupInfo.Model
										$TextShipDate.Text = $LookupInfo.ShipDate
										$TextWarrantyDate.Text = $LookupInfo.WarrantyDate
										$TagResult.Text = 'Lookup Successful.' 
									}
									else {$TagResult.Text = 'Something went wrong.'}
								}
							else {$TagResult.Text = 'The Service Tag has either not been entered, or is the wrong length.'}
							}
					})
	$ImportForm.Controls.Add($SubmitBtn)



	
	$RadioBtnTag.TabIndex = 0
	$RadioBtnCSV.TabIndex = 1


	$TextServiceTag.TabIndex = 5

	#$ImportForm.Topmost = $True

	$ImportForm.Add_Shown({$ImportForm.Activate()})
	[void] $ImportForm.ShowDialog()
	
	}

LookupForm