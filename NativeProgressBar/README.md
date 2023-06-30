# PowerShell.NativeProgressBar

The native version of my progress bar project located at https://github.com/arsscriptum/PowerShell.CustomProgressBar


---------------------------------------------------------------------------------------------------------

### RATIONALE

To provides a nice, compact way to display the progress of longer-running tasks in PowerShell. Show that the jobs are active and provide time remaining.

You can use it as a replacement for Write-Progress. While this has the advantage of being a "native" cmdlet with a few options to customize the progress of tasks, it occupies a bit of real estate in the PowerShell window (the upper portion of the console), sometimes hiding interesting information. 

Both ```Show-ActivityIndicatorBar``` and ```Show-NativeProgressBar```  function is only a single line of text, at the current cursor position, and does not hide any output or status messages from other commands.

The ```Show-ActivityIndicatorBar``` function shows an animation to represent activity in the job

The ```Show-NativeProgressBar``` displays a progress bar with completion percentage

---------------------------------------------------------------------------------------------------------


### HOW TO USE

```Register-NativeProgressBar```

Called once, before the job is started. Initialize the progress bar with default settings, no countdown timer sizr of 30 character

```Register-NativeProgressBar 30 ```
Initialize the progress bar so that it will diaplay a countdown timer for 30 seconds


```Write-ActivityIndicatorBar```
Called at every iteration of the loop
Shows an animation to represent activity in the job

```Write-NativeProgressBar```

Called at every iteration of the loop
Without any arguments, Show-NativeProgressBar displays a progress bar refreshing at every 100 milliseconds.
If no value is provided for the Activity parameter, it will simply say "Current Task" and the completion percentage.

```Write-NativeProgressBar 50 5 "Yellow"```
Displays a progress bar refreshing at every 50 milliseconds in Yellow color


---------------------------------------------------------------------------------------------------------
### To Compile

Load Visual Studio and compile ```NativeProgressBar.csproj```


---------------------------------------------------------------------------------------------------------
### To Run Test

```
    .\test\RunTest.ps1 10 
```



### Activity Indicator
![Activity Indicator](https://arsscriptum.github.io/assets/img/posts/custom-progressbar/ActivityIndicator.gif)

### Progress Bar
![Progress Wheel](https://arsscriptum.github.io/assets/img/posts/custom-progressbar/ProgressWheel.gif)

### Progress Bar Demo
![Progress Wheel Demo](https://arsscriptum.github.io/assets/img/posts/custom-progressbar/ProgressWheelDemo.gif)
