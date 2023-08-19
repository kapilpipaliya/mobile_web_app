const initialUrl = "";

const String htmlContent = """<!DOCTYPE html>
<html>
<head>
<title>Custom actions</title>
</head>
<body>
<button onclick="navbar()">Show/Hide statusBar</button>
<h1>Click button to open drawer</h1>
<button onclick="openDrawer()">openDrawer</button>
<h1>Click button to select file</h1>
<button onclick="selectFile()">select file</button>
<h1>Click button to share file</h1>
<button onclick="shareFile()">share File</button>
<h1>Click button to download file</h1>
<button onclick="downloadFile()">Download</button>
<h1>Click button to set home screen Wallpaper</h1>
<button onclick="setWallpaper()">set WallPaper</button>
<h1>Click button to add Calender event</h1>
<button onclick="addEvent()">addEvent</button>
<h1>Click button to remove Calender event</h1>
<button onclick="removeEvent()">removeEvent</button>
<script>
    function navbar() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"navbar"}').then(function(result) {
      console.log(result);
    });
    }
    function selectFile() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"selectFile"}').then(function(result) {
      console.log(result);
    });
    }
    function shareFile() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"shareFile"}').then(function(result) {
      console.log(result);
    });
    }
    function downloadFile() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"downloadFile","url":"this is url"}').then(function(result) {
      console.log(result);
    });
    }
    function setWallpaper() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"setWallpaper"}').then(function(result) {
      console.log(result);
    });
    }
    function addEvent() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"addEvent","title":"3532","date":"2023-08-19 16:48:12.152664"}').then(function(result) {
      console.log(result);
    });
    }
    function removeEvent() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"removeEvent","title":"3532"}').then(function(result) {
      console.log(result);
    });
    }
    function openDrawer() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"openDrawer","menu":["first action","second action"]}').then(function(result) {
      console.log(result);
    });
    }
</script>
</body>
</html>""";
