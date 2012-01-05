var jug = undefined
$(document).live('pageshow', function(event){
      enableChat()
      $("#mesg").empty();
});

$(document).live('pagehide', function(event){
      disableChat()
      
});

function enableChat() { 
  if (!(typeof jug !== undefined && jug)) {
    jug = new Juggernaut();
    jug.subscribe("user", function(data){
      var ul = '<ul data-role="listview" data-inset="true" class="ui-listview ui-listview-inset ui-corner-all ui-shadow"><li class="ui-li ui-li-static ui-body-c ui-corner-top ui-corner-bottom">'+data+'</li></ul>'
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
        data: "msg_body="+this.msg_body.value+"&sender="+this.sender.value,
      });
    }
    return false;
  });
  
}  

function disableChat()
{
    if (typeof jug !== undefined && jug)
    {
      jug.unsubscribe("user")
      jug.unbind()
    }
}



