
	#Create the even trigger like so:

	$SubscriptionDefinition = "<QueryList><Query Id=`"0`" Path=`"Application`"><Select Path=`"Application`">*[System[EventID=1999]]</Select></Query></QueryList>"

	$class = cimclass MSFT_TaskEventTrigger root/Microsoft/Windows/TaskScheduler
	$taskTriggerEvent = $class | New-CimInstance -ClientOnly
	$taskTriggerEvent.Enabled = $true
	$taskTriggerEvent.Subscription = $SubscriptionDefinition


	$taskAction = New-ScheduledTaskAction -Execute 'F:\Scripts\Sandbox\PowerShell.ScheduledTask.Creator\tmp\mbox.bat' -Argument "NEWEVENT EVENT1999"

	# The name of your scheduled task.
	$taskName = "DevelopmentTasks\TestEvent"

	# Describe the scheduled task.
	$description = "New Event"

	# Register the scheduled task
	Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTriggerEvent -Description $description

