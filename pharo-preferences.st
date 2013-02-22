| color red green yellow white |
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
"============================================================================="

Author fullName: 'Camillo Bruni'.

"============================================================================="

yellow value: 'Updating image'.

UpdateStreamer new 
    beSilent; 
    elementaryReadServerUpdates.

"============================================================================="

yellow value: 'Loading custom preferences'.

Debugger alwaysOpenFullDebugger: true.

white value: '- enabling TrueType fonts'.
FreeTypeSystemSettings loadFt2Library: true.

white value: '- set default fonts'.
StandardFonts defaultFont: (LogicalFont familyName: 'Consolas' pointSize: 10).
GraphicFontSettings resetAllFontToDefault.

white value: '- preparing tools'.
PolymorphSystemSettings 
	desktopColor: Color gray;
	showDesktopLogo: false.

"UITheme currentSettings fastDragging: true."

TextEditorDialogWindow autoAccept: true.

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