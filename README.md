# Simple web live multiplayer server

# Work in progress - updated docs soon

This is a simple server/harness to help quickly develop realtime mulitplayer web apps.


### Table of Contents
 - **[Overview](#overview)**
 - **[Quick Start](#quick-start)**


<br>
<br>

# Overview
I wanted a quick way to try out some live multi-user app ideas, so this project is a simple webserver/harness specifically to help with this.

In brief:
 - When you start the server, it starts a webserver at http://localhost:1337
 - Loading this URL in a browser opens a webpage that has a live socket connection (via the server) to everyone else that loads that URL.
 - It will by default load a debug view to show this.
 - By providing command line argument to the server you can define a url to your web app that it will load in an Iframe served to all the users
 - The application provides a url to js to include in your webpage that allows it to use the socket connection.
 - Your web app will now be able to send any object to the server and this will be broadcast to all users.



---
<br>
<br>

# Quick Start
 - Run the server binary with hashlink (standalone bin coming soon)

```console
$ hl P2PServer.hl
```

- You can now open a browser to see the Debug interface http://localhost:1337, open multiple browsers and see the live connections

<div align="center" width="100%">
    <img src="https://raw.githubusercontent.com/spilehx/hx-simple-web-multiplayer-server/main/docs/demo.gif" width="900" alt="" />
</div>

- Running with the -url arg will load your webpage in the harness

```console
$ hl P2PServer.hl -url http://myapp.com/fabapp.html
``` 

- To setup your app to use the connection use the handy code the server serves up, like this
```html
<!DOCTYPE html>
<html>

<head>
	<!-- update this url based on where you are serving, this js code is embeded in the server for ease of use -->
	<script src="http://localhost:1337/framecode.js"></script>
	<script>
		function start() {
			frameMessaging.onHostMessage = onHostMessage;
			frameMessaging.init();
		}

		function onHostMessage(msg) {
			// Incoming messages!
			var type = msg.type;
			var data = msg.data;
			console.log("type--> " + type);
			console.log("Data--> " + JSON.stringify(data));
			switch (type){
				case "SOCKET_OPEN":
					console.log("SOCKET_OPEN");
				break;

				case "SOCKET_CLOSE":
					console.log("SOCKET_CLOSE");
				break;

				case "SOCKET_ERROR":
					console.log("SOCKET_ERROR");
				break;

				case "SOCKET_REGISTER":
					console.log("SOCKET_REGISTER");
				break;

				case "SOCKET_KEEPALIVE":
					console.log("SOCKET_KEEPALIVE");
				break;

				case "SOCKET_MESSAGE":
					console.log("SOCKET_MESSAGE");
				break;
			}
		}

		function sendMessage() {
			// send any data like this
			var data = {
				foo: "bar",
				thing: 1
			};
			frameMessaging.sendFrameMessage(data);
		}

		window.onload = function () {
			start();
		};
	</script>
</head>

<body>
</body>
</html>
```

- Data is send to all users in the in an array of user data like this (note the unique id of each user,  this id persists when they reconnect as it is stored in a cookie on first connection)
```json
{
    "4ad40da0-d380-11f0-b0d1-03b3229af6ee": {
        "data": {
            "foo": "bar",
            "thing": 1
        },
        "userID": "1765579167876-9E3300",
        "wsUUID": "4ad40da0-d380-11f0-b0d1-03b3229af6ee"
    },
    "49784e30-d380-11f0-b0d1-7918b07669c2": {
        "data": {
            "foo": "bar",
            "thing": 1
        },
        "userID": "1765581374608-D9443E",
        "wsUUID": "49784e30-d380-11f0-b0d1-7918b07669c2"
    }
}

```