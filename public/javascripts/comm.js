var jugger_comm = undefined;
var data_session = undefined;
var data_channel = undefined
var timer = 0;
var invite = false;


$("#buddies").live('pageinit', function(event){
    init()
});


function init()
{
  $.ajax({
    url: '/chat/get_data',
    type: 'POST',
    data: "",
    success: function(data){
      data_session = data
      inviteChat()
      
      channel_subscribe(data_session.org_channel)
    }
  });  

}

function channel_subscribe(channel)
{
    if (!(typeof jugger_comm !== undefined && jugger_comm))
    {
        jugger_comm = new Juggernaut();
    }
    
    jugger_comm.subscribe(channel, function(data)
    {
      if((data.message["code"] == "invite") || (data.message["code"] == "accept"))
      {
          enableOrgChat(data)
      }
      
      if(data.message["code"] == "write")
      {
          enableChat(data)
      }
    });
}

function enableOrgChat(data)
{
  if(data.receiver == data_session.buddy_id)
  {
      if(data.message["code"] == "invite")
      {
        $( "#"+data.sender).unbind("click");
        $( "#"+data.sender).click(function(event){
          $(this).removeAttr('style');
          $.ajax({
            url: "/chat/accept",
            type: 'POST',
            data: "channel="+data_session.org_channel+"&sender="+data_session.buddy_id+"&receiver="+$(this).attr("id"),
            success: function(data){
              
                
            }
          });
        });
        runEffect(data.sender);
      }
      
      if(data.message["code"] == "accept")
      {
        data_channel = data.message["message"];
        init_chat(data_channel);
        channel_subscribe(data.message["message"]);
      }
  }
  
  if(data.sender == data_session.buddy_id)
  {
      if(data.message["code"] == "invite")
      {
          init_buffer(data.message["message"])
          channel_subscribe(data.message["message"]);
      }
      
      if(data.message["code"] == "accept")
      {
        data_channel = data.message["message"];
        init_chat(data_channel);
        channel_subscribe(data.message["message"]);
      }
  }
}

function enableChat(data)
{
  var ul = '<ul data-role="listview" data-inset="true" class="ui-listview ui-listview-inset ui-corner-all ui-shadow"><li class=" write_'+data.message["sender"]+' ui-li ui-li-static ui-body-c ui-corner-top ui-corner-bottom">'+data.message["message"]+'</li></ul>'
  $("#mesg").append(ul)
  var text = $("#mesg").children().last().first().text()
  $("#mesg").children().last().css("width", text.length*10)
  text = ""  
  if(data.message["sender"] == data_session.buddy_id)
  {
    $(".write_"+data.message["sender"]).css("background-color", "#BADE86")
    $(".write_"+data.message["sender"]).css("background-image", "none");
  }
  else
  {
    $(".write_"+data.message["sender"]).css("background-color", "#4488F6")
    $(".write_"+data.message["sender"]).css("background-image", "none");
  }
  
  
  $("#chat_window")[0].reset();
  setTimeout(function(){window.scroll(0,$(document).height()+200)},300);
}

function inviteChat()
{
  $(".buddy_content" ).click(function(event){
      $(this).removeAttr('style');
      $.ajax({
        url: "/chat/invite",
        type: 'POST',
        data: "channel="+data_session.org_channel+"&sender="+data_session.buddy_id+"&receiver="+$(this).attr("id"),
        success: function(data){}
      });
  });
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


function init_chat(channel)
{
  $("#chat_window").unbind("submit");
  $("#chat_window").submit(function(event) {
    event.preventDefault();
    $("#header-main").css("top", "0px")
    var message = $.trim(this.msg_body.value)
    if (message != '')
    {
      $.ajax({
        url: "/chat/write",
        type: 'POST',
        data: "channel="+channel+"&message="+message+"&sender="+data_session.buddy_id,
        success: function(data){}
      });
    }
    return false;
  });
}

function init_buffer(channel)
{
  $("#chat_window").unbind("submit");
  $("#chat_window").submit(function(event) {
    event.preventDefault();
    $("#header-main").css("top", "0px")
    var message = $.trim(this.msg_body.value)
    if (message != '')
    {
      $.ajax({
        url: "/chat/buffer",
        type: 'POST',
        data: "channel="+channel+"&message="+message+"&sender="+data_session.buddy_id,
        success: function(data){}
      });
    }
    return false;
  });
}
