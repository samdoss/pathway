﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:2.0.50727.4952
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace epubConvert.Properties {
    using System;
    
    
    /// <summary>
    ///   A strongly-typed resource class, for looking up localized strings, etc.
    /// </summary>
    // This class was auto-generated by the StronglyTypedResourceBuilder
    // class via a tool like ResGen or Visual Studio.
    // To add or remove a member, edit your .ResX file then rerun ResGen
    // with the /str option, or rebuild your VS project.
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("System.Resources.Tools.StronglyTypedResourceBuilder", "2.0.0.0")]
    [global::System.Diagnostics.DebuggerNonUserCodeAttribute()]
    [global::System.Runtime.CompilerServices.CompilerGeneratedAttribute()]
    internal class Resources {
        
        private static global::System.Resources.ResourceManager resourceMan;
        
        private static global::System.Globalization.CultureInfo resourceCulture;
        
        [global::System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Performance", "CA1811:AvoidUncalledPrivateCode")]
        internal Resources() {
        }
        
        /// <summary>
        ///   Returns the cached ResourceManager instance used by this class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Resources.ResourceManager ResourceManager {
            get {
                if (object.ReferenceEquals(resourceMan, null)) {
                    global::System.Resources.ResourceManager temp = new global::System.Resources.ResourceManager("epubConvert.Properties.Resources", typeof(Resources).Assembly);
                    resourceMan = temp;
                }
                return resourceMan;
            }
        }
        
        /// <summary>
        ///   Overrides the current thread's CurrentUICulture property for all
        ///   resource lookups using this strongly typed resource class.
        /// </summary>
        [global::System.ComponentModel.EditorBrowsableAttribute(global::System.ComponentModel.EditorBrowsableState.Advanced)]
        internal static global::System.Globalization.CultureInfo Culture {
            get {
                return resourceCulture;
            }
            set {
                resourceCulture = value;
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Chapter .
        /// </summary>
        internal static string Chapter {
            get {
                return ResourceManager.GetString("Chapter", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to &amp;Use this font instead:.
        /// </summary>
        internal static string ConvertToSILFont {
            get {
                return ResourceManager.GetString("ConvertToSILFont", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to &amp;Embed the font. I have the proper rights to redistribute it..
        /// </summary>
        internal static string EmbedFont {
            get {
                return ResourceManager.GetString("EmbedFont", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to What do you want to do?.
        /// </summary>
        internal static string EmbedFontOptions {
            get {
                return ResourceManager.GetString("EmbedFontOptions", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to &apos;{0}&apos; is specified as the default font for language(s): &apos;{1}&apos;. You will need the proper rights in order to embed this font in your distributed document..
        /// </summary>
        internal static string EmbedFontsWarning {
            get {
                return ResourceManager.GetString("EmbedFontsWarning", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Font Copyright Warning.
        /// </summary>
        internal static string FontWarningDlgTitle {
            get {
                return ResourceManager.GetString("FontWarningDlgTitle", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Missing Font: &apos;{0}&apos;.
        /// </summary>
        internal static string MissingFontTitle {
            get {
                return ResourceManager.GetString("MissingFontTitle", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to &apos;{0}&apos; is specified as the default font for language(s): &apos;{1}&apos;, but cannot be found on this system. Select another font to use instead, or click Cancel to stop the conversion to .epub..
        /// </summary>
        internal static string MissingFontWarning {
            get {
                return ResourceManager.GetString("MissingFontWarning", resourceCulture);
            }
        }
        
        /// <summary>
        ///   Looks up a localized string similar to Do this for the next {0} item(s)..
        /// </summary>
        internal static string RepeatAction {
            get {
                return ResourceManager.GetString("RepeatAction", resourceCulture);
            }
        }
    }
}
