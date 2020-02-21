function Get-TreeSize ($folder = $null)
{
    #Function to get recursive folder size
    $result = @()
#    $folderResult = "" | Select-Object FolderPath, FolderName, SizeKB, SizeMB, SizeGB, OverThreshold
    $folderResult = "" | Select-Object FolderPath, SizeGB

    $contents  = Get-ChildItem $folder.FullName -recurse -force -erroraction SilentlyContinue -Include * | Where-Object {$_.psiscontainer -eq $false} | Measure-Object -Property length -sum | Select-Object sum
#    $sizeKB = [math]::Round($contents.sum / 1000,3)   #.ToString("#.##")
#    $sizeMB = [math]::Round($contents.sum / 1000000,3)   #.ToString("#.##")
    $sizeGB = [math]::Round($contents.sum / 1000000000,3)   #.ToString("#.###")

    $folderResult.FolderPath = $folder.FullName
 #   $folderResult.FolderName = $folder.BaseName
 #   $folderResult.SizeKB = $sizeKB
#    $folderresult.SizeMB = $sizeMB
    $folderresult.SizeGB = $sizeGB
    $result += $folderResult

    return $result
} 


#Use the function like this for a single directory
#$topDir = get-item "C:\users"
#Get-TreeSize ($topDir)

#Use the function like this for all top level folders within a direcotry
#$topDir = gci -directory "\\server\share\folder"
$topDir = Get-ChildItem -directory "d:\"
foreach ($folderPath in $topDir) {Get-TreeSize $folderPath}