
using System;
using System.Management.Automation;

namespace NativeProgressBar.Utility
{
    /// <summary>
    /// A base cmdlet object that provides common functionality.
    /// </summary>
    public class BaseNativeProgressBarCmdlet : PSCmdlet, IDynamicParameters
    {
        private CommonParmeters _commonParmeters = new CommonParmeters();
        object IDynamicParameters.GetDynamicParameters()
        {
            return this._commonParmeters;
        }

        private protected CommonParmeters BaseCommonParmeters
        {
            get { return _commonParmeters; }
            set { _commonParmeters = value; }
        }
       

        /// <summary>
        /// The name of this cmdlet activity for progress tracking.
        /// </summary>
        internal string ActivityName { get; set; }


        /// <summary>
        /// Default constructor.
        /// </summary>
        public BaseNativeProgressBarCmdlet()
        {
        }


        protected static void WriteExt(string s, int x = -1, int y = -1, ConsoleColor foregroudColor = ConsoleColor.White, ConsoleColor backgroundColor = ConsoleColor.Black, bool clearline = false, bool noNewLine = true)
        {
            try
            {
                ConsoleColor bg_color = Console.BackgroundColor;
                ConsoleColor fg_color = Console.ForegroundColor;
                int cursor_top = Console.CursorTop;
                int cursor_left = Console.CursorLeft;

                int new_cursor_x = cursor_left;
                if (x > 0)
                {
                    new_cursor_x = x;
                }

                int new_cursor_y = cursor_top;
                if (y > 0)
                {
                    new_cursor_y = y;
                }

                if (clearline)
                {
                    int len = Console.WindowWidth - 1;

                    var empty = new string(' ', len);

                    Console.SetCursorPosition(0, new_cursor_y);
                    Console.Write(empty);
                }

                Console.BackgroundColor = backgroundColor;
                Console.ForegroundColor = foregroudColor;

                Console.SetCursorPosition(new_cursor_x, new_cursor_y);
                Console.Write(s);
                Console.WriteLine();
                if (noNewLine)
                {
                    Console.SetCursorPosition(cursor_left, cursor_top);
                }

                Console.BackgroundColor = bg_color;
                Console.ForegroundColor = fg_color;
            }
            catch (ArgumentOutOfRangeException e)
            {
                Console.Clear();
                Console.WriteLine(e.Message);
            }
        }


    }
}
