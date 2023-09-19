Add-Type -AssemblyName  Microsoft.VisualBasic, PresentationCore, PresentationFramework, System.Drawing, System.Windows.Forms, WindowsBase, WindowsFormsIntegration, System; Add-Type -TypeDefinition 'namespace Windows.Native{using System;using System.ComponentModel;using System.IO;using System.Runtime.InteropServices;public class Kernel32{public const uint FILE_SHARE_READ = 1;public const uint FILE_SHARE_WRITE = 2;public const uint GENERIC_READ = 0x80000000;public const uint GENERIC_WRITE = 0x40000000;public static readonly IntPtr INVALID_HANDLE_VALUE = new IntPtr(-1);public const int STD_ERROR_HANDLE = -12;public const int STD_INPUT_HANDLE = -10;public const int STD_OUTPUT_HANDLE = -11;[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]public class CONSOLE_FONT_INFOEX{private int cbSize;public CONSOLE_FONT_INFOEX(){this.cbSize = Marshal.SizeOf(typeof(CONSOLE_FONT_INFOEX));}public int FontIndex;public short FontWidth;public short FontHeight;public int FontFamily;public int FontWeight;[MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]public string FaceName;}public class Handles{public static readonly IntPtr StdIn = GetStdHandle(STD_INPUT_HANDLE);public static readonly IntPtr StdOut = GetStdHandle(STD_OUTPUT_HANDLE);public static readonly IntPtr StdErr = GetStdHandle(STD_ERROR_HANDLE);}[DllImport("kernel32.dll", SetLastError=true)]public static extern bool CloseHandle(IntPtr hHandle);[DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]public static extern IntPtr CreateFile([MarshalAs(UnmanagedType.LPTStr)] string filename,uint access,uint share,IntPtr securityAttributes, [MarshalAs(UnmanagedType.U4)] FileMode creationDisposition,uint flagsAndAttributes,IntPtr templateFile);[DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]public static extern bool GetCurrentConsoleFontEx(IntPtr hConsoleOutput, bool bMaximumWindow, [In, Out] CONSOLE_FONT_INFOEX lpConsoleCurrentFont);[DllImport("kernel32.dll", SetLastError=true)]public static extern IntPtr GetStdHandle(int nStdHandle);[DllImport("kernel32.dll", SetLastError=true)]public static extern bool SetCurrentConsoleFontEx(IntPtr ConsoleOutput, bool MaximumWindow,[In, Out] CONSOLE_FONT_INFOEX ConsoleCurrentFontEx);public static IntPtr CreateFile(string fileName, uint fileAccess, uint fileShare, FileMode creationDisposition){IntPtr hFile = CreateFile(fileName, fileAccess, fileShare, IntPtr.Zero, creationDisposition, 0U, IntPtr.Zero);if (hFile == INVALID_HANDLE_VALUE){throw new Win32Exception();}return hFile;}public static CONSOLE_FONT_INFOEX GetCurrentConsoleFontEx(){IntPtr hFile = IntPtr.Zero;try{hFile = CreateFile("CONOUT$", GENERIC_READ,FILE_SHARE_READ | FILE_SHARE_WRITE, FileMode.Open);return GetCurrentConsoleFontEx(hFile);}finally{CloseHandle(hFile);}}public static void SetCurrentConsoleFontEx(CONSOLE_FONT_INFOEX cfi){IntPtr hFile = IntPtr.Zero;try{hFile = CreateFile("CONOUT$", GENERIC_READ | GENERIC_WRITE,FILE_SHARE_READ | FILE_SHARE_WRITE, FileMode.Open);SetCurrentConsoleFontEx(hFile, false, cfi);}finally{CloseHandle(hFile);}}public static CONSOLE_FONT_INFOEX GetCurrentConsoleFontEx(IntPtr outputHandle){CONSOLE_FONT_INFOEX cfi = new CONSOLE_FONT_INFOEX();if (!GetCurrentConsoleFontEx(outputHandle, false, cfi)){throw new Win32Exception();}return cfi;}}}'; 

