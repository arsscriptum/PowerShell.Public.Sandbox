
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
   
    [Cmdlet(VerbsLifecycle.Register, "NativeProgressBar")]
    public class RegisterNativeProgressBar : BaseNativeProgressBarCmdlet
    {

        [Parameter(Position = 0, Mandatory = true)]
        public double Size
        {
            get { return _size; }
            set { _size = value; }
        }
        private double _size;

        // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
        protected override void BeginProcessing()
        {
            Globals.GEncoding = Console.OutputEncoding;
            Console.OutputEncoding = Encoding.Unicode;

            Globals.GProgressSw.Reset();
            Globals.GProgressSw.Start();

            Globals.GStartTime = DateTime.Now;
            Globals.GMax = Size;
            Globals.GSize = Size;
            Globals.GHalf = Size / 2;
            Globals.GPos = 0;
            Globals.GCurrentSpinnerIndex = 0;

            Globals.GShowCursor = BaseCommonParmeters.ShowCursor;

            string msg = String.Format("Begin Register-NativeProgressBar. GShowCursor {0}", Globals.GShowCursor);
            WriteVerbose(msg);
        }

        protected override void ProcessRecord()
        {
            string msg = String.Format("Process Register-NativeProgressBar. GShowCursor {0}", Globals.GShowCursor);
            WriteVerbose(msg);
        }
    }


}
