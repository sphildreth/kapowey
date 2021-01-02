using Kapowey.Extensions;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Kapowey.Utility
{
    public static class FolderPathHelper
    {
        public static IEnumerable<string> FolderSpaceReplacements = new List<string> { ".", "~", "_", "=", "-" };

        public static int MaximumFolderNameLength = 1024;

        public static string Path(string pathTitle, bool createIfNotFound = false)
        {
            var rt = new StringBuilder(pathTitle);
            foreach (var stringReplacement in FolderSpaceReplacements)
            {
                if (!rt.Equals(stringReplacement))
                {
                    rt.Replace(stringReplacement, " ");
                }
            }
            var pt = rt.ToString().ToAlphanumericName(false, false).ToFolderNameFriendly().ToTitleCase(false);
            if (string.IsNullOrEmpty(pt))
            {
                throw new Exception($"PathTitle [{ pt }] is invalid.");
            }
            var maxFnLength = MaximumFolderNameLength - 7;
            if (pt.Length > maxFnLength)
            {
                pt = pt.Substring(0, maxFnLength);
            }
            var directoryInfo = new DirectoryInfo(pt);
            if (createIfNotFound && !directoryInfo.Exists)
            {
                directoryInfo.Create();
            }
            return directoryInfo.FullName;
        }
    }
}