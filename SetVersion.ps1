# SetVersion.ps1
#
# Set the version in all the AssemblyInfo.cs or AssemblyInfo.vb files in any subdirectory.
#
# usage:  
#  from cmd.exe: 
#     powershell.exe SetVersion.ps1 2.8.3.0 2.8.3.0-beta123
# 
#  from powershell.exe prompt: 
#     .\SetVersion.ps1 2.8.3.0 2.8.3.0-beta123
#
# last saved Time-stamp: <Wednesday, April 23, 2008  11:52:15  (by dinoch)>
# modified by dannevesdantas on 03-11-2021
#

param (
  [Parameter(Mandatory = $true)][string]$version,
  [Parameter(Mandatory = $true)][string]$infoVersion
)

function Usage {
  echo "Usage: ";
  echo "  from cmd.exe: ";
  echo "     powershell.exe SetVersion.ps1  2.8.3.0";
  echo " ";
  echo "  from powershell.exe prompt: ";
  echo "     .\SetVersion.ps1  2.8.3.0";
  echo " ";
}


function Update-SourceVersion {
  Param ([string]$Version, [string]$InfoVersion)
  $NewVersion = 'AssemblyVersion("' + $Version + '")';
  $NewFileVersion = 'AssemblyFileVersion("' + $Version + '")';
  $NewInformationalVersion = 'AssemblyInformationalVersion("' + $InfoVersion + '")';

  foreach ($o in $input) {
    Write-output $o.FullName
    $TmpFile = $o.FullName + ".tmp"

    Get-Content $o.FullName -encoding utf8 |
    % { $_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewVersion } |
    % { $_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewFileVersion }  |
    % { $_ -replace 'AssemblyInformationalVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', $NewInformationalVersion }  |
    Set-Content $TmpFile -encoding utf8
    
    move-item $TmpFile $o.FullName -force
  }
}


function Update-AllAssemblyInfoFiles ( $version, $infoVersion ) {
  foreach ($file in "AssemblyInfo.cs", "AssemblyInfo.vb" ) {
    get-childitem -recurse | ? { $_.Name -eq $file } | Update-SourceVersion $version $infoVersion ;
  }
}


# validate arguments 
$r = [System.Text.RegularExpressions.Regex]::Match($version, "^[0-9]+(\.[0-9]+){1,3}$");

if ($r.Success) {
  Update-AllAssemblyInfoFiles $version $infoVersion;
}
else {
  Write-Error -Message "Bad Input! From powershell.exe prompt: .\SetVersion.ps1 2.8.3.0" -Category InvalidArgument -ErrorAction Stop
  #Usage ;
}
