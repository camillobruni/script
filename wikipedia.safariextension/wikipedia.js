function update() {
    /* pinpoint the navigation panel */
    $('#mw-panel')
        .css('position','fixed')
        .css('top','0px')
        .css('left','0px')
        .css('height','100%')
        .css('overflow','auto')
    
    /* pinpoint the contents */
    $('#toc')
        .css('position','fixed')
        .css('top','10px')
        .css('right','10px')
        .css('z-index', '2')
        .click(function(){$('#toc ul').show()});
    $('#toc ul').hide();
    
    /* center the infobox */
    $('.infobox')
        .css('float', 'none')
        .css('margin-left', 'auto')
        .css('margin-right', 'auto');
        
    /* center images */
    $('.tright').css('float','none');
    $('.thumbinner')
        .css('margin-left', 'auto')
        .css('margin-right', 'auto');
    
    /* center the body */
    $('#bodyContent')
        .css('font-size', settings.fontSize+'px') 
        .css('text-align', 'justify')
        .css('font-family', 'Georgia')
        .css('line-height', '1.5em')
        .css('left','50%')
        .css('width', settings.textWidth+'em')
        .css('marginLeft', '-'+(settings.textWidth/2)+'em');
}

// ===========================================================================
settings = {};

safari.self.addEventListener("message", 
    function settingsChanged(event) {
        if (event.name == 'setSettings') {
            settings = event.message;
            update();
        }
    }, false);
safari.self.tab.dispatchMessage("getSettings");

Hyphenator.run();

//$.getScript('http://hyphenator.googlecode.com/svn/tags/Version%203.2.0/Hyphenator.js?bm=true');
