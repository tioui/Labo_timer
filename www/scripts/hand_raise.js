function checkRaised(open_url) {
  var xhttp;
  if (window.XMLHttpRequest) {
    // code for modern browsers
    xhttp = new XMLHttpRequest();
    } else {
    // code for IE6, IE5
    xhttp = new ActiveXObject("Microsoft.XMLHTTP");
  }
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      if (this.responseText === "1") {
        document.getElementsByName("hand")[0].style.display = "none";
        document.getElementsByName("raised")[0].style.display = "";
      } else {
        document.getElementsByName("hand")[0].style.display = "";
        document.getElementsByName("raised")[0].style.display = "none";
     }
    }
  };
  xhttp.open("GET", open_url, true);
  xhttp.send();
}
