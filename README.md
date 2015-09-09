# Windows Wrapper

This projects provides a PowerShell script to wrap invocation of native windows  application suffering from max path length limitation when working with very long directory and filenames.

Notable examples of command line programs failing to work with long filenames :
  - **Poppler pdftocairo**, _for PDF to PNG conversion_
  - **Poppler pdf2svg**, _for PDF to SVG conversion_
  - **SWFTools PDF2SWF**, _for PDF to SWF conversion_
  - **ImageMagick convert**, _for image manipulation such as thumbnail generation_

**Usage**

The script receives 2 required and 2 optionals parameters,in the following order, to match the common uses of the aboved mention programs : 
  1.  input filename
  2.  output filename
  3.  width (_for use during thumbnail creation_)
  4.  height (_for use during thumbnail creation_)

You may invoke the wrapper from a Java program by using the following command in a [Process](http://docs.oracle.com/javase/7/docs/api/java/lang/Process.html) invocation : 
```
"C:/Windows/System32/cmd.exe" /c echo . |"C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" -ExecutionPolicy Bypass -File "c:/WindowsWrapper/winwrapper.ps1" "c:/long/path/to/in.src" "c:/long/path/to/out.dest" 
```

**Implementation**

In order to workaround the maxpath filename limitations, this script perform the following steps :
  * computes 2 temporary filename (with a short filename since they are generated using native windows API) : 
    * one for the temporary input file
    * one for the temporary outpule file (using the same extension as the specified outputfile)
  * copies the input file to the temporary input file (*)
  * invokes the native command using the temporary "short" files
  * move the temporary output file to the temporary input file (*)
  * delete the temporary input file

(*) using [Microsoft Experimental IO](https://www.nuget.org/packages/Microsoft.Experimental.IO/) to support long filename)

**Additional resources**
 * [Microsoft Experimental IO](https://www.nuget.org/packages/Microsoft.Experimental.IO/)
 * [PowerShell and external commands done right](http://edgylogic.com/blog/powershell-and-external-commands-done-right/)
 * [PowerShell Community Extension](http://pscx.codeplex.com/)

