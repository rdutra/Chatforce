var jugger_comm = undefined;
var data_session = undefined;
var data_channel = undefined;
var channel_selected = undefined;
var hidden_messages_size = 0;
var timer = 0;
var invite = false;


$("#buddies").live('pageinit', function(event){
    init()
});

$(document).bind( "pagechange", function( e, data ) {
  hide_notification_div();
});

$(".newMessaje").live('click', function(){
      hide_notification();
      $.mobile.changePage('buddies');
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
              if(data.signed == "false") window.location.replace("/index.html");
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
      console.info("Data channel_suscribe", data)
      if((data.message["code"] == "invite") || (data.message["code"] == "accept")) {
        enableOrgChat(data);
        
      } else if(data.message["code"] == "write") {
        enableChat(data, false);
        //runEffect(data.sender);
        
      } else if(data.message["code"] == "status") {
        setStatus(data.sender, data.message["message"]);
        
      } else if (data.message["code"] == "prediction") {
        setChatPrediction(data);

      } else if(data.message["code"] == "notify" && data.message.receiver_id == data_session.buddy_id ) {
        if($('.ui-page-active').attr('id') == "chat") show_notification_message(data);
        runEffect(data.sender);
      }

    });
}

function enableOrgChat(data)
{
  console.info("Data de enableOrgChat", data);
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
              if(conn_channel_data.signed == "false") window.location.replace("/index.html");
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
                if(buddy.signed == "false") window.location.replace("/index.html");
                jQuery('#header #status_circle').removeClass('Online Offline Busy Away');
                jQuery('#header #status_circle').addClass(buddy.status);
                jQuery('#header #name').text(buddy.name);
                jQuery('#header .picContainer > img')[0].src = buddy.pic;
              }
          });
        });

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
          init_buffer(data.message["message"], data.receiver)
          channel_subscribe(data.message["message"]);
      }
      
      if(data.message["code"] == "accept")
      {
        var is_indirect = $("#" + data.receiver).attr("indirect");
        if(is_indirect == "true")
        {
          init_chat(data.message["channel_conn"], true, undefined);
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
  
  console.info("Data enable chat", data)
  if(data.channel == channel_selected)
  {
    console.info("uno");
    if(data.sender != data_session.buddy_id && $('.ui-page-active').attr('id') == "buddies") runEffect(data.message['sender']);
    
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
  else
  {
    console.info("dos");
    if(data.sender != data_session.buddy_id && $('.ui-page-active').attr('id') == "chat")
      {
        show_notification_message(data);
      }
  }
  
  
  

  setTimeout(function(){window.scroll(0,$(document).height()+200)},300);
}

function inviteChat()
{
  $(".buddy_content" ).unbind('click');
  $(".buddy_content" ).click(function(event){
      
      $("#newMessajeCont").css("height", "0px")
      
      var objLi = $(this);
      jQuery('#header').attr('name',$(this).attr("id"));
      $.ajax({
          url: "/chat/get_buddy_info",
          type: 'POST',
          data: { buddy: $(this).attr("id")},
          success: function(buddy){
            if(buddy.signed == "false") window.location.replace("/index.html");
            jQuery('#header #status_circle').removeClass('Online Offline Busy Away');
            jQuery('#header #status_circle').addClass(buddy.status);
            jQuery('#header #name').text(buddy.name);
            jQuery('#header .picContainer > img')[0].src = buddy.pic;
          }
      });

      if(objLi.attr('name') == undefined){
        $.ajax({
          url: "/chat/invite_return_channel",
          type: 'POST',
          data: "channel="+data_session.org_channel+"&sender="+data_session.buddy_id+"&receiver="+$(this).attr("id"),
          success: function(data_ch){
            if(data_ch.signed == "false") window.location.replace("/index.html");
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
            if(data_buf.signed == "false") window.location.replace("/index.html");
            for (i=data_buf.length-1;i>=0;i--)
            {
                enableChat(data_buf[i], true);
            }  
          }
        });
      }
      $(this).removeAttr('style');
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

      /*if(id_sender != undefined)
      {
        $.ajax({
          url: "/chat/write",
          type: 'POST',
          data: "channel="+channel_selected+"&message="+message+"&sender="+real_sender,
          success: function(data){}
        });
      }*/
      
      $.ajax({
        url: "/chat/buffer",
        type: 'POST',
        data: "channel="+channel_selected+"&message="+message+"&sender="+real_sender,
        success: function(data_buffer){
          if(data_buffer.signed == "false") window.location.replace("/index.html");
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
        },
        success: function(data){
          if(data.signed == "false") window.location.replace("/index.html");
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
        },
        success: function(data){
           if(data.signed == "false") window.location.replace("/index.html");
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
          if(data.signed == "false") window.location.replace("/index.html");
          for (i=data.length-1;i>=0;i--)
          {
              enableChat(data[i], true)
          }          
        }
      });
  }
}

function init_buffer(channel, receiver)
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
        success: function(data){
           if(data.signed == "false") window.location.replace("/index.html");
          }
      });
      
      $.ajax({
        url: "/chat/send_notification",
        type: 'POST',
        data: "org_channel="+data_session.org_channel+"&message="+message+"&sender="+data_session.buddy_id+"&receiver="+receiver,
        success: function(data){
           if(data.signed == "false") window.location.replace("/index.html");
          }
      });
      
    }
    return false;
  });
  
}

