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
      console.info("Data de  jugger: " , data);
      if((data.message["code"] == "invite") || (data.message["code"] == "accept"))
      {
          enableOrgChat(data)
      }
      
      if(data.message["code"] == "write")
      {
            enableChat(data, false)
      }
      
      if(data.message["code"] == "status")
      {
          setStatus(data.sender, data.message["message"])
      }
    });
}

function enableOrgChat(data)
{
  if(data.receiver == data_session.buddy_id)
  {
      console.info("enableOrgChat" , data);
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
        });
        runEffect(data.sender);
        display_message_notification();
        go_buddies_notification();
        runEffect('inside-notification');
      }
      
      if(data.message["code"] == "accept")
      {
        console.info("uno");
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
        console.info("dos");
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
  console.info("Buferazo: " , buffer);
  
  // Is chatting from another room
  if(data.channel == channel_selected)
  {
    if(!buffer)
    {
      var ul = '<ul data-role="listview" data-inset="true" class="ui-listview ui-listview-inset ui-corner-all ui-shadow"><li class=" write_'+data.message["sender"]+' ui-li ui-li-static ui-body-c ui-corner-top ui-corner-bottom">'+data.message["message"]+'</li></ul>'
      $("#mesg").append(ul)
      var text = $("#mesg").children().last().first().text()
      $("#mesg").children().last().css("width", text.length*10)
      var margin = (document.width - (text.length*10))
      if(data.message["sender"] == data_session.buddy_id)
      {
        $(".write_"+data.message["sender"]).css("background-color", "#BADE86")
        $(".write_"+data.message["sender"]).css("background-image", "none");
        //$(".write_"+data.message["sender"]).parent().css("text-align", "left");
        $("#msg_body").val("")
      }
      else
      {
        $(".write_"+data.message["sender"]).css("background-color", "#ACD5E7")
        $(".write_"+data.message["sender"]).css("background-image", "none");
        //$(".write_"+data.message["sender"]).parent().css("margin-left", margin+"px");
      }
    }
    else
    {   
        var ul = '<ul data-role="listview" data-inset="true" class="ui-listview ui-listview-inset ui-corner-all ui-shadow"><li class=" write_'+data.buddy_id+' ui-li ui-li-static ui-body-c ui-corner-top ui-corner-bottom">'+data.message+'</li></ul>'
        $("#mesg").append(ul)
        var text = $("#mesg").children().last().first().text()
        $("#mesg").children().last().css("width", text.length*10)
        var margin = (document.width - (text.length*10))
        $(".write_"+data.buddy_id).css("background-color", "#ACD5E7")
        $(".write_"+data.buddy_id).css("background-image", "none");
        //$(".write_"+data.message["sender"]).parent().css("margin-left", margin+"px");
        
    }
  }
  else{
    console.info("deberia esperar");

  }
  
  
  
  setTimeout(function(){window.scroll(0,$(document).height()+200)},300);
}

function inviteChat()
{
  $(".buddy_content" ).unbind('click');
  $(".buddy_content" ).click(function(event){
    
     //aca preguntar si es el channel y levantar el buffer si ya estaban conectados
      $(this).removeAttr('style');
      var objLi = $(this);

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
      }
      else{
          channel_selected = objLi.attr('name');
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
      $.ajax({
        url: "/chat/write",
        type: 'POST',
        data: "channel="+channel_selected+"&message="+message+"&sender="+real_sender,
        success: function(data){}
      });
    }
    return false;
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
   $('#inside-notification').css("right", "-134px");
}
