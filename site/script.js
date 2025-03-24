// Sidebar and Dropdown Functionality

// Get the Sidebar
var mySidebar = document.getElementById("mySidebar");

// Get the DIV with overlay effect
var overlayBg = document.getElementById("myOverlay");

// Toggle between showing and hiding the sidebar, and add overlay effect
function w3_open() {
  if (mySidebar.style.display === 'block') {
    mySidebar.style.display = 'none';
    overlayBg.style.display = "none";
  } else {
    mySidebar.style.display = 'block';
    overlayBg.style.display = "block";
  }
}

// Close the sidebar with the close button
function w3_close() {
  mySidebar.style.display = "none";
  overlayBg.style.display = "none";
}

// Function for the 01 Network Basics dropdown
function myFunction() {
  var x = document.getElementById("Network Basics");
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}

// Function for the 02 Network Security dropdown
function myFunction2() {
  var x = document.getElementById("Network Security");
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}

// Function for the 03 Network Infrastructure dropdown
function myFunction3() {
  var x = document.getElementById("Network Infrastructure");
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}

// Function for the 04 Encryption & Security dropdown
function myFunction4() {
  var x = document.getElementById("Encryption & Security");
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}

// Function for the 05 DNS & DNSSEC dropdown
function myFunction5() {
  var x = document.getElementById("DNS & DNSSEC");
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}

// Function for the 06 Cloud Computing dropdown
function myFunction6() {
  var x = document.getElementById("Cloud Computing");
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}

// Function for the 07 Misc Technologies dropdown
function myFunction7() {
  var x = document.getElementById("Misc Technologies");
  if (x.className.indexOf("w3-show") == -1) {
    x.className += " w3-show";
  } else { 
    x.className = x.className.replace(" w3-show", "");
  }
}

function copyCode() {
  const codeSnippet = document.getElementById("codeSnippet");
  const range = document.createRange();
  range.selectNode(codeSnippet);
  window.getSelection().removeAllRanges();
  window.getSelection().addRange(range);
  try {
      document.execCommand('copy');
      alert('Code copied to clipboard!');
  } catch (err) {
      alert('Failed to copy code');
  }
  window.getSelection().removeAllRanges();
}
