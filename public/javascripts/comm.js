var jugger_comm = undefined
var org_channel = undefined

$(document).live('pageshow', function(event){
    org_channel = $.cookie("chgo_org_key")
    enableCommChat(org_channel)
    createChat()
});

$(document).live('pagehide', function(event){
    org_channel = $.cookie("chgo_org_key")
    disableCommChat(org_channel)
    //destroyChat()
});

function enableCommChat(channel) {
  //init()
  if (!(typeof jugger_comm !== undefined && jugger_comm)) {
    jugger_comm = new Juggernaut();
    jugger_comm.subscribe(channel, function(data){
      console.log(data)
      if(data.receiver == $.cookie("chgo_user_id"))
      {
          runEffect(data.sender);
          
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

function createChat()
{
  $(".buddy_content" ).click(function(event){
    if($.cookie('chgo_ch_key') == null)
    {
      $.cookie('chgo_re_id',$(this).attr("id"));
      $.ajax({
          url: '/chat/create_channel',
          type: 'POST',
          data: "channel="+$.cookie("chgo_org_key")+"sender="+$.cookie("chgo_user_id")+"&receiver="+$.cookie('chgo_re_id'),
          success: function(data){
            $.cookie('chgo_ch_key',data);
          }
        });     
    }
    document.location = "/chat/single"
      
     //return false;
  });
}



