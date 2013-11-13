"Put this in ~/Library/Preferences/pharo/ "

Smalltalk isHeadless ifFalse: [
StartupLoader default executeAtomicItems: {
StartupAction name: 'Image Setup' code: [
| color red green yellow white isIssueImage |

"============================================================================="
"some helper blocks for error printing"
color := [:colorCode :text|
    FileStream stderr 
        "set the color"
        nextPut: Character escape; nextPut: $[; print: colorCode; nextPut: $m;
        nextPutAll: text; crlf;
        "reset the color"
        nextPut: Character escape; nextPutAll: '[0m'.
].

red    := [:text| color value: 31 value: text ].
green  := [:text| color value: 32 value: text ].
yellow := [:text| color value: 33 value: text ].
white  := [:text| FileStream stderr nextPutAll: text; crlf ].

"Check whether we use an image for issue reporting"
isIssueImage := Smalltalk imageFile basename first isDigit.

"============================================================================="

Author fullName: 'Camillo Bruni'.

"============================================================================="

[
	yellow value: 'Loading custom preferences'.

	Smalltalk at: #Debugger ifPresent: [ :debugger|
		debugger
			alwaysOpenFullDebugger: true;
			filterCommonMessageSends: false ].
		
	SpecDebugger
		alwaysOpenFullDebugger: true.

	white value: '- set default fonts'.
	StandardFonts defaultFont: (LogicalFont familyName: 'Consolas' pointSize: 10).
	GraphicFontSettings resetAllFontToDefault.

	white value: '- preparing tools'.
	PolymorphSystemSettings 
		desktopColor: Color gray;
		showDesktopLogo: false.

	"UITheme currentSettings fastDragging: true."

	TextEditorDialogWindow autoAccept: true.

	SHPreferences setStyleTableNamed: 'Tango'.
		
	NECPreferences
		popupShowAutomatic: false;
		popupShowWithShortcut: Character tab asKeyCombination.
		
	NNavNavigation
		useArrowsShortcuts: true.

	isIssueImage ifFalse: [
			
	].
			
	"Do not load anything special in an issue image due to possible side effects"
	(isIssueImage and: [ Smalltalk isInteractive ])
		ifTrue: [ | slice |
			"open a slice inspector"
			slice := (Smalltalk imageFile basename copyUpTo: $-).
			(MCFileRepositoryInspector repository: (MCHttpRepository inboxRepository) workingCopy: nil)
				versionSearchAccept: slice;
				show.
		].
] fork.

white value: '- enabling TrueType fonts'.
FreeTypeSystemSettings 
	loadFt2Library: false;
	loadFt2Library: true.
"============================================================================="

(Workspace new contents: '';
    openLabel: '')
	width: 1200; height: 230;
	setToAdhereToEdge: #bottomLeft;
	makeUnclosable.

MCWorkingCopyBrowser new show window
	width: 700; height: 230;
	setToAdhereToEdge: #topLeft;
	makeUnclosable.
	

] 
runOnce: true}].
