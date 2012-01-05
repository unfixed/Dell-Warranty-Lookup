#requires -version 2.0

# Warranty Lookup Tool for Dell Systems
# Created by Arslan Gondal


function Max-Datetime {

    param (
        	[parameter(Mandatory=$true, HelpMessage="Enter array of datetimes")]
            [array]$datetimes
        )
    $latest = [datetime] 0
    foreach ($datetime in $datetimes) {
        if ($datetime.ticks -ge $latest.ticks) {
            $latest = $datetime
            }
        }
    return $latest.Date
}

function Get-DellWarranty {
	param (
    	[parameter(Mandatory=$true, HelpMessage="Enter Dell Service Tag")]
        [String]$ServiceTag
        )
    $GUID = New-Object GUID('12345678-1234-1234-1234-123456789012')
    $AppName = 'Warranty Lookup Tool for Dell Systems'
    try {$proxy = New-WebServiceProxy -URI 'http://xserv.dell.com/services/assetservice.asmx'}
	catch {[system.exception] "Something went wrong"}
    $Data = $proxy.GetAssetInformation($GUID, $AppName, $ServiceTag)

    $HeaderInfo = ($Data | Select-Object -ExpandProperty AssetHeaderData)

    $WarrantyDates = @()
    foreach ($item in ($Data |Select-Object -ExpandProperty Entitlements))
    {
        $ThisEntitlement = New-Object PSobject -Property @{
            Entitlement = $item.EntitlementType
            Provider = $item.Provider
            ServiceLevelCode = $item.ServiceLevelCode
            ServiceLevelDescription = $item.ServiceLevelDescription
            StartDate = $item.StartDate
            EndDate = $item.EndDate
        }
		$WarrantyDates += $ThisEntitlement.EndDate
    }
    
    $SystemInformation = New-Object System.Object
    $SystemInformation | Add-Member -membertype NoteProperty -name Model -value ($HeaderInfo.SystemType+' '+$HeaderInfo.SystemModel)
    $SystemInformation | Add-Member -membertype NoteProperty -name ServiceTag -value $HeaderInfo.ServiceTag
    $SystemInformation | Add-Member -membertype NoteProperty -name ShipDate -value $HeaderInfo.SystemShipDate
    $SystemInformation | Add-Member -membertype NoteProperty -name WarrantyDate -value (Max-Datetime $WarrantyDates).ToShortDateString()
    
    
    Return $SystemInformation
}


function importCSV {
	param (
        [string]$filepath
      )
	#write-host 
	$serials = Import-Csv $filepath
	
	$Systems = @()
    
	foreach ($serial in $serials) {
		$Systems += (Get-DellWarranty ($serial.serialtag))
		}

	$filepath = $filepath.TrimEnd('.csv') + '_parsed.csv'
	$Systems | Export-Csv -Path $filepath -NoTypeInformation
	return $true
}

#$filepath = "D:\My Dropbox\Projects\Dell Asset Tag\tempfile.csv"

function LookupForm			#Requested Login Name From User - Deprecated
	{
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
	[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	[void] [System.Windows.Forms.Application]::EnableVisualStyles()
	
	$ImportForm = New-Object System.Windows.Forms.Form
	$ImportForm.Text = "Warranty Lookup Tool for Dell Systems"
	$ImportForm.Size = New-Object System.Drawing.Size(400,300)
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
	
	$RadioBtnCSV.Text = "Lookup Warranties Using a .csv File (Recommended for Large Volumes)"
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
	$Drawing_Point.Y = 170
	$RadioBtnTag.Location = $Drawing_Point
	$Drawing_Point.X = 50
	$Drawing_Point.Y = 50
	$RadioBtnCSV.Location = $Drawing_Point
	
	$RadioBtnCSV.DataBindings.DefaultDataSourceUpdateMode = 0
	$RadioBtnCSV.TabStop = $True

	$ImportForm.Controls.Add($RadioBtnCSV)
	$ImportForm.Controls.Add($RadioBtnTag)
	
	
	$SubmitBtn = New-Object System.Windows.Forms.Button
	$SubmitBtn.Location = New-Object System.Drawing.Size(300,230)
	$SubmitBtn.Size = New-Object System.Drawing.Size(75,23)
	$SubmitBtn.Text = "OK"
	

	$TextServiceTag = New-Object System.Windows.Forms.TextBox
	$Drawing_Size.Width = 150
	$Drawing_Size.Height = 30
	$TextServiceTag.Size = $Drawing_Size
	$Drawing_Point.X = 50
	$Drawing_Point.Y = 230
	$TextServiceTag.Location = $Drawing_Point
	
	
	$TextServiceTag.DataBindings.DefaultDataSourceUpdateMode = 0
	$TextServiceTag.Text = "Enter Service Tag Here"
	$TextServiceTag.Name = "TextBox_ServiceTag"
	$ImportForm.Controls.Add($TextServiceTag)



	$FileImport = New-Object System.Windows.Forms.Label
	$FileImport.Location = New-Object System.Drawing.Size(50,80)
	$FileImport.Size = New-Object System.Drawing.Size(300,30)
	$FileImport.Text = ""
	$ImportForm.Controls.Add($FileImport)

	$FileResult = New-Object System.Windows.Forms.Label
	$FileResult.Location = New-Object System.Drawing.Size(80,110)
	$FileResult.Size = New-Object System.Drawing.Size(200,30)
	$FileResult.Text = ""
	$ImportForm.Controls.Add($FileResult)

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
									if (ImportCSV $FileImport.Text) {$FileResult.Text = 'Results Written to: '+[io.path]::GetFileNameWithoutExtension($FileImport.Text) +'_parsed.csv'}
									else {$FileResult.Text = 'Something went wrong.'}
								}
							else {$FileResult.Text = 'A valid file was not selected. Make sure the file has a .csv extension.'}
							}
						elseif ($RadioBtnTag.Checked) {
							if ( $TextServiceTag.Text.Length -eq 7 ) {
									if ($TextServiceTag.Text = (Get-DellWarranty $TextServiceTag.Text).WarrantyDate )  {$FileResult.Text = 'Lookup Successful.' }
									else {$FileResult.Text = 'Something went wrong.'}
								}
							else {$FileResult.Text = 'The Service Tag has either not been entered, or is the wrong length.'}
							}
					})
	$ImportForm.Controls.Add($SubmitBtn)



	
	$RadioBtnTag.TabIndex = 0
	$RadioBtnCSV.TabIndex = 1


	$TextServiceTag.TabIndex = 5

	$ImportForm.Topmost = $True

	$ImportForm.Add_Shown({$ImportForm.Activate()})
	[void] $ImportForm.ShowDialog()
	}


LookupForm