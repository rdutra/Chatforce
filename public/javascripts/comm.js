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
  if (!(typeof jug !== undefined && jug)) {
    jug = new Juggernaut();
    jug.subscribe(channel, function(data){
      runEffect();
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
function runEffect() {
  // get effect type
  var selectedEffect = "highlight"
  
  // most effect types need no options passed by default
  var options = {color: "#0DAE1D"};
  
  // run the effect
  $( ".buddy_content" ).effect( selectedEffect, options, 500, callback );
};

// callback function to bring a hidden box back
function callback() {
  setTimeout(function() {
    timer++
    if(timer < 5)
    {
      runEffect()
    }
    else
    {
      timer = 0
    }
  }, 550 );
};