function setStatus(sender, message)
{
    $("#"+sender+" .buddyStatus").removeClass('Online Offline Busy Away');
    $("#"+sender+" .buddyStatus").addClass(message);
    if (sender == jQuery('#header').attr('name')){
      jQuery('#header #status_circle').removeClass('Online Offline Busy Away');
      jQuery('#header #status_circle').addClass(message);
    } else if(sender == data_session.buddy_id){
      jQuery('#header-main #status_circle').removeClass('Online Offline Busy Away');
      jQuery('#header-main #status_circle').addClass(message);
    }
}

function hide_notification()
{
   $("#newMessajeCont").css("height", "0px");
   $("#mesg").html("");
   hidden_messages_size = 0;
}

function hide_notification_div()
{
   $("#newMessajeCont").css("height", "0px");
   hidden_messages_size = 0;
}

function show_notification_message(data)
{  
  
    if( $(".newMsjSender").attr("last-id") != undefined && $(".newMsjSender").attr("last-id") != data.message.sender_id ) 
    {
      hidden_messages_size = 0;
    }
    
    hidden_messages_size ++;
    $(".newMsjSender").attr( "last-id", data.message.sender_id );
    $(".newMsjSender").html(data.message.senderName);
    var sendMsj = $(".newMsjSender")[0];

    $(".newMessaje").html("");
    $(".newMessaje").append(sendMsj);
    $(".newMessaje").append(data.message.message);
    $(".picContainerTh img")[0].src = data.message.pic;
    $(".newMessajeCount").html(hidden_messages_size);
    $("#newMessajeCont").css("height", "32px");
    //$("#newMessajeCont").addClass("newMessajeMod");
    
}

function add_ellipsis(str)
{  
  if(str != undefined)
  {
    if(str.length > 26)
    {
      str = str.substr(0,25) + "...";
    }
  }
  return str;
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

function searchInContactsFilter(element){
  var filter = element.value.toLowerCase();
  jQuery('.buddyListItem .buddyName[data-filter-text*=' + filter + ']').each(function (index,element){
    jQuery(element).parent().css('display','');
  });
  jQuery('.buddyListItem .buddyName:not([data-filter-text*=' + filter + '])').each(function (index,element){
    jQuery(element).parent().css('display','none');
  });
  if (jQuery('.buddiesHidden').length == 0){
    buddiesInit();
  }
}

function toggleSerch(){
  element = jQuery('.searchContainer');
  if (parseInt(element.height()) == 0 ){
    element.height(element.children().outerHeight());
  } else {
    element.height(0);
  }
}
function toggleBuddies(){
  element = jQuery('.buddiesContainer');
  if (jQuery('.buddiesHidden').length != 0){
    var tHeight= 0;
    element.children().each(function (index, element){
      tHeight += jQuery(element).outerHeight();
    });
    element.height(tHeight);
    element.find('.buddyListHeaderBtn').removeClass('buddiesHidden');
  } else {
    element.height(parseInt(element.children().outerHeight()) -1);
    element.find('.buddyListHeaderBtn').addClass('buddiesHidden');
  }
}
function buddiesInit(){
  element = jQuery('.buddiesContainer');
  var tHeight= 0;
  element.children().each(function (index, element){
    tHeight += jQuery(element).outerHeight();
  });
  tHeight -= (tHeight == element.children().outerHeight())? 1 : 0;
  element.css({ 
    'height': tHeight,
    '-webkit-transition': 'height 0s linear',
    '-ms-transition': 'height 0s linear',
    '-moz-transition': 'height 0s linear',
    'transition': 'height 0s linear'
  });
  setTimeout(function(){element.css({ 
    '-webkit-transition': '',
    '-ms-transition': '',
    '-moz-transition': '',
    'transition': ''
  });},0);
}
jQuery(document).ready(function(){buddiesInit()});
