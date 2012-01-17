//= require jquery
//= require app
//= require_tree .
//= require_self

// Stupid IE
var tags = ['header', 'section', 'article'];
while(tags.length)
  document.createElement(tags.pop());
  
function popup(pageURL, title,w,h) {
  var left = (screen.width/2)-(w/2);
  var top = (screen.height/2)-(h/2);
  var targetWin = window.open(
    pageURL,
    title,
    'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left
    );
}