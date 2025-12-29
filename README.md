# Simple Web Live Multiplayer Server

**A lightweight server and JS helper that instantly adds real-time, multi-user messaging to any existing web app or game.
You host your app anywhere; this server wraps it and connects all users via WebSockets.**

**Designed for fast multiplayer prototypes, collaborative tools, live demos, and experiments.**


> [!IMPORTANT]  
> Please review **Important Notes** at bottom of this readme.


## Table of Contents
 - **[Overview](#overview)**
  - [Setup and run the server](#setup-and-run-the-server)
  - [Add your content](#add-your-content)
  - [Sending and Receiving messages in your webapp](#sending-and-receiving-messages-in-your-webapp)
 - **[Quick Start](#quick-start)**
 - **[Without docker](#without-docker)**
 - **[How it works](#how-it-works)**
 - **[Important Notes](#important-notes)**



<br>
<br>

# Overview

This is a backend server that provides a peer to peer websocket connections, provide it a url to your webapp and it will serve it with all the plumbing setup for you.

## In brief:
> [!NOTE]  
> When I mention server at http://localhost:8081 it can be of course any url, just proxy it!

**Start It Up** - Starting the server (I suggest via [docker-compose.yml](https://github.com/spilehx/hx-simple-web-multiplayer-server/blob/main/docker-compose.yml)) Will start a http server and a websocket server

**A Web Page That Connects all users** - Once started, loading the page at http://localhost:8081 (or where ever you have set it up for) will show a webpage that is able to send live data via a websocket to any other user that loads that URL. By default you will see a debugging page here, load it in several browsers and have a play!

**Add your webapp or game** - If you set the FRAME_URL value in the [docker-compose.yml](https://github.com/spilehx/hx-simple-web-multiplayer-server/blob/main/docker-compose.yml) to the URL of your web-app the http://localhost:8081 page will load your content in a frame.


**Get your page sending and Receiving messages** - The server provides its own code to help, this can be found at http://localhost:8081/framecode.js, load this in a ```<script>``` in you webapp html. Your code will then have access to a ```frameMessaging``` object which you can listen to and send messages via.


---
<br>
<br>

# Quick Start

> [!NOTE]
> You dont need to clone this repo to use it, its all provided in [docker images](https://github.com/spilehx/hx-simple-web-multiplayer-server/pkgs/container/hx-simple-web-multiplayer-server/618850731?tag=latest). This assumes that you have [docker setup and running](https://www.docker.com/get-started/)


## Setup and run the server
 - Create a ```docker-compose.yml``` use the [one in the repo](https://github.com/spilehx/hx-simple-web-multiplayer-server/blob/main/docker-compose.yml) as a guide
 - Start the server, unless you start it with ```-d``` you will see the server activity logs

	```console
	$ docker compose up
	```

- Check it all works correctly by opening a browser to http://localhost:8081, You should see the debug interface. Here is what it looks like with 2 browsers open. ***Note they are connected to each other!***
<div align="center" width="80%">
    <img src="https://raw.githubusercontent.com/spilehx/hx-simple-web-multiplayer-server/main/docs/demo.gif" alt="" />
</div>

- Stop the server ```ctrl-c ``` and follow the next section to setup your content.

## Add your content

> [!NOTE]
> You need to have your webpage hosted on a webserver - This project wont host your content, it will just load it in an iFrame and provide connectivity!

- Open your ```docker-compose.yml``` and add environment variable for ```FRAME_URL``` this should be the url of your webpage

	```
	services:
		hxsimplewebmultiplayerserver:
			container_name: hx-simple-web-multiplayer-server
			image: ghcr.io/spilehx/hx-simple-web-multiplayer-server:latest
			ports:
				- "8081:80"
			environment:
				FRAME_URL: "[YOUR PAGE URL HERE]"
	``` 
- Start the server, unless you start it with ```-d``` you will see the server activity logs

	```console
	$ docker compose up
	```
- Check it all works correctly by opening a browser to http://localhost:8081, You should see your page loaded. ***Now lets get your app communicating!** 


## Sending and Receiving messages in your webapp
- You need to add some js code to your html, this code is provided on a url from the server at ```http://localhost:8081/framecode.js``` when this is loaded you need to call ```frameMessaging.init();``` to start it and set ```frameMessaging.onHostMessage``` to get the messages.
  
  All in one example using the ```parentOrigin``` that is passed to your frame
  	```js
	window.onload = function () {
		const s = document.createElement('script');
		s.src = new URLSearchParams(location.search).get("parentOrigin") + "/framecode.js";
		s.onload = () => {
			frameMessaging.init(); // Start comms!
			frameMessaging.onHostMessage = onHostMessage; // set a function to get the messages
		};
		document.head.appendChild(s);
	};

	function onHostMessage(msg) {
		// here are the messages
	}

	``` 
  
  
  You can also just add the link in a ```<script>```in your html ```<head>``` ***Note: But you will have to set the url manually**

	```html
	<script src="http://localhost:8081/framecode.js"></script>
	``` 

- When you reload the server your page will be connected! ***See example below for a full example of how to implement in your code.***

	```html
	<!DOCTYPE html>
	<html>

	<head>
		<script>

			// load the comms code provided by the server
			// This page is loaded as a frame and is passed the parent origin as a url param, 
			// so we can use that to get "https://whereYourServerIs.com/framecode.js"
			window.onload = function () {
				const s = document.createElement('script');
				s.src = new URLSearchParams(location.search).get("parentOrigin") + "/framecode.js";
				s.onload = () => {
					frameMessaging.init(); // Start comms!

					frameMessaging.onHostMessage = onHostMessage; // set a function to get the messages
				};
				document.head.appendChild(s);
			};

			// Incoming messages!
			function onHostMessage(msg) {
				var type = msg.type;
				var message = msg.data;
				switch (type) {
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
						onSocketMessage(message);
						break;
				}
			}

			function onSocketMessage(message) {
				document.getElementById("nusers").innerHTML = message.data.connectedUsers;
			}


			/* Create functions like these to send data */

			function sendGlobalMessage() {
				// GlobalMessages are passed on to ALL users

				// You can send ANY data structure you like!
				var data = {
					foo: "bar",
					thing: 1
				};
				frameMessaging.sendGlobalMessage(data);
			}

			function sendDirectMessage() {
				// DirectMessage are passed only to a specific user
				// a user list is sent to you in your GlobalMessages, find UserId there
				var userID = "1234567";
				// You can send ANY data structure you like!
				var data = {
					foo: "bar",
					thing: 1
				};
				frameMessaging.sendDirectMessage(data, userID);
			}

		</script>
	</head>

	<body>
		<p id="nusers"></p>
	</body>

	</html>
	```

- Messages arrive in this format, This example is for ```globalData```. Note that each user has thier own ```globalData``` this is so you know who its from.
	```json
	{
		"classname": "GlobalMessage",
		"data": {
			"data": {
				"users": [
					{
						"globalData": {},
						"userID": "1765581374608-D9443E",
						"wsUUID": "31f6de90-d380-11f0-90d4-61446f5aca2d"
					},
					{
						"globalData": {
							"messageType": "GlobalUpdateMessage",
							"ts": 0,
							"data": {
								[WHATEVER DATA YOU SENT]
							},
							"userID": ""
						},
						"userID": "1765579167876-9E3300",
						"wsUUID": "2be22af0-d380-11f0-90d4-7f18d2eb7da3"
					}
				],
				"connectedUsers": 2
			},
			"messageType": "GlobalMessage",
			"ts": 1766368066000
		}
	}

	```

<br>
<br>

# Without docker
If you dont want to use docker, you can just use the [server binary](https://github.com/spilehx/hx-simple-web-multiplayer-server/releases/latest) 

This server is written in [Haxe](https://haxe.org/) and requires the Hashlink runtime. **You MUST have this installed to run it** [Details here](https://hashlink.haxe.org/)

## Running the binary
Just execute like this, and pass args as required
```console
$ hl P2PServer.hl
```

For details on args run 
```console
$ hl P2PServer.hl --help
```

---
<br>
<br>


# How it works

### High-level flow

```text
┌──────────────┐
│  User A      │
│  Browser     │
│              │
│  iframe      │◀───────────────┐
│  (your app)  │                │
└──────┬───────┘                │
       │ WebSocket              │ WebSocket
       │                        │
┌──────▼────────────────────────▼──────┐
│   Simple Web Live Multiplayer Server  │
│   - HTTP server                       │
│   - WebSocket hub                     │
│   - Message routing                   │
└──────▲────────────────────────▲──────┘
       │                        │
       │ WebSocket              │ WebSocket
       │                        │
┌──────┴───────┐                ┌──────┴───────┐
│  User B      │                │  User C      │
│  Browser     │                │  Browser     │
│              │                │              │
│  iframe      │                │  iframe      │
│  (your app)  │                │  (your app)  │
└──────────────┘                └──────────────┘
```

### Message flow
1. Users open the server URL
2. The server loads your app URL inside an iframe
3. Your app loads `framecode.js`
4. Each iframe opens a WebSocket connection to the server
5. The server relays messages (global or direct) between users
6. Your app receives events via `frameMessaging.onHostMessage`


---
<br>
<br>

# Important Notes

**Q: How mature is this project?**

**A:** It works, BUT its still WORK IN PROGRESS - Please be aware of this!

**Q: Is this production ready, fully app sec tested and ready for my important project**

**A:** Please use at your own risk, and probably best not on anything mission critical. Remember all data is open to all users and you can sen whatever you like.

**Q: I found a bug!**

**A:** GREAT!! That means its being used! Just create an issue on this repo and i will try and have a look!

