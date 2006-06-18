{
     File:       NSL.p
 
     Contains:   Interface to API for using the NSL User Interface
 
     Version:    Technology: Mac OS X
                 Release:    Universal Interfaces 3.4.2
 
     Copyright:  � 1985-2002 by Apple Computer, Inc., all rights reserved
 
     Bugs?:      For bug reports, consult the following page on
                 the World Wide Web:
 
                     http://www.freepascal.org/bugs.html
 
}


{
    Modified for use with Free Pascal
    Version 200
    Please report any bugs to <gpc@microbizz.nl>
}

{$mode macpas}
{$packenum 1}
{$macro on}
{$inline on}
{$CALLING MWPASCAL}

unit NSL;
interface
{$setc UNIVERSAL_INTERFACES_VERSION := $0342}
{$setc GAP_INTERFACES_VERSION := $0200}

{$ifc not defined USE_CFSTR_CONSTANT_MACROS}
    {$setc USE_CFSTR_CONSTANT_MACROS := TRUE}
{$endc}

{$ifc defined CPUPOWERPC and defined CPUI386}
	{$error Conflicting initial definitions for CPUPOWERPC and CPUI386}
{$endc}
{$ifc defined FPC_BIG_ENDIAN and defined FPC_LITTLE_ENDIAN}
	{$error Conflicting initial definitions for FPC_BIG_ENDIAN and FPC_LITTLE_ENDIAN}
{$endc}

{$ifc not defined __ppc__ and defined CPUPOWERPC}
	{$setc __ppc__ := 1}
{$elsec}
	{$setc __ppc__ := 0}
{$endc}
{$ifc not defined __i386__ and defined CPUI386}
	{$setc __i386__ := 1}
{$elsec}
	{$setc __i386__ := 0}
{$endc}

{$ifc defined __ppc__ and __ppc__ and defined __i386__ and __i386__}
	{$error Conflicting definitions for __ppc__ and __i386__}
{$endc}

{$ifc defined __ppc__ and __ppc__}
	{$setc TARGET_CPU_PPC := TRUE}
	{$setc TARGET_CPU_X86 := FALSE}
{$elifc defined __i386__ and __i386__}
	{$setc TARGET_CPU_PPC := FALSE}
	{$setc TARGET_CPU_X86 := TRUE}
{$elsec}
	{$error Neither __ppc__ nor __i386__ is defined.}
{$endc}
{$setc TARGET_CPU_PPC_64 := FALSE}

{$ifc defined FPC_BIG_ENDIAN}
	{$setc TARGET_RT_BIG_ENDIAN := TRUE}
	{$setc TARGET_RT_LITTLE_ENDIAN := FALSE}
{$elifc defined FPC_LITTLE_ENDIAN}
	{$setc TARGET_RT_BIG_ENDIAN := FALSE}
	{$setc TARGET_RT_LITTLE_ENDIAN := TRUE}
{$elsec}
	{$error Neither FPC_BIG_ENDIAN nor FPC_LITTLE_ENDIAN are defined.}
{$endc}
{$setc ACCESSOR_CALLS_ARE_FUNCTIONS := TRUE}
{$setc CALL_NOT_IN_CARBON := FALSE}
{$setc OLDROUTINENAMES := FALSE}
{$setc OPAQUE_TOOLBOX_STRUCTS := TRUE}
{$setc OPAQUE_UPP_TYPES := TRUE}
{$setc OTCARBONAPPLICATION := TRUE}
{$setc OTKERNEL := FALSE}
{$setc PM_USE_SESSION_APIS := TRUE}
{$setc TARGET_API_MAC_CARBON := TRUE}
{$setc TARGET_API_MAC_OS8 := FALSE}
{$setc TARGET_API_MAC_OSX := TRUE}
{$setc TARGET_CARBON := TRUE}
{$setc TARGET_CPU_68K := FALSE}
{$setc TARGET_CPU_MIPS := FALSE}
{$setc TARGET_CPU_SPARC := FALSE}
{$setc TARGET_OS_MAC := TRUE}
{$setc TARGET_OS_UNIX := FALSE}
{$setc TARGET_OS_WIN32 := FALSE}
{$setc TARGET_RT_MAC_68881 := FALSE}
{$setc TARGET_RT_MAC_CFM := FALSE}
{$setc TARGET_RT_MAC_MACHO := TRUE}
{$setc TYPED_FUNCTION_POINTERS := TRUE}
{$setc TYPE_BOOL := FALSE}
{$setc TYPE_EXTENDED := FALSE}
{$setc TYPE_LONGLONG := TRUE}
uses MacTypes,Events,NSLCore;

{$ALIGN MAC68K}


type
	NSLDialogOptionFlags 		= UInt32;
