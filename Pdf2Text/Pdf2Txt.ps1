################################################################################
# TextFromPdf - A PowerShell module for extracting text from PDF.
# Copyright (C) 2016 Antony Onipko
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

Function getTextFromLocation ($page, $x, $y, $w, $h) {
    $boundingBox = New-Object iText.Kernel.Geom.Rectangle($x, $y, $w, $h) # x, y, width, height
    $filter = New-Object iText.Kernel.Pdf.Canvas.Parser.Filter.TextRegionEventFilter($boundingBox)
    $strategy = New-Object iText.Kernel.Pdf.Canvas.Parser.Listener.FilteredTextEventListener(
        #(New-Object iText.Kernel.Pdf.Canvas.Parser.Listener.LocationTextExtractionStrategy),
        (New-Object iText.Kernel.Pdf.Canvas.Parser.Listener.SimpleTextExtractionStrategy),
        $filter
    )
    return [iText.Kernel.Pdf.Canvas.Parser.PdfTextExtractor]::GetTextFromPage($page, $strategy)
}
Function getTextFromPage ($page) {
    return [iText.Kernel.Pdf.Canvas.Parser.PdfTextExtractor]::GetTextFromPage($page)
}
################################################################################

Function Get-TextFromPDF {
    <#
        .SYNOPSIS
        Extracts text values from PDFs using the iText 7 library.
        
        .EXAMPLE
        Get-TextFromPDF -Path 'c:\temp\receipt01.pdf'

        .EXAMPLE
        '.\receipt01.pdf', '.\receipt02.pdf' | Get-TextFromPDF
        
        .DESCRIPTION
        By default set up to work with receipts, but the extraction rules can be
        customised by passing a different RuleSet variable. Text is cleaned up using
        the TextCleanup scriptblock.
        It might be possible to obtain better results by using a different
        TraverseHeight.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PsObject])]
    Param
    (
        # Path of the PDF to process.
        [Parameter(Mandatory=$true,
                   Position=1,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [Alias('FullName')]
        [ValidateScript({Test-Path $_})]
        [string]$Path
    )

    Process {
        
        try {
            $reader = New-Object iText.Kernel.Pdf.PdfReader $Path
            $pdf = New-Object iText.Kernel.Pdf.PdfDocument $reader
        } catch {
            Write-Error $_.Exception.Message
            return
        }

        [System.Collections.ArrayList]$AllPagesText = [System.Collections.ArrayList]::new()
        for ($pageNumber = 1; $pageNumber -le $pdf.GetNumberOfPages(); $pageNumber++) {
    
            $page = $pdf.GetPage($pageNumber)
            $pageSize = $page.GetPageSize()

            $text = getTextFromPage($page)

            if (![string]::IsNullOrWhiteSpace($text)) {
                [void]$AllPagesText.Add($text)
            }
            <#
            if (!$TraverseHeight) {
                $TraverseHeight = $RatioHeightBase * ($pageSize.GetHeight() / $pageSize.GetWidth())
            }

            [float]$x = 0
            [float]$y = $pageSize.GetHeight() - $TraverseHeight
            [float]$w = $pageSize.GetWidth()
            [float]$h = $TraverseHeight

            for ( ; $y -ge 0 ; $y -= $TraverseHeight) {

                $text = getTextFromLocation $page $x $y $w $h

                if (![string]::IsNullOrWhiteSpace($text)) {

                    $text = & $TextCleanup $text

                    Write-Verbose "$x,$y :  $text"

                    $RuleSet | ? { !$results."$($_.Name)" } | % {
                        if (($m = [regex]::Match($text, $_.Expression)).Success) {
                            if ($_.Function) {
                                $value = & $_.Function.GetNewClosure()
                            } else {
                                $value = $m.Value
                            }
                            Write-Verbose "    $($_.Name): $($value)"
                            $results."$($_.Name)" = $value
                        }
                    }

                }

            }#>

        }
        $AllPagesText

        if ($reader) {
            $reader.Close()
        }

        Write-Output $results

    }

}
