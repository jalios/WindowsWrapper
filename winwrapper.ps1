#Set-StrictMode -Version 2.0

<#
.SYNOPSIS
    Wraps invocation of native windows application to prevent max path length limitation from being reached when working with very long directory and filename.
	IMPORTANT : This script MUST BE MODIFIED for each application/command use (search text "Change command here" in this script)
   
 Install this script and the associated required "Microsoft.Experimental.IO.dll" in directory "c:\WindowsWrapper\" (or anything short)
  
 You may invoke from cmd.exe using the following comman: 
   "C:/Windows/System32/WindosPowerShell/v1.0/powershell.exe" -ExecutionPolicy Bypass -File c:\WindowsWrapper\winwrapper.ps1 c:\long\path\to\in.src c:\long\path\to\out.out

 You may invoke from a Java program , using the following command :
   "C:/Windows/System32/cmd.exe" /c echo . |"C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" -ExecutionPolicy Bypass -File "c:/WindowsWrapper/winwrapper.ps1" "c:\long\path\to\in.pdf" "c:\long\path\to\out.swf" 

#>
param(
  # required
	$InPath = $null,
	$OutPath = $null,
  # optionnal
	$Width = "640",
	$Height = "480"
)

########################################################################
# Modify the following function to invoke whatever native windows application you need to run
#
function RunCmd([string]$TemporaryInFileName, [string]$TemporaryOutFileName) 
{
    Write-Output "Invoke native windows application on temporary input/output path..."
    Write-Output  "   input file  :  $TemporaryInFileName"
    Write-Output  "   output file :  $TemporaryOutFileName"
    Write-Output  "   width       :  ${Width}"
    Write-Output  "   height      :  ${Height}"
	
	# ### Change command here
    &"C:\Path to\native.exe" $TemporaryInFileName ${Width}x${Height} $TemporaryOutFileName ;
    
    # Examples : 
    
    # PDF to SWF : 
    # &"C:\Program Files (x86)\SWFTools\pdf2swf.exe" -s "internallinkfunction=handleInternalLink" -T 9 -t $TemporaryInFileName -o $TemporaryOutFileName ;
    
    # PDF to PNG : 
    # &"C:\ProgramPortable\poppler\bin\pdftocairo.exe" -png $TemporaryInFileName $TemporaryOutFileName ;
    
    # PDF to SVG : 
    # &"C:\ProgramPortable\pdf2svg\pdf2svg.exe" $TemporaryInFileName $TemporaryOutFileName all ;
    
    # ImageMagick thumbnail generation from PDF, Postscript file and Illustrator files
    # application/pdf, application/postscript and application/illustrator
    # &"C:\ProgramPortable\ImageMagick\convert.exe" "$TemporaryInFileName[0]" -colorspace rgb -resize ${Width}x${Height} "$TemporaryOutFileName"
    
    # ImageMagick thumbnail generation from any image, eg TIFF (image/tiff)
    # &"C:\ProgramPortable\ImageMagick\convert.exe" "$TemporaryInFileName" -colorspace rgb -resize ${Width}x${Height} "$TemporaryOutFileName"
    
    # You may find some help in the article "PowerShell and external commands done right"
    #   http://edgylogic.com/blog/powershell-and-external-commands-done-right/
    # If needed, debug your command with echoargs from PowerShell Community Extension
    #   http://pscx.codeplex.com/
    # &"EchoArgs.exe" -a -b $TemporaryInFileName -c -d $TemporaryOutFileName
    
    
	# ### 
	
    $script:CmdExitCode = $LastExitCode ;
}

########################################################################

function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}

$script:ScriptDirectoryPath = Get-ScriptDirectory;
$script:MsExperimentalAssemblyPath =  "$ScriptDirectoryPath\Microsoft.Experimental.IO.dll"
$script:MsExperimentalAssembly = [System.Reflection.Assembly]::LoadFrom($script:MsExperimentalAssemblyPath)
if (!$script:MsExperimentalAssembly) {
    Write-Error "Required Microsoft.Experimental.IO library could not be loaded from" $script:MsExperimentalAssemblyPath
    exit 1;
}

function main() {
    Write-Output  "input file  :  $InPath"
    Write-Output  "output file :  $OutPath"

    $inTmp = [System.IO.Path]::GetTempFileName() ;
    $outTmp = [System.IO.Path]::GetTempFileName() ;
    
    # Use a temporary filename with the same extension as the original out filename (if any)
    # It is required for some app to indicate the destination format
    $outExtension = [System.IO.Path]::GetExtension($OutPath) ;
    if (![string]::IsNullOrEmpty($outExtension)) 
    {
        $outTmp = [System.IO.Path]::GetTempPath() + ([System.Guid]::NewGuid()).ToString() + "$outExtension";
    }
    
    Write-Output  "Temporary input file  :  $inTmp"
    Write-Output  "Temporary output file :  $outTmp"
    
    Write-Output "Copy input source file to temporary directory file with short path and filename..."
    # Copy-Item $InPath $inTmp ;
    [Microsoft.Experimental.IO.LongPathFile]::Copy($InPath, $inTmp, $true);
    
	# Invoke native command
	RunCmd $inTmp $outTmp;
    
    # Move-Item $outTmp $OutPath ;
    if (Test-Path -PathType Leaf $outTmp) {
        if ([Microsoft.Experimental.IO.LongPathFile]::Exists($OutPath)) {
            Write-Output "Delete existing output file..." 
            [Microsoft.Experimental.IO.LongPathFile]::Delete($OutPath);
        }
        Write-Output "Move new file to its final destination..."
        [Microsoft.Experimental.IO.LongPathFile]::Move($outTmp, $OutPath);
    }
    
    Remove-Item $inTmp ;
    
    Write-Output "Exit with status $script:CmdExitCode"
    exit $script:CmdExitCode;
}

main;