const
	kNSLDefaultNSLDlogOptions	= $00000000;					{  use defaults for all the options  }
	kNSLNoURLTEField			= $00000001;					{  don't show url text field for manual entry  }
	kNSLAddServiceTypes			= $00000002;					{  add the service type if a user enters an incomplete URL  }
	kNSLClientHandlesRecents	= $00000004;					{  Stops NSLStandardGetURL from adding the selection to the recent items folder  }


type
	NSLDialogOptionsPtr = ^NSLDialogOptions;
	NSLDialogOptions = record
		version:				UInt16;
		dialogOptionFlags:		NSLDialogOptionFlags;					{  option flags for affecting the dialog's behavior  }
		windowTitle:			Str255;
		actionButtonLabel:		Str255;									{  label of the default button (or null string for default)  }
		cancelButtonLabel:		Str255;									{  label of the cancel button (or null string for default)  }
		message:				Str255;									{  custom message prompt (or null string for default)  }
	end;

{$ifc TYPED_FUNCTION_POINTERS}
	NSLURLFilterProcPtr = function(url: CStringPtr; var displayString: Str255): boolean;
{$elsec}
	NSLURLFilterProcPtr = ProcPtr;
{$endc}

	{  you can provide for calls to NSLStandardGetURL }
{$ifc TYPED_FUNCTION_POINTERS}
	NSLEventProcPtr = procedure(var newEvent: EventRecord; userContext: UnivPtr);
{$elsec}
	NSLEventProcPtr = ProcPtr;
{$endc}

{$ifc OPAQUE_UPP_TYPES}
	NSLURLFilterUPP = ^SInt32; { an opaque UPP }
{$elsec}
	NSLURLFilterUPP = UniversalProcPtr;
{$endc}	
{$ifc OPAQUE_UPP_TYPES}
	NSLEventUPP = ^SInt32; { an opaque UPP }
{$elsec}
	NSLEventUPP = UniversalProcPtr;
{$endc}	

const
	uppNSLURLFilterProcInfo = $000003D0;
	uppNSLEventProcInfo = $000003C0;
	{
	 *  NewNSLURLFilterUPP()
	 *  
	 *  Availability:
	 *    Non-Carbon CFM:   available as macro/inline
	 *    CarbonLib:        in CarbonLib 1.0 and later
	 *    Mac OS X:         in version 10.0 and later
	 	}
function NewNSLURLFilterUPP(userRoutine: NSLURLFilterProcPtr): NSLURLFilterUPP; external name '_NewNSLURLFilterUPP'; { old name was NewNSLURLFilterProc }
{
 *  NewNSLEventUPP()
 *  
 *  Availability:
 *    Non-Carbon CFM:   available as macro/inline
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
function NewNSLEventUPP(userRoutine: NSLEventProcPtr): NSLEventUPP; external name '_NewNSLEventUPP'; { old name was NewNSLEventProc }
{
 *  DisposeNSLURLFilterUPP()
 *  
 *  Availability:
 *    Non-Carbon CFM:   available as macro/inline
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
procedure DisposeNSLURLFilterUPP(userUPP: NSLURLFilterUPP); external name '_DisposeNSLURLFilterUPP';
{
 *  DisposeNSLEventUPP()
 *  
 *  Availability:
 *    Non-Carbon CFM:   available as macro/inline
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
procedure DisposeNSLEventUPP(userUPP: NSLEventUPP); external name '_DisposeNSLEventUPP';
{
 *  InvokeNSLURLFilterUPP()
 *  
 *  Availability:
 *    Non-Carbon CFM:   available as macro/inline
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
function InvokeNSLURLFilterUPP(url: CStringPtr; var displayString: Str255; userRoutine: NSLURLFilterUPP): boolean; external name '_InvokeNSLURLFilterUPP'; { old name was CallNSLURLFilterProc }
{
 *  InvokeNSLEventUPP()
 *  
 *  Availability:
 *    Non-Carbon CFM:   available as macro/inline
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
procedure InvokeNSLEventUPP(var newEvent: EventRecord; userContext: UnivPtr; userRoutine: NSLEventUPP); external name '_InvokeNSLEventUPP'; { old name was CallNSLEventProc }
{ <--- function returns OSStatus of the operation.  noErr will be returned if valid, kNSLUserCanceled will be returned if the user cancels }
{ ---> dialogOptions }
{ ---> eventProc }
{ ---> eventProcContextPtr }
{ ---> filterProc }
{ ---> serviceTypeList }
{ <--- userSelectedURL }
{ NSLDialogOptions* dialogOptions }
{
   dialogOptions is a user defined structure defining the look, feel and operation of NSLStandardGetURL dialog
   default behavior can be achieved by passing in a pointer to a structure that has been filled out by a previous
   call to NSLGetDefaultDialogOptions or by passing in NULL.
}
{ NSLEventUPP eventProc }
{
   the eventProc is a callback NSLURLFilterUPP that will
   get called with Events that the dialog doesn't handle.  If you pass in nil,
   you won't get update events while the NSLStandardGetURL dialog is open.
}
{ void* eventProcContextPtr }
{  you can provide a pointer to some contextual data that you want to have sent to your eventProc filter }
{ NSLURLFilterProcPtr filterProc }
{
   the filter param is a callback NSLURLFilterUPP that
   will get called (if not nil) for each url that is going to be displayed in
   the dialog's result list.  A result of false will not include the url for the
   user to select from.  You also have the option of handling the way the url looks
   in the dialog listing by copying the preferred name into the displayString
   parameter.  (If left alone, NSLStandardGetURL dialog will strip the service type
   portion off the url).
}
{ char* serviceTypeList }
{
   the serviceTypeList parameter is a null terminated string that will 
   directly affect the contents of the services popup in the dialog.
   The structure of this string is a set of tuples as follows:
   Name of ServiceType as to be represented in the popup followed by
   a comma delimted list of service descriptors (ie http,https) that will
   used in the search of that type.  Each comma delimited tuple is delimited
   by semi-colons.
}
{
   For example:
   If you want to search for services of type http (web), https (secure web),
   and ftp, you could pass in the string "Web Servers,http,https;FTP Servers,ftp".
   This would result in a popup list with two items ("Web Servers" and "FTP Servers")
   and searches performed on them will provide results of type http and https for the
   first, and ftp for the second.
}

{
   Results list Icons:
   NSLStandardGetURL provides icons in its listings for the following types:
   "http", "https", "ftp", "afp", "lpr", "LaserWriter", "AFPServer"
   any other types will get a generic icon.  However, you can provide icons
   if you wish by including an '#ics8' resource id at the end of your comma
   delimited list.  The dialog will then use that icon if found in its results
   list.  This icon will be used for all types in a tuple.
   For example:
   The param "Web Servers,http,https;Telnet Servers,telnet;NFS Servers,nfs,129"
   would result in lists of http and https services to be shown with their default
   icons, telnet servers would be shown with the default misc. icon and nfs
   servers would be shown with your icon at resource id 129.
}

{ char** url }
{
   pass in the address of a char* and it will point to the resulting url.  If the user
   cancels (the function returns false), the pointer will be set to nil.  If the function
   returns true (user selected a url), then you must call NSLFreeURL on the pointer when
   you are done with it.
}
{
   Call this to have the user select a url based service from a dialog.
   Function takes on input an optional filter proc, a serviceTypeList, and an address to a Ptr.
   Function sets the value of the Ptr to a newly created c-style null terminated string
   containing the user's choice of URL.
}

{
 *  NSLStandardGetURL()
 *  
 *  Availability:
 *    Non-Carbon CFM:   in NSLPPCLib 1.1 and later
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
function NSLStandardGetURL(dialogOptions: NSLDialogOptionsPtr; eventProc: NSLEventUPP; eventProcContextPtr: UnivPtr; filterProc: NSLURLFilterUPP; serviceTypeList: CStringPtr; var userSelectedURL: CStringPtr): OSStatus; external name '_NSLStandardGetURL';

{
 *  NSLGetDefaultDialogOptions()
 *  
 *  Availability:
 *    Non-Carbon CFM:   in NSLPPCLib 1.1 and later
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
function NSLGetDefaultDialogOptions(var dialogOptions: NSLDialogOptions): OSStatus; external name '_NSLGetDefaultDialogOptions';

{ <--- function returns null (useful for setting variable at same time as freeing it }
{ ---> url is memory created by a call to NSLStandardGetURL }
{
 *  NSLFreeURL()
 *  
 *  Availability:
 *    Non-Carbon CFM:   in NSLPPCLib 1.1 and later
 *    CarbonLib:        in CarbonLib 1.0 and later
 *    Mac OS X:         in version 10.0 and later
 }
function NSLFreeURL(url: CStringPtr): CStringPtr; external name '_NSLFreeURL';

{ <--- function returns kNSLErrNullPtrError, file mgr errors, or resource mgr errors }
{ ---> folderSelectorType is one of the well-known folders defined in Folders.h }
{ ---> url is any valid url }
{ ---> userFriendlyName is used for the file name and the display name (in the UI) }
{
 *  NSLSaveURLAliasToFolder()
 *  
 *  Availability:
 *    Non-Carbon CFM:   in NSLPPCLib 1.1 and later
 *    CarbonLib:        not available
 *    Mac OS X:         in version 10.0 and later
 }
function NSLSaveURLAliasToFolder(folderSelectorType: OSType; url: ConstCStringPtr; userFriendlyName: ConstCStringPtr): OSErr; external name '_NSLSaveURLAliasToFolder';


{$ALIGN MAC68K}


end.
