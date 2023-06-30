
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
   
    [Cmdlet(VerbsLifecycle.Unregister, "NativeProgressBar")]
    public class UnregisterNativeProgressBar : BaseNativeProgressBarCmdlet
    { 
    
        // This method gets called once for each cmdlet in the pipeline when the pipeline starts executing
        protected override void BeginProcessing()
        {
            Console.OutputEncoding = Globals.GEncoding;
            Globals.GProgressSw.Reset();
            Globals.GProgressSw.Stop();
            Globals.GShowCursor = BaseCommonParmeters.ShowCursor;

            string msg = String.Format("Begin Unregister-NativeProgressBar. GShowCursor {0}", Globals.GShowCursor);
            WriteVerbose(msg);
        }

        protected override void ProcessRecord()
        {
            string msg = String.Format("Process Unregister-NativeProgressBar. GShowCursor {0}", Globals.GShowCursor);
            WriteVerbose(msg);
        }

    }

}
