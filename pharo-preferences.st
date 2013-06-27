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

	Debugger 
		alwaysOpenFullDebugger: true;
		filterCommonMessageSends: true.


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

	UITheme currentSettings
		preferGradientFill: false;
		preferRoundCorner: true;
		menuColor: Color white.
		
	NECPreferences
		popupShowAutomatic: false;
		popupShowWithShortcut: Character tab asKeyCombination.
		
	NNavNavigation
		useArrowsShortcuts: true.

	yellow value: 'loading eclipse icons'.
	isIssueImage ifFalse: [
		(SystemVersion current major >= 3) ifTrue: [
			Gofer new
				smalltalkhubUser: 'estebanlm' project: 'EclipsePack';
				package: 'EclipsePack';
				load.
			ThemeIcons current: EclipseUIThemeIcons new.
			World resetWorldMenu.
			NautilusUI resetIconCaches ]].
	(isIssueImage and: [ Smalltalk isInteractive ])
		ifTrue: [ | slice |
			"open a slice inspector"
			slice := (Smalltalk imageFile basename copyUpTo: $-).
			(MCFileRepositoryInspector repository: (MCHttpRepository inboxRepository) workingCopy: nil)
				versionSearchAccept: slice;
				show.
		]
] fork.

white value: '- enabling TrueType fonts'.
FreeTypeSystemSettings loadFt2Library: true.
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