$FontAspects = [Windows.Native.Kernel32]::GetCurrentConsoleFontEx()
$FontAspects.FontIndex = 0; $FontAspects.FontWidth = 8
$FontAspects.FontHeight = 8; $FontAspects.FontFamily = 48
$FontAspects.FontWeight = 400; $FontAspects.FaceName = "Terminal"
[Windows.Native.Kernel32]::SetCurrentConsoleFontEx($FontAspects)

[int]$nScreenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width / 8
[int]$nScreenHeight = ([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height / 8) - 12

$host.UI.RawUI.BufferSize = [Management.Automation.Host.Size]::new(($nScreenWidth), ($nScreenHeight))
$host.UI.RawUI.WindowSize = [Management.Automation.Host.Size]::new(($nScreenWidth), ($nScreenHeight))

$sig = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'; Add-Type -MemberDefinition $sig -Name NativeMethods -Namespace Win32
(Get-Process Powershell).MainWindowHandle | ForEach-Object { [Win32.NativeMethods]::ShowWindowAsync($_, 3) } | Out-Null


function Image {
    param([string]$imagePath = "C:\Users\OBAMA\OneDrive\Desktop\R (1).png", $sx = 0, $sy = 0)

    $gradient = " .:-=+*#%@".ToCharArray()
    $bitmap = [System.Drawing.Bitmap]$imagePath 
    
    for ($y = 0; $y -lt $bitmap.Height; $y++) {
        for ($x = 0; $x -lt $bitmap.Width; $x++) {

            $pixelColor = $bitmap.GetPixel($x, $y)
            $brightness = ($pixelColor.R * 0.299 + $pixelColor.G * 0.587 + $pixelColor.B * 0.114) / 255
            $alpha = $pixelColor.A / 255
            $index = [int]($brightness * $alpha * ($gradient.Length - 1))
        
            $screen[$y + $sy] = $screen[$y + $sy].Remove($x + $sx, 1)
            $screen[$y + $sy] = $screen[$y + $sy].Insert($x + $sx, $gradient[$index])

        }
    }
}

function GifToAscii {
    param([string]$gifPath = "", $sx = 0, $sy = 0)
    $gradient = " .:-=+*#%@".ToCharArray()

    $gif = [Drawing.Bitmap]::FromFile($gifPath)
    $dimension = [System.Drawing.Imaging.FrameDimension]::new($gif.FrameDimensionsList[0])
    $frameCount = $gif.GetFrameCount($dimension)

    for ($frameIndex = 0; $frameIndex -lt $frameCount; $frameIndex++) {

        $gif.SelectActiveFrame($dimension, $frameIndex)
        $bmp = [Drawing.Bitmap]::new($gif)

        for ($y = 0; $y -lt $bmp.Height; $y++) {
            for ($x = 0; $x -lt $bmp.Width; $x++) {

                $pixelColor = $bmp.GetPixel($x, $y)
                $brightness = ($pixelColor.R * 0.299 + $pixelColor.G * 0.587 + $pixelColor.B * 0.114) / 255
                $alpha = $pixelColor.A / 255
                $index = [math]::Min([int]($brightness * $alpha * ($gradient.Length - 1)), $gradient.Length - 1)
                [system.console]::title = "$x $y"
                
                $screen[$y + $sy] = $screen[$y + $sy].Remove($x + $sx, 1)
                $screen[$y + $sy] = $screen[$y + $sy].Insert($x + $sx, $gradient[$index])
            }
        }
    }

}

While (1) {

    $sw = [Diagnostics.Stopwatch]::StartNew()
    $screen = @(" " * $nScreenWidth) * $nScreenHeight


    GifToAscii "(Gif Path)" 10 10 | Out-Null

    $sw.Stop()
    $fps = [math]::Round(10000000 / $sw.ElapsedTicks)
    [system.console]::title = "Made by: Jh1sc - FPS: $fps"
    [char]27 + "[0;0H"
    [console]::write([string]::Join("`n", $screen))
}