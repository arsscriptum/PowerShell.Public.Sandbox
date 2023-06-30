
/*
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
*/


using System;
using System.Text;
using System.Management.Automation;
using System.Diagnostics;
using NativeProgressBar.Utility;

namespace NativeProgressBar.Functions
{
    [Cmdlet(VerbsCommunications.Write, "NativeProgressBar")]
    public class WriteNativeProgressBar : BaseNativeProgressBarCmdlet
    {

        [Parameter(Position = 0, Mandatory = true)]
        public int Percentage
        {
            get { return percentage; }
            set { percentage = value; }
        }
        private int percentage;

        [Parameter(Position = 1, Mandatory = true)]
        public string Message
        {
            get { return message; }
            set { message = value; }
        }
        private string message;

        [Parameter(Position = 2, Mandatory = false)]
        public int UpdateDelay
        {
            get { return updatedelay; }
            set { updatedelay = value; }
        }
        private int updatedelay = 100;

        [Parameter(Position = 3, Mandatory = false)]
        public int ProcessDelay
        {
            get { return processdelay; }
            set { processdelay = value; }
        }
        private int processdelay = 5;

        [Parameter(Position = 4, Mandatory = false)]
        public ConsoleColor ForegroundColor
        {
            get { return foregroundColor; }
            set { foregroundColor = value; }
        }
        private ConsoleColor foregroundColor;


        [Parameter(Position = 5, Mandatory = false)]
        public ConsoleColor BackgroundColor
        {
            get { return backgroundColor; }
            set { backgroundColor = value; }
        }
        private ConsoleColor backgroundColor;

        protected override void BeginProcessing()
        {
            Globals.GShowCursor = BaseCommonParmeters.ShowCursor;
            string msg = String.Format("Begin Write-NativeProgressBar. GShowCursor {0}", Globals.GShowCursor);
            WriteVerbose(msg);
        }

        protected override void ProcessRecord()
        {
        
            bool wasCursorVisible = Console.CursorVisible;
            
            if (Globals.GShowCursor == false)
            {
                Console.CursorVisible = false;
            }

            TimeSpan timeSpan = Globals.GProgressSw.Elapsed;
            Double elapsedMillisecs = timeSpan.TotalMilliseconds;
            if (elapsedMillisecs < updatedelay)
            {
                return;
            }
            Console.OutputEncoding = Encoding.Unicode;
          
            char[] spinners = new char[4];
            spinners[0] = '-';
            spinners[1] = '\\';
            spinners[2] = '|';
            spinners[3] = '/';

            Globals.GCurrentSpinnerIndex++;

            if (Globals.GCurrentSpinnerIndex >= 4)
            {
                Globals.GCurrentSpinnerIndex = 0;
            }

            char currentSpinner = spinners[Globals.GCurrentSpinnerIndex];

            Double elapsedSeconds = timeSpan.TotalSeconds;
            Globals.GProgressSw.Restart();

            Double tmpVal = (Globals.GMax / 100) * percentage; 
            Globals.GPos = Convert.ToInt32(Math.Round(tmpVal));
           
            string p = "";
            for (int i = 0; i < Globals.GPos; i++)
            {
                p += '.';
            }
            p += currentSpinner;
            for (int i = Convert.ToInt32(Globals.GPos); i < Globals.GMax; i++)
            {
                p += ' ';
            }

            string strprogress = String.Format("[{0}] {1}", p, message);

            WriteExt(strprogress, -1, -1, foregroundColor, backgroundColor, true, true);

            Console.CursorVisible = wasCursorVisible;

        }
    }

}
