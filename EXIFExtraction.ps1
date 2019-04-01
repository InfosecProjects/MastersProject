<# 
.SYNOPSIS 
    Forensic tool to extract and log image metadata 
.DESCRIPTION 
    Extracts metadata from folder of imagee files. Creates a CSV log of image data 
    and generates a KML file for Google Earth containing placemarks for any images 
    containing GPS data. 
.PARAMETER Source 
    The path to the folder containing the images for examination 
.PARAMETER Target 
    The path where the CSV output file will be stored. 
.PARAMETER TargetFileName 
    Case Number or any other name unique to the case 
.NOTES 
    File Name       :   imagemapper.ps1 
    Original Author :   Garrett Ed Pewitt 
    Modified By     :   Author 
    Requires        :   PowerShell v5 
.LINK 
    http://www.forensicexpedition.com/tools/imagemapper.ps1 
.EXAMPLE 
    imagemapper.ps1 -source "C:\CaseImages" -target "C:\Cases\001\Images" -targetfilename "outputs" 
    Example showing how to run script against folder of images 
#> 

[CmdletBinding()] 
Param ( 
    [Parameter(Mandatory=$True, Position=1)] 
    [string]$Source, 
    [Parameter(Mandatory=$True, Position=2)] 
    [string]$Target, 
    [Parameter(Mandatory=$True, Position=3)] 
    [string]$TargetFileName 
) 

$CurDate = Get-Date -f "yyyyMMdd" 

Function AddCSV 
{ 
    # Function to manually create CSV is needed. 
    $CSVContent = "`"$ImgName`",`"$ImgType`",`"" ` 
    + "$ImgDateTaken`",`"$ImgCameraModel`",`"" ` 
    + "$ImgCameraMake`",`"" ` 
    + "$LatOrt`",`"$LonOrt`"" 
    Add-Content $CSVFile $CSVContent 
} 

Function ImageMetaDataExtract 
{ 
    # Function to extract data from image files 
} 

# Test source path 
If ($Source -ne '') 
{ 
    # Check to see if Source path is valid 
    If ((Test-Path($Source)) -eq $true) 
    { 
        # If no target path is specifed use current user desktop as target. 
        If ($Target -eq '') 
        { 
            $Target = [Environment]::GetFolderPath("Desktop") 

            If ($TargetFileName -eq '') 
            { 
                $TargetFileName = $CurDate 
            } 
            $TargetPath = $Target + "\" + $TargetFileName + "-imagemapper" 
            New-Item $TargetPath -Type Directory 
        } 
        else 
        {      
        } 
         
        # Create output files 
        $CSVFile = "$TargetPath\$TargetFileName-Results.csv" 

        $TargetPath = $Source 
        $Images = Get-ChildItem "$TargetPath"  -Recurse | Where { ! $_.PSIsContainer}     

        # Create CSV file and add CSV File Header 
        New-Item $CSVFile -Type File 
        $CSVHeader = '"File Name","Extension",' ` 
        + '"Date Taken","Camera Model",' ` 
        + '"Camera Make",' ` 
        + '"Latitude","Longitude"' 
        Add-Content $CSVFile $CSVHeader 

        ForEach ($Image in $Images) 
        { 
            # Get File Metadata 
            $COM = New-Object -COMObject Shell.Application 
            $Folder = Split-Path $Image.FullName 
            $File = Split-Path $Image.FullName -leaf 
            $COMFolder = $COM.Namespace($Folder) 
            $COMFile = $COMFolder.ParseName($File) 
            $MData = New-Object -TypeName PSCustomObject -Property @{ 
                Name = $COMfolder.GetDetailsOf($COMFile,0) 
                Type = $COMfolder.GetDetailsOf($COMFile,2)                
                DateTaken = $COMfolder.GetDetailsOf($COMFile,12) 
                CameraModel = $COMfolder.GetDetailsOf($COMFile,30) 
                CameraMake = $COMfolder.GetDetailsOf($COMFile,32) 
                } 

                $ImgName = $MData.Name 
                $ImgType = $MData.Type               
                $ImgDateTaken = $MData.DateTaken 
                $ImgCameraModel = $MData.CameraModel                
                $ImgCameraMake = $MData.CameraMake 
                $ImgFilePath = $Image.FullName               

            Try 
            { 
                $img = New-Object -TypeName system.drawing.bitmap -ArgumentList $ImgFilePath; 
            } 
            Catch 
            { 
                $FileStatus = "Error" 
            } 

            # Set default values 
            $GPSInfo = $true 
            $ImgGPS = "TRUE" 
            $Encode = New-Object System.Text.ASCIIEncoding 

            Try 
            { 
                $LatNS = $Encode.GetString($img.GetPropertyItem(1).Value) 
            } 
            Catch 
            { 
                $GPSInfo = $False 
            } 

            If ($GPSInfo -eq $true) 
            { 
                $LatDeg = (([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(2).Value, 0)) / ([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(2).Value, 4))) 
                $LatMin = (([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(2).Value, 8)) / ([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(2).Value, 12))) 
                $LatSec = (([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(2).Value, 16)) / ([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(2).Value, 20))) 

                $LonEW = $Encode.GetString($img.GetPropertyItem(3).Value) 
                $LonDeg = (([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(4).Value, 0)) / ([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(4).Value, 4))) 
                $LonMin = (([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(4).Value, 8)) / ([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(4).Value, 12))) 
                $LonSec = (([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(4).Value, 16)) / ([Decimal][System.BitConverter]::ToInt32($img.GetPropertyItem(4).Value, 20))) 

                # Convert to decimal Degrees 
                If ($LatNS -eq 'S') 
                { 
                    $LatOrt = "-"    
                } 
                If ($LonEW -eq 'W') 
                { 
                    $LonOrt = "-" 
                } 
                $LatDec = ($LatDeg + ($LatMin/60) + ($LatSec/3600)) 
                $LonDec = ($LonDeg + ($LonMin/60) + ($LonSec/3600)) 
                $LatOrt = $LatOrt + $LatDec 
                $LonOrt = $LonOrt + $LonDec 

                # Add information to CSV File 
                AddCSV 
            } 
            else 
            { 
                # Add information to CSV File 
                AddCSV 
            } 
            $LatDeg = $null 
            $LatMin = $null 
            $LatSec = $null 
            $LonDeg = $null 
            $LonMin = $null 
            $LonSec = $null 
            $LatNS = $null 
            $LonEW = $null 
            $LatOrt = $null 
            $LonOrt = $null    
            $LatDec = $null 
            $LonDec = $null 
        } 
    } 
    else 
    { 
        Write-Host "Source Test Path Failed" 
    } 
}

