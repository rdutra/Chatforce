var jugger_comm = undefined;
var data_session = undefined;
var data_channel = undefined;
var channel_selected = undefined;
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
      $("#buddy-status").change(function(){
          $.ajax({
            url: '/chat/set_status',
            type: 'POST',
            data: "channel="+data_session.org_channel+"&sender="+data_session.buddy_id+"&message="+$(this).val(),
            success: function(data){
              //setStatus(data_session.buddy_id, $(this).val())
            }
          });  
      })
    }
  });  
  
  

}

function channel_subscribe(channel)
{
    if (!(typeof jugger_comm !== undefined && jugger_comm))
    {
        jugger_comm = new Juggernaut(data_session);
        jugger_comm.meta = {buddy_id: data_session.buddy_id};
    }
    
    jugger_comm.on("disconnect", function(){ 
      
    });
    jugger_comm.on("connect", function(){ 
      
    });
    
    jugger_comm.subscribe(channel, function(data)
    {
      if((data.message["code"] == "invite") || (data.message["code"] == "accept")) {
        enableOrgChat(data);
        
      } else if(data.message["code"] == "write") {
        enableChat(data, false);
        
      } else if(data.message["code"] == "status") {
        setStatus(data.sender, data.message["message"]);
        
      } else if (data.message["code"] == "prediction") {
        setChatPrediction(data);
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
            data: "channel="+data_session.org_channel+"&sender="+data_session.buddy_id+"&receiver="+$(this).attr("id")+"&channel_conn="+data.message["message"],
            success: function(conn_channel_data){
              channel_selected = conn_channel_data;
              $("#"+data.sender).attr( "name", channel_selected );
              $("#"+data.sender).attr( "indirect", true );
            }
          });
          jQuery('#header').attr('name',$(this).attr("id"));
          $.ajax({
              url: "/chat/get_buddy_info",
              type: 'POST',
              data: { buddy: $(this).attr("id")},
              success: function(buddy){
                jQuery('#status_circle').removeClass('Online Offline Busy Away');
                jQuery('#status_circle').addClass(buddy.status);
                jQuery('#name').text(buddy.name);
                jQuery('.picContainer > img')[0].src = buddy.pic;
              }
          });
        });
        runEffect(data.sender);
        display_message_notification();
        go_buddies_notification();
        runEffect('inside-notification');
      }
      
      if(data.message["code"] == "accept")
      {
        data_channel = data.message["message"];
        init_chat(data.message["channel_conn"], false, undefined);
        channel_subscribe(data.message["message"]);
        channel_selected = data.message.channel_conn;
        //$("#"+data.sender).attr("name", data.message.channel_conn);
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

        var is_indirect = $("#" + data.receiver).attr("indirect");
        if(is_indirect == "true")
        {
          init_chat(data.message["channel_conn"], true, data.receiver);
        }
        else
        {
          channel_subscribe(data.message["channel_conn"]);
          init_chat(data.message["channel_conn"], true, undefined);
        }
      }
  }
}

function enableChat(data, buffer)
{

  if(data.channel == channel_selected)
  {
    var who =  (data.message['sender'] == data_session.buddy_id)? 'left': 'right';
    var ul = '<div class="conversationContainer">';
    ul += '  <div class="triangle ' + who + '"></div>';
    ul += '  <div class="conversation">';
    ul += '    <div class="sender">';
    ul +=        data.message["senderName"];
    ul += '    </div>';
    ul += '    <div class="timestamp">';
    ul +=        data.message["date"];
    ul += '     </div>';
    ul += '     <div class="message">';
    ul +=         data.message["message"];
    ul += '     </div>';
    ul += '   </div>';
    ul += '</div>';
    $("#mesg").append(ul);
    $(ul).css('float',who);
    if(data.message["sender"] == data_session.buddy_id){
      $("#msg_body").val("");
    }

  }
  else{
    
    //Lunes 13 feb seguir aca con el envio de un ya conectado previamente
    if(data.message["message"] != '')
    {
      $.ajax({
        url: "/chat/buffer",
        type: 'POST',
        data: "channel="+data.channel+"&message="+data.message.message+"&sender="+data.message["sender"],
        success: function(data_buffer){}
      });
    }
  }
  
  

  setTimeout(function(){window.scroll(0,$(document).height()+200)},300);
}

