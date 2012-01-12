var jug = undefined
var org_channel = undefined
$(document).live('pageshow', function(event){
    org_channel = $.cookie("chgo_org_key")
    enableChat(org_channel)
});

$(document).live('pagehide', function(event){
    org_channel = $.cookie("chgo_org_key")
    disableChat(org_channel)
});

function enableChat(channel) {
  init()
  if (!(typeof jug !== undefined && jug)) {
    jug = new Juggernaut();
    jug.subscribe(channel, function(data){
      console.log(data.receiver)
      if(data.receiver == $.cookie("chgo_user_id"))
      {
          runEffect(data.sender);
      }
      
    }); 
   } 
}  

function disableChat(channel)
{
    if (typeof jug !== undefined && jug)
    {
      jug.unsubscribe(channel)
      jug.unbind()
    }
}

var timer = 0

// run the currently selected effect
function runEffect(buddy_id) {
  // get effect type
  var selectedEffect = "highlight"
  
  // most effect types need no options passed by default
  var options = {color: "#0DAE1D"};
  
  // run the effect
  $( "#"+buddy_id ).effect( selectedEffect, options, 500, callback(buddy_id) );
};

// callback function to bring a hidden box back
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
    }
  }, 550 );
};

function init()
{
  $(".buddy_content" ).click(function(event){
      $.ajax({
          url: '/chat/send',
          type: 'POST',
          data: "channel="+$.cookie("chgo_org_key")+"&sender="+$.cookie("chgo_user_id")+"&receiver="+$(this).attr("id")+"&message=keep alive",
        });
     return false;   
  });
}

