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
				document.getElementById("hand").style.display = "none";
				document.getElementById("raised").style.display = "";
			} else {
				document.getElementById("hand").style.display = "";
				document.getElementById("raised").style.display = "none";
			}
		}
	};
	xhttp.open("GET", open_url, true);
	xhttp.send();
}

function update_nb_interventions(open_url) {
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
			document.getElementById("nb_interventions").innerHTML = this.responseText;
		}
	};
	xhttp.open("GET", open_url, true);
	xhttp.send();
}

function update_interventions(open_url) {
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
			document.getElementById("table_interventions").innerHTML = this.responseText;
		}
	};
	xhttp.open("GET", open_url, true);
	xhttp.send();
}
