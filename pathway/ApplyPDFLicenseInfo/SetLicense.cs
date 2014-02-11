﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading;

namespace ApplyPDFLicenseInfo
{
    public static class SetLicense
    {
        public static int ExitCode;
        public static string RedirectOutput;
        public static string LastError;
        private static Process myProcess = new Process();
        private static int _elapsedTime;
        private static bool _eventHandled;

        public static void RunCommand(string instPath, string name, string arg, bool wait)
        {
            _elapsedTime = 0;
            _eventHandled = false;

            try
            {
                // Start a process to print a file and raise an event when done.
                myProcess.StartInfo.FileName = name;
                myProcess.StartInfo.Arguments = arg;
                myProcess.StartInfo.CreateNoWindow = true;
                myProcess.EnableRaisingEvents = true;
                myProcess.StartInfo.CreateNoWindow = true;
                myProcess.StartInfo.UseShellExecute = string.IsNullOrEmpty(RedirectOutput);
                myProcess.StartInfo.WorkingDirectory = instPath;

                myProcess.Exited += new EventHandler(myProcess_Exited);
                myProcess.Start();

            }
            catch (Exception ex)
            {
                if (!string.IsNullOrEmpty(RedirectOutput))
                {
                    string result = string.Empty;
                    StreamWriter streamWriter = new StreamWriter(Path.Combine(instPath, RedirectOutput));
                    var errorArgs = string.Format("An error occurred trying to print \"{0}\":" + "\n" + ex.Message, arg);
                    result += errorArgs;
                    streamWriter.Write(result);
                    streamWriter.Close();
                    RedirectOutput = null;
                }
                return;
            }

            // Wait for Exited event, but not more than 30 seconds. 
            const int SLEEP_AMOUNT = 100;
            while (!_eventHandled)
            {
                _elapsedTime += SLEEP_AMOUNT;
                if (_elapsedTime > 30000)
                {
                    break;
                }
                Thread.Sleep(SLEEP_AMOUNT);
            }
            myProcess.Close();
        }

        // Handle Exited event and display process information. 
        private static void myProcess_Exited(object sender, System.EventArgs e)
        {

            _eventHandled = true;
        }

        /// <summary>
        /// Make sure the path contains the proper / for the operating system.
        /// </summary>
        /// <param name="path1"></param>
        /// <param name="path2"></param>
        /// <returns>normalized path</returns>
        public static string PathCombine(string path1, string path2)
        {
            path1 = DirectoryPathReplace(path1);
            path2 = DirectoryPathReplace(path2);
            return Path.Combine(path1, path2);
        }

        /// <summary>
        /// Make sure the path contains the proper / for the operating system.
        /// </summary>
        /// <param name="path">input path</param>
        /// <returns>normalized path</returns>
        public static string DirectoryPathReplace(string path)
        {
            if (string.IsNullOrEmpty(path)) return path;

            string returnPath = path.Replace('/', Path.DirectorySeparatorChar);
            returnPath = returnPath.Replace('\\', Path.DirectorySeparatorChar);
            return returnPath;
        }

        public static bool UnixVersionCheck()
        {
            bool isRecentVersion = false;
            try
            {
                string getOSName = GetOsName();
                string majorVersion = string.Empty;
                if (getOSName.IndexOf("Unix") >= 0)
                {
                    isRecentVersion = true;
                    majorVersion = getOSName.Substring(0, 11);
                }
                if (majorVersion == "Unix 3.2.0.")
                {
                    isRecentVersion = true;
                }
            }
            catch { }
            return isRecentVersion;
        }

        public static string GetOsName()
        {
            OperatingSystem osInfo = Environment.OSVersion;

            switch (osInfo.Platform)
            {
                case System.PlatformID.Win32NT:
                    switch (osInfo.Version.Major)
                    {
                        case 3:
                            return "Windows NT 3.51";
                            break;
                        case 4:
                            return "Windows NT 4.0";
                            break;
                        case 5:
                            if (osInfo.Version.Minor == 0)
                                return "Windows 2000";
                            else
                                return "Windows XP";
                            break;
                        case 6:
                            if (osInfo.Version.Minor == 1)
                                return "Windows7";
                            break;
                    }
                    break;

            }
            return osInfo.VersionString.ToString();
        }
    }
}
