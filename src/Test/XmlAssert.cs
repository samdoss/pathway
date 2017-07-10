// --------------------------------------------------------------------------------------------
// <copyright file="XmlAssert.cs" from='2009' to='2009' company='SIL International'>
//      Copyright ( c ) 2009, SIL International. All Rights Reserved.
//
//      Distributable under the terms of either the Common Public License or the
//      GNU Lesser General Public License, as specified in the LICENSING.txt file.
// </copyright>
// <author>Greg Trihus</author>
// <email>greg_trihus@sil.org</email>
// Last reviewed:
//
// <remarks>
// ODT Test Support
// </remarks>
// --------------------------------------------------------------------------------------------

using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography.Xml;
using System.Text.RegularExpressions;
using System.Xml;
using NUnit.Framework;
using SIL.Tool;

namespace Test
{
    public static class XmlAssert
    {
	    public static bool TrimSpace;

        /// <summary>
        /// Compares the XML file at expected path tand output path to make sure they are the same in terms of what matters to XML.
        /// </summary>
        /// <param name="expectPath">expected output path</param>
        /// <param name="outputPath">output path</param>
        /// <param name="msg">message to display if mismatch</param>
        public static void AreEqual(string expectPath, string outputPath, string msg)
        {
	        if (TrimSpace)
	        {
		        Console.WriteLine("Temp Folder {0}", Path.GetTempPath());
		        var tempExpected = Path.Combine(Path.GetTempPath(),
			        Path.GetFileNameWithoutExtension(expectPath) + "Exp" + Path.GetExtension(expectPath));
				File.Copy(expectPath, tempExpected, true);
		        expectPath = tempExpected;
				var tempOutput = Path.Combine(Path.GetTempPath(),
					Path.GetFileNameWithoutExtension(outputPath) + "Out" + Path.GetExtension(outputPath));
				File.Copy(outputPath, tempOutput, true);
		        outputPath = tempOutput;
	        }
			Console.WriteLine("Comparing Expected {0}\n and Output {1}", expectPath, outputPath);
			XmlDocument outputDocument = Common.DeclareXMLDocument(false);
            outputDocument.Load(outputPath);
            XmlDocument expectDocument = Common.DeclareXMLDocument(false);
            expectDocument.Load(expectPath);
	        if (TrimSpace)
	        {
		        TrimSpaces(expectDocument);
				expectDocument.Save(expectPath);
				TrimSpaces(outputDocument);
				outputDocument.Save(outputPath);
	        }
            XmlDsigC14NTransform outputCanon = new XmlDsigC14NTransform();
            outputCanon.Resolver = null;
            outputCanon.LoadInput(outputDocument);
            XmlDsigC14NTransform expectCanon = new XmlDsigC14NTransform();
            expectCanon.Resolver = null;
            expectCanon.LoadInput(expectDocument);
            Stream outputStream = (Stream)outputCanon.GetOutput(typeof(Stream));
            Stream expectStream = (Stream)expectCanon.GetOutput(typeof(Stream));
            FileAssert.AreEqual(expectStream, outputStream, msg);
			outputStream.Close();
			expectStream.Close();
	        if (!TrimSpace) return;
	        File.Delete(outputPath);
	        File.Delete(expectPath);
        }

	    private static void TrimSpaces(XmlDocument xmlDocument)
	    {
		    var nodes = xmlDocument.SelectNodes("//text()");
		    foreach (XmlText xmlText in nodes)
		    {
			    xmlText.InnerText = Regex.Replace(xmlText.InnerText, @"\s+", " ").Trim(new []{' ', '\n', '\t'});
		    }
	    }

	    public static void Ignore(string path, string xpath, Dictionary<string, string> nameSpaces)
        {
            XmlDocument xmlDocument = Common.DeclareXMLDocument(false);
            XmlNamespaceManager ns = new XmlNamespaceManager(xmlDocument.NameTable);
            if (nameSpaces != null)
                foreach (string key in nameSpaces.Keys)
                    ns.AddNamespace(key, nameSpaces[key]);
            xmlDocument.Load(path);
            XmlNodeList xmlNodes = xmlDocument.SelectNodes(xpath, ns);
            if (xmlNodes != null)
            {
                foreach (XmlNode xmlNode in xmlNodes)
                    xmlNode.InnerText = "Ignore";
                if (xmlNodes.Count > 0)
                    xmlDocument.Save(path);
            }
            xmlDocument.RemoveAll();
        }
    }
}
