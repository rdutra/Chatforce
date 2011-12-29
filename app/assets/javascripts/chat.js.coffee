# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready(() ->
  jug = new Juggernaut();
  $("#mesg").append($("<li/>").append("Subscribing to channel1_channel2"));
  jug.subscribe("/chats/channel1_channel2", (data) ->
    li = $("<li/>");
    li.text(data);
    $("#mesg").append(li);
    $("#chat_window")[0].reset();
  ); 
  
  $("#chat_window").submit(() -> 
    $.ajax({
      url: '/chat/send',
      type: 'POST',
      data: "msg_body="+this.msg_body.value+"&sender="+this.sender.value
      success: (data) ->
        
    });
    return false;
  )
);


