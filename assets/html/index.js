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
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"downloadFile","url":"https://www.kozco.com/tech/LRMonoPhase4.mp3"}').then(function(result) {
      console.log(result);
    });
    }
    function shareNetworkFile() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"shareFile","url":"this is url"}').then(function(result) {
      console.log(result);
    });
    }
    function setWallpaper() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"setWallpaper"}').then(function(result) {
      console.log(result);
    });
    }
    function addEvent() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"addEvent","id":"1","title":"test event","date":"2023-08-19 16:48:12.152664"}').then(function(result) {
      console.log(result);
    });
    }
    function removeEvent() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"removeEvent","id":"1"}').then(function(result) {
      console.log(result);
    });
    }
    function openDrawer() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"openDrawer","menu":[{"name": "Home", "href": "/admin/","id": "cl-0", "children": [] },{"name": "Base","expanded": false,"id": "cl-1", "children": [{"name": "DataTypes","href": "/admin/DataType","id": "cl-2","children": []},{"name": "Components Category","href": "/admin/CompCategory","id": "cl-3","children": []}]}]}').then(function(result) {
      console.log(result);
    });
    }
    function getLocation() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"getLocation"}').then(function(result) {
      console.log(result);
    });
    }
    function clearCache() {
    window.flutter_inappwebview.callHandler('myChannel', '{"action":"clearCache"}').then(function(result) {
      console.log(result);
    });
    }
     function showNotification() {
        window.flutter_inappwebview.callHandler('myChannel', '{"action":"showNotification","title":"test title","body":"this is test notification body"}').then(function(result) {
          console.log(result);
        });
     }
     function scheduleNotification() {
             window.flutter_inappwebview.callHandler('myChannel', '{"action":"scheduleNotification","title":"Schedule title","body":"this is schedule notification body"}').then(function(result) {
               console.log(result);
             });
     }