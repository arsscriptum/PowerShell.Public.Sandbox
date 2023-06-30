
using System;
using System.Management.Automation;

namespace NativeProgressBar.Utility
{
    /// <summary>
    /// A base cmdlet object that provides common functionality.
    /// </summary>
    internal class CommonParmeters
    {
        [Parameter(Mandatory = false)]
        public bool ShowCursor
        {
            get { return _showCursor; }
            set { _showCursor = value; }
        }
        private bool _showCursor = false;
    }
}
