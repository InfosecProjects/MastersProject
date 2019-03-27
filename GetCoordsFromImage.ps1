Function Get-FileContents {
     param($file)
     #$file = "C:\Users\IEUser\Downloads\IMG_20181217_220612.jpg"
     # Creates the full path for the file
     Try {
          $fullPath = (Resolve-Path $file).path
          # Creates a file handle to the image
          $fs = [System.IO.File]::OpenRead($fullPath)
          # Reads the image to allow parsing for EXIF data
          $image = [System.Drawing.Image]::FromStream($fs, $false, $false)
     }
     Catch {
          if (($fs) -or ($image)){
               $image.dispose()
               $fs.close()
          }
          Write-Error "Error Opening $file"
          return
     }
     $maker = Get-ExifContents -image $image -exifCode "271"
     $model = Get-ExifContents -image $image -exifCode "272"
     $version = Get-ExifContents -image $image -exifCode "305"
     $dateTime = Get-ExifContents -image $image -exifCode "306"
     $lat = Get-Coordinates -image $image -exifCode "2"
     $long = Get-Coordinates -image $image -exifCode "4"
     $latRef = Get-ExifContents -image $image -exifCode "1"
     $longRef = Get-ExifContents -image $image -exifCode "3"
     $altitude = Get-Coordinates -image $image -exifCode "6"
     # Puts all the EXIF data in a PSObject to return
     $exifData = [pscustomobject][ordered]@{
          File = $file
          CameraMaker = $maker
          CameraModel = $model
          SoftwareVersion = $version
          DateTaken = $dateTime
          Latitude = [string]$lat + $latRef
          Longitude = [string]$long + $longRef
          Altitude = $altitude
     }
     if ($exifData.Latitude -eq "<empty><empty>"){
          $exifData.Latitude = "<empty>"
     }
     if ($exifData.Longitude -eq "<empty><empty>"){
          $exifData.Longitude = "<empty>"
     }
     # releases the file handles
     $image.dispose()
     $fs.Close()
     return $exifData
}
Function Get-ExifContents {
     param($image, $exifCode)
     # Trys to pull the EXIF data from the file
     Try {
          # Pulls the property from the file based on the EXIF tag
          $PropertyItem = $image.GetPropertyItem($exifCode)
          # Grabs only the value from the property item
          $valueBytes = $PropertyItem.value
          # Converts the byte array in an ASCII String
          $value = [System.Text.Encoding]::ASCII.GetString($valueBytes)
     }
     # If it fails to pull the property from the photo, sets the value to "<empty>" 
     Catch{
          $value = "<empty>"     
     }
     return $value
}
Function Get-Coordinates{
     param($image, $exifCode)
     Try {
          $propertyItem = $image.GetPropertyItem($exifCode)
          $valueBytes = $propertyItem.value
          [double]$degree = (([System.BitConverter]::ToInt32($valueBytes, 0)) / ([System.BitConverter]::ToInt32($valueBytes,4)))
          [double]$minute = (([System.BitConverter]::ToInt32($valueBytes, 8)) / ([System.BitConverter]::ToInt32($valueBytes,12)))
          [double]$second = (([System.BitConverter]::ToInt32($valueBytes, 16)) / ([System.BitConverter]::ToInt32($valueBytes,20)))
          $value = $degree + ($minute / 60) + ($second / 3600)
     }
     Catch {
          $value = "<empty>"
     }
     return $value
}
