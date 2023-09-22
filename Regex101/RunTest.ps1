<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>



[CmdletBinding(SupportsShouldProcess)]
param()

function Invoke-RegEx101Search{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True, Position = 0)]
        [string]$SearchString
    ) 
    process{
      try{
        $header = @{
          "Content-Type" = "application/json"
        }

        $url = "https://regex101.com/api/library/1/"

        $querystring = @{"search"="$SearchString"}

        $Res = Invoke-RestMethod -Uri $url -Body $querystring -Headers $header -Method GET
        return $Res
      }catch{
        write-error "$_"
      }
    }
}

function Invoke-RegEx101GetEntry{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True, Position = 0)]
        [string]$UniqueId
    ) 
    process{
      try{
        $header = @{
          "Content-Type" = "application/json"
        }

        $url = "https://regex101.com/api/regex/{0}/1" -f $UniqueId

        $querystring = @{"search"="$SearchString"}

        $Res = Invoke-RestMethod -Uri $url -Body $querystring -Headers $header -Method GET
        return $Res
      }catch{
        write-error "$_"
      }
    }
}

function Invoke-RegEx101Create{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$True, Position = 0)]
        [string]$RegEx,
        [Parameter(Mandatory=$True, Position = 1)]
        [string]$TestString
    ) 
    process{
      try{

        $url = "https://regex101.com/api/regex"
    

        $querystring = @{
          regex = "$RegEx"
          testString = "$TestString"
          flags = 'mg'
          delimiter = '/'
          flavor = 'pcre'
        }

      $Res = Invoke-RestMethod -Uri $url -Body $querystring -Method POST
      return $Res

      }catch{
        write-error "$_"
      }
    }
}


try{  

  # Create
  $regex_str = '(?<UserName>^[\w-\.]+)@(?<HostName>([\w-]+)+)(?<dot>\.)(?<Suffix>[\w-]{2,4})$'
  $test_str = 'guillaume@test.com'
  Write-Host "Create Entry for`n`tRegex = `"$regex_str`"`n`tTest String = `"$test_str`"`n" -f Yellow
  $res = Invoke-RegEx101Create -RegEx $regex_str -TestString $test_str
  Write-Host "----- Success! -----`n" -f Green

  # List
  $unique_id = $res.permalinkFragment
  Write-Host "Get Entry Data`n`tunique_id = `"$unique_id`"`n" -f Yellow
  $res = Invoke-RegEx101GetEntry -UniqueId "$unique_id"
  Write-Host "----- Success! -----`n" -f Green
  Write-Host "Result: `n`tDate: $($res.dateCreated)`n`tRegEx: $($res.regex)`n`tTestString: $($res.testString)`n" -f Cyan
  # Search
  $search_str = 'String'
  Write-Host "Searching for `"$search_str`""
  $SearchResults = Invoke-RegEx101Search -SearchString "$search_str"
  $res_count = $SearchResults.data.Count

  Write-Host "Success!`n`tFound $res_count entries" -f Green

  $i = 1
  $search_str = 'test'
  Write-Host "Searching for `"$search_str`""
  $SearchResults = Invoke-RegEx101Search -SearchString "$search_str"
  $res_count = $SearchResults.data.Count
  Write-Host "Results:" -f Cyan
  Write-Host "Success!`n`tFound $res_count entries" -f Green
  
  ForEach($r in $SearchResults.data){
     Write-Host "`n----- SEARCH RESULT ENTRY $i -----`n" -f Red
     $i++
     Write-Host "  title:`t$($r.title)`n  date :`t$($r.dateCreated)`n  desc :`t$($r.description)" -f Gray
     
  }
}catch{
  write-error "$_"
}