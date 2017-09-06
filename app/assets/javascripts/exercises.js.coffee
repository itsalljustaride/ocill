# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
function _embedVideo(targetId,wid,uiconf_id,flashvars,entry_id,cb){
    kWidget.embed({
        targetId: targetId,
        wid: wid,
        uiconf_id: uiconf_id,
        flashvars: flashvars || {},
        entry_id: entry_id,
        readyCallback: cb
    });
}