function inviteChat()
{
  $(".buddy_content" ).unbind('click');
  $(".buddy_content" ).click(function(event){
      $(this).removeAttr('style');
      var objLi = $(this);
      jQuery('#header').attr('name',$(this).attr("id"));
      $.ajax({
          url: "/chat/get_buddy_info",
          type: 'POST',
          data: { buddy: $(this).attr("id")},
          success: function(buddy){
            jQuery('#status_circle').removeClass('Online Offline Busy Away');
            jQuery('#status_circle').addClass(buddy.status);
            jQuery('#name').text(buddy.name);
            jQuery('.picContainer > img')[0].src = buddy.pic;
          }
      });

      if(objLi.attr('name') == undefined){
        $.ajax({
          url: "/chat/invite_return_channel",
          type: 'POST',
          data: "channel="+data_session.org_channel+"&sender="+data_session.buddy_id+"&receiver="+$(this).attr("id"),
          success: function(data_ch){
            channel_selected = data_ch;
            objLi.attr('name', data_ch);
          }
        });
      } else {
        channel_selected = objLi.attr('name');
        
        $.ajax({
          url: "/chat/get_buffer",
          type: 'POST',
          data: "channel="+channel_selected,
          success: function(data_buf){
            for (i=data_buf.length-1;i>=0;i--)
            {
                enableChat(data_buf[i], true);
            }  
          }
        });
      }
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
      //$('#inside-notification').animate({"right": "-134px"}, 5000);
    }
  }, 550 );
};


function init_chat(channel, buffer, id_sender)
{
  $("#chat_window").unbind("submit");
  $("#chat_window").submit(function(event) {
    event.preventDefault();
    $("#header-main").css("top", "0px")
    var message = $.trim(this.msg_body.value)
    real_sender = data_session.buddy_id;
    
    if(id_sender != undefined) real_sender = id_sender; 
    
    if (message != '')
    {
      /*$.ajax({
        url: "/chat/write",
        type: 'POST',
        data: "channel="+channel_selected+"&message="+message+"&sender="+real_sender,
        success: function(data){}
      });*/
      $.ajax({
        url: "/chat/buffer",
        type: 'POST',
        data: "channel="+channel_selected+"&message="+message+"&sender="+real_sender,
        success: function(data_buffer){
          jQuery('#msg_body').keyup();
        }
      });
      
    }
    return false;
  });
  
  var msgBody = jQuery('#msg_body');
  msgBody.unbind('keyup');
  msgBody.keyup(function(){
    var element = jQuery(this);
    if (element.val() != '' && element.attr('prediction') != "writing") {
      var message = 'writing';
      $.ajax({
        url: "/chat/prediction",
        type: 'POST',
        data: {
          channel: channel_selected,
          message: message,
          sender: data_session.buddy_id
        }
      });
      element.attr('prediction', 'writing');
    } else if ( element.val() == '' && element.attr('prediction') != "discard"){
      var message = 'discard';
      $.ajax({
        url: "/chat/prediction",
        type: 'POST',
        data: {
          channel: channel_selected,
          message: message,
          sender: data_session.buddy_id
        }
      });
      element.attr('prediction', 'discard');
    }
  });
  
  if(buffer && id_sender == undefined)
  {
      $.ajax({
        url: "/chat/get_buffer",
        type: 'POST',
        data: "channel="+channel,
        success: function(data){
          for (i=data.length-1;i>=0;i--)
          {
              enableChat(data[i], true)
          }          
        }
      });
  }
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

function setStatus(sender, message)
{
    $("#"+sender+" img").attr("src", "/images/"+message+".png")
    if (sender == jQuery('#header').attr('name')){
      jQuery('#status_circle').removeClass('Online Offline Busy Away');
      jQuery('#status_circle').addClass(message);
    }
}

function display_message_notification(){
  
  rightPosition = $('#inside-notification').css('right');
  rightPosition = parseFloat(rightPosition);
  
  if(rightPosition < 0) $('#inside-notification').animate({"right": "0px"}, 200);
}

function go_buddies_notification()
{

  $("#inside-notification").unbind("click");
  $("#inside-notification").click(function(event) {
    hide_notification();
    $.mobile.changePage("/buddies");
  });
}

function hide_notification(){
  // aca borrar el buffer
   $("#mesg").html("");
   $('#inside-notification').css("right", "-134px");
}

function setChatPrediction ( data ){
  if(data.channel == channel_selected && data.sender != data_session.buddy_id){
    if (data.message.prediction == 'writing'){
      jQuery('#status_mssg').text('Is typing a message..');
    } else {
      jQuery('#status_mssg').text('');
    }
  }
}
