var jug = undefined
$(document).live('pageshow', function(event){
      //enableChat($.cookie('chgo_ch_key'))
      $("#mesg").empty();
});

$(document).live('pagehide', function(event){
      disableChat($.cookie('chgo_ch_key'))
      
});

function enableChat(channel) { 
  if (!(typeof jug !== undefined && jug)) {
    jug = new Juggernaut();
    jug.subscribe(channel, function(data){
      var ul = '<ul data-role="listview" data-inset="true" class="ui-listview ui-listview-inset ui-corner-all ui-shadow"><li class="ui-li ui-li-static ui-body-c ui-corner-top ui-corner-bottom">'+data.sender+": "+data.message+'</li></ul>'
      $("#mesg").append(ul)
      $("#chat_window")[0].reset();
      setTimeout(function(){window.scroll(0,$(document).height()+200)},300);
    }); 
   } 
   
  $("#chat_window").unbind("submit");
  $("#chat_window").submit(function(event) {
    event.preventDefault();
    $("#header-main").css("top", "0px")
    var msg = $.trim(this.msg_body.value)
    if (msg != '')
    {
      $.ajax({
        url: '/chat/send',
        type: 'POST',
        data: "channel="+channel+"&sender="+$.cookie("chgo_user_id")+"&receiver="+$.cookie('chgo_re_id')+"&message="+this.msg_body.value
      });
    }
    return false;
  });
  
}  

function disableChat(channel)
{
    if (typeof jug !== undefined && jug)
    {
      jug.unsubscribe(channel)
      jug.unbind()
    }
}


