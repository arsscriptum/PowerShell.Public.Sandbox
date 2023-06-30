
using System;
using System.Text;
using System.Management.Automation;
using System.Diagnostics;

namespace NativeProgressBar.Utility
{
    /// <summary>
    /// A base cmdlet object that provides common functionality.
    /// </summary>
    static class Globals
    {
        static bool _showCursor = false;
        public static bool GShowCursor
        {
            set { _showCursor = value; }
            get { return _showCursor; }
        }

        static DateTime _startTime;
        public static DateTime GStartTime
        {
            set { _startTime = value; }
            get { return _startTime; }
        }
        static int _currentSpinnerIndex;
        public static int GCurrentSpinnerIndex
        {
            set { _currentSpinnerIndex = value; }
            get { return _currentSpinnerIndex; }
        }
        static double _max;
        public static double GMax
        {
            set { _max = value; }
            get { return _max; }
        }

        static double _half;
        public static double GHalf
        {
            set { _half = value; }
            get { return _half; }
        }
   
        static double _pos;
        public static double GPos
        {
            set { _pos = value; }
            get { return _pos; }
        }

        static Encoding _encoding;
        public static Encoding GEncoding
        {
            set { _encoding = value; }
            get { return _encoding; }
        }

        // global int using get/set
        static double _gsize;
        public static double GSize
        {
            set { _gsize = value; }
            get { return _gsize; }
        }
        public static Stopwatch GProgressSw
        {
            set { _stopwatch = value; }
            get { return _stopwatch; }
        }
        static Stopwatch _stopwatch = new Stopwatch();
    }

}
