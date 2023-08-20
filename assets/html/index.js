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
    function navigateTo(href: string) {
      console.log(href);
    }