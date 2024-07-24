
#You need to load the assembly before you can use the function            
#
#Merge-PDF -path c:\pdf_docs -filename c:\saved_docs.pdf


$ObjImported = Add-Type -Path "$PWD\PdfSharp.dll" -Verbose -PassThru
            
Function Merge-PDF {            
    Param($path, $filename)                        
            
    $output = New-Object PdfSharp.Pdf.PdfDocument            
    $PdfReader = [PdfSharp.Pdf.IO.PdfReader]            
    $PdfDocumentOpenMode = [PdfSharp.Pdf.IO.PdfDocumentOpenMode]                        
            
    foreach($i in (gci $path *.pdf -Recurse | sort)) {            
        $input = New-Object PdfSharp.Pdf.PdfDocument            
        $input = $PdfReader::Open($i.fullname, $PdfDocumentOpenMode::Import)            
        $input.Pages | %{$output.AddPage($_)}            
    }                        
            
    $output.Save($filename)            
}