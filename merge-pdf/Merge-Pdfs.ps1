
function Merge-Pdf
{
<#
.Synopsis
   Merges multiple pdf files into one
.DESCRIPTION
   Merge-Pdf cmdlet joins all the pages of provided pdf files into one pdf. If no OutputPath value provided it creates Merged.pdf in current location.
.EXAMPLE
   Merge-Pdf
   Gets all .PDF files in current location and merges them into .\Merged.pdf
.EXAMPLE
   Merge-Pdf -OutputPath c:\output\out.pdf -Path c:\input\in.pdf -Append
   Appends in.pdf to out.pdf
.EXAMPLE
   Merge-Pdf -OutputPath c:\output\out.pdf
   Merges all .PDF files in current location into c:\output\out.pdf
.EXAMPLE
   Merge-Pdf -Path c:\input\ -OutputPath c:\output\out.pdf
   Merges all .PDF files in folder c:\input into c:\output\out.pdf
.EXAMPLE
   'c:\input\file1.pdf', 'c:\input\file2.pdf' | Merge-Pdf -OutputPath c:\output\out.pdf
   Merges .PDF files provided from pipeline into c:\output\out.pdf
.INPUTS
   Array of PowerShell Paths, output path for the result
.OUTPUTS
   Merge-Pdf does not return any output. There can be error, warning or verbose messages.
.NOTES
   The cmdlet uses PdfSharp library available under MIT licence.
#>
    [cmdletbinding(SupportsShouldProcess=$true)]
    param(
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [string[]]$Path = '.',
        [string]$OutputPath = 'Merged.pdf',
        [switch]$Append,
        [switch]$Force
    )
    begin
    {
        if ($OutputPath -eq 'Merged.pdf')
        {
            Write-Warning "OutputPath parameter is not provided. Using current location."
        }

        $outputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
        
        if ((Test-Path $OutputPath) -and (Get-Item $OutputPath).PSIsContainer)
        {
            $OutputPath = Join-Path $OutputPath Merged.pdf
        }

        if (Test-Path $OutputPath)
        {
            Write-Verbose "Force: $($Force.IsPresent)"
            Write-Verbose "Append: $($Append.IsPresent)"
            if (-not $Force.IsPresent -and -not $Append.IsPresent)
            {
                throw "$OutputPath already exists. Use -Force parameter to rewrite the file."
            }
            elseif ((-not $Append.IsPresent) -and $pscmdlet.ShouldProcess($OutputPath, "Delete existing PDF"))
            {
                Remove-Item $OutputPath -Force
            }
        }

        if ($Append.IsPresent) 
        {
            $outputDocument = [PdfSharp.Pdf.IO.PdfReader]::Open($OutputPath, [PdfSharp.Pdf.IO.PdfDocumentOpenMode]::Open)
            Write-Verbose "Opened file $outputDocument with $($outputDocument.PageCount) pages."
        }
        else 
        {
            $outputDocument = New-Object PdfSharp.Pdf.PdfDocument
        }
    }
    process
    {
        $files = (Resolve-Path $path).Path
        Write-Verbose "Resoved paths: $files"

        $files = $files | Get-ChildItem -Filter *.pdf
        
        Write-Verbose "Expanded paths: $($files | select -ExpandProperty FullName)"

        $files = $files | select -ExpandProperty FullName

        try
        {
            foreach ($inputFile in $files)
            {
                $inputPdf = [PdfSharp.Pdf.IO.PdfReader]::Open($inputFile, [PdfSharp.Pdf.IO.PdfDocumentOpenMode]::Import)
                $pages = $inputPdf.Pages

                Write-Verbose "Processing $inputFile with $($inputPdf.PageCount) pages"
                for ($i = 0; $i -lt $inputPdf.PageCount; $i++)
                {
                    $outputDocument.AddPage($inputPdf.Pages[$i]) | Out-Null
                }
            }
        }
        finally
        {
            if ($null -ne $outputDocument)
            {
                $outputDocument.Dispose()
            }
        }
    }
    end
    {
        try
        {
            if ($outputDocument.PageCount -eq 0)
            {
                Write-Warning "No pages were added. File was not created."
                return
            }

            if ($pscmdlet.ShouldProcess($OutputPath, "Create merged PDF"))
            {
                $outputDocument.Save($outputPath) | Out-Null
            }

            $outputDocument.Close()
        }
        finally
        {
            if ($null -ne $outputDocument)
            {
                $outputDocument.Dispose()
            }
        }
        
        return Get-Item $OutputPath
    }
}
