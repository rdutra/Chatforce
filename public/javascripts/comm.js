var jugger_comm = undefined;
var data_session = undefined;
var timer = 0;
var invite = false;

function getData()
{
  $.ajax({
    url: '/chat/get_data',
    type: 'POST',
    data: "",
    success: function(data){
      data_session = data
      enableCommChat(data_session.org_channel)
      createChat()
    }
  });  

}

$(document).live('pageshow', function(event){
    getData()
});

$(document).live('pagehide', function(event){
  if (typeof data_session !== undefined && data_session) {
    disableCommChat(data_session.org_channel)
  }  
});

function enableCommChat(channel) {
  if (!(typeof jugger_comm !== undefined && jugger_comm)) {
    jugger_comm = new Juggernaut();
    jugger_comm.subscribe(channel, function(data){
      if(data.receiver == data_session.buddy_id)
      {
          runEffect(data.sender);
          data_session.chat_channel = data.message;
          invite = true;
      }
      
    }); 
   } 
}  

function disableCommChat(channel)
{
    if (typeof jugger_comm !== undefined && jugger_comm)
    {
      jugger_comm.unsubscribe(channel)
      jugger_comm.unbind()
    }
}

function runEffect(buddy_id) {
  var selectedEffect = "highlight"
  var options = {color: "#0DAE1D"};
  $( "#"+buddy_id ).effect( selectedEffect, options, 500, callback(buddy_id) );
};

function callback(buddy_id) {
  setTimeout(function() {
    timer++
    if(timer < 5)
    {
      runEffect(buddy_id)
    }
    else
    {
      timer = 0
      $("#"+buddy_id).css("background-color", "#0DAE1D")
      $("#"+buddy_id).css("background-image", "none");
      
    }
  }, 550 );
};

function createChat()
{
  $(".buddy_content" ).click(function(event){
    var url_chat = "/chat/create_channel"
    var channel_chat = data_session.org_channel
    if(invite)
    {
        url_chat = "/chat/connect_channel"
        channel_chat = data_session.chat_channel
    }
        
    $.ajax({
      url: url_chat,
      type: 'POST',
      data: "channel="+channel_chat+"&sender="+data_session.buddy_id+"&receiver="+$(this).attr("id"),
      success: function(data){
        jugger_comm.subscribe(data, function(data){}); 
        document.location = "/chat/single"
      }
    }); 
  });
}



