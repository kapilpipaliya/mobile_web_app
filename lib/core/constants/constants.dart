const initialUrl = "";

const String htmlContent = """<!DOCTYPE html>
<html>
<head>
<title>Custom actions</title>
</head>
<body>
<button onclick="navbar()">Show/Hide statusBar</button>
<h1>Click button to select file</h1>
<button onclick="selectFile()">select file</button>
<h1>Click button to share file</h1>
<button onclick="shareFile()">share File</button>
<h1>Click button to download file</h1>
<button onclick="downloadFile()">Download</button>
<h1>Click button to set home screen Wallpaper</h1>
<button onclick="setWallpaper()">set WallPaper</button>
<script>
    function navbar() {
    window.flutter_inappwebview.callHandler('myChannel', 'navbar').then(function(result) {
      console.log(result);
    });
    }
    function selectFile() {
    window.flutter_inappwebview.callHandler('myChannel', 'selectFile').then(function(result) {
      console.log(result);
    });
    }
    function shareFile() {
    window.flutter_inappwebview.callHandler('myChannel', 'shareFile').then(function(result) {
      console.log(result);
    });
    }
    function downloadFile() {
    window.flutter_inappwebview.callHandler('myChannel', 'downloadFile','this is url').then(function(result) {
      console.log(result);
    });
    }
    function setWallpaper() {
    window.flutter_inappwebview.callHandler('myChannel', 'setWallpaper').then(function(result) {
      console.log(result);
    });
    }
</script>
</body>
</html>""";
