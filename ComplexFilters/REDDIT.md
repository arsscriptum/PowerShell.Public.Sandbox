People are often not aware of the extensibility of the ```Where-Object``` cmdlet and how you can leverage it's power to create complex filters.

I'm talking about creating a ```scriptblock``` containing the filtering logic and using it in your command

For Example: here, let's create a **scriptblock** named ```$custom_groupfilter```;
1. In it, I declare a ```RegEx``` expression matching the mail domains you specified ```'microsoft.com|google.com|yahoo.com'```
2. I have a boolean variable named ```$valid``` that will be returned by the scriptblock: ```$False``` and the value is filtered out from the ```Where``` clause, ```$True``` it is included
3. I declare a variable **cat** ( ```$cat=$_.GroupCategory``` ) and **usermail** ( ```$usermail=$_.Mail``` ) - Note the ```$_``` . This represent the current instance in the pipeline.
4. if the group category is Distribution and if the maildomain match, set the return value to $true


Complete filer script block


```
  $custom_groupfilter = {
	$valid=$False
	[Regex]$rg = 'microsoft.com|google.com|yahoo.com'
    $cat=$_.GroupCategory
	$usermail=$_.Mail
	$manager=$_.ManagedBy 		# used later in the pipeline

	# checking if the usermail matches the domain we listed
	$maildomain_match = ($rg.Match($usermail)).Success	
	# if the group category is Distribution and if the maildomain match, set the return value to $true
	if( ($cat -eq "Distribution") -and ($maildomain_match -eq $True) ) { $valid=$True }
    $valid
  }
```

Now, we use it like so:


```
  # filter the ad groups with our expression
  $groups = Get-ADGroup -Server server | Where $custom_groupfilter

  # additional select logic...
  $groups = $groups | Select Name,Mail,SamAccountName,@{Name='ManagedBy';Expression={(Get-ADUser $manager -Properties Mail).Mail}},ProxyAddresses

```