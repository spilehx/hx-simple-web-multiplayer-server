# Simple Web Live Multiplayer Server

**A lightweight server and JS helper that instantly adds real-time, multi-user messaging to any existing web app or game.
You host your app anywhere; this server wraps it and connects all users via WebSockets.**

**Designed for fast multiplayer prototypes, collaborative tools, live demos, and experiments.**


> [!IMPORTANT]  
> Please review **Important Notes** at bottom of this readme.


## Table of Contents
  - **[Overview](#overview)**
  - **[How to get it going](#how-to-get-it-going)**
  	- [Step 1: Setup and run the server](#step-1-setup-and-run-the-server)
  	- [Step 2: Adding your content](#step-2-adding-your-content)
  	- [Step 3: Sending and receiving messages](#step-3-sending-and-receiving-messages)
  		- [Simple all-in-one JS code to add](#simple-all-in-one-js-code-to-add)
  		- [If using haxe to make your webapp.](#if-using-haxe-to-make-your-webapp)
  		- [Geeky explanation of what these examples are doing](#geeky-explanation-of-what-these-examples-are-doing)
  - **[The data that is sent](#the-data-that-is-sent)**
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

# How to get it going

> [!NOTE]
> You dont need to clone this repo to use it, its all provided in [docker images](https://github.com/spilehx/hx-simple-web-multiplayer-server/pkgs/container/hx-simple-web-multiplayer-server/618850731?tag=latest). This assumes that you have [docker setup and running](https://www.docker.com/get-started/)


## Step 1: Setup and run the server
 - Create a ```docker-compose.yml``` use the [one in the repo](https://github.com/spilehx/hx-simple-web-multiplayer-server/blob/main/docker-compose.yml) as a guide
 - Start the server *(start it with ```-d``` if you don't want to see the logs)*
	```console
	$ docker compose up
	```
- Check it all works correctly by opening a browser to http://localhost:8081, You should see the debug interface. Here is what it looks like with 2 browsers open. <ins>Note they are connected to each other!</ins> All browsers that open that URL will be connected.
  
<div align="center" width="100%">
    <img src="https://raw.githubusercontent.com/spilehx/hx-simple-web-multiplayer-server/main/docs/demo.gif" alt="" width="80%" />
</div>

- Now, stop the server ```ctrl-c ``` and follow the next section to put your content in.

<br>

## Step 2: Adding your content

> [!NOTE]
> Your web app page needs to be on its own webserver so that it loads directly on a URL. This service does not act as a webserver for your content, it will just load it in an iFrame and warp it to provide the communication connectivity!

- Open the ```docker-compose.yml``` we made in the last step and add environment variable for ```FRAME_URL``` this should be the full url of your webpage html.

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
- Start the server *(start it with ```-d``` if you don't want to see the logs)*

	```console
	$ docker compose up
	```
- Check it works by opening a browser to http://localhost:8081, You should see your page loaded. 
	
	> [!TIP]
	> If you open the dev tools in your browser, you can see how it works, there is a main webpage that has the comms code, and your app is loaded in an iframe. You can also see log messages from the comms code - If you dont want to see these logs set ```VERBOSE_LOGGING: "false"``` in the ```docker-compose.yml```



<br>

## Step 3: Sending and receiving messages

Your webapp needs to include a small bit of JS - This code is provided by the running server and is easy to setup!


### Simple all-in-one JS code to add

 - Open up the ```index.html``` for your webapp and add the following code to the ```<body>```.

	```html
	<script>
		window.onload = function () {
			const s = document.createElement('script');
			s.src = new URLSearchParams(location.search).get("parentOrigin") + "/framecode.js";
			s.onload = () => {
				frameMessaging.init();
				frameMessaging.onHostMessage = onHostMessage;
			};
			document.head.appendChild(s);
		};

		function onHostMessage(msg) {
			// You will get your messages here
			console.log(msg);
		}

	</script>
	``` 

 - Now reload the main page http://localhost:8081 and in the browser dev tools you will see full messages logged each time a new user connects.

### If using haxe to make your webapp.

**With haxe its really easy as there is a haxelib**

- Install the haxelib
  ```console
	$ haxelib git hx-simple-web-multiplayer-server-tools https://github.com/spilehx/hx-simple-web-multiplayer-server  
  ```
- Add this to your ```build.hxml```
	```
	-lib hx-simple-web-multiplayer-server-tools
	```
- In your haxe code you will have access to an object called ```MultiplayerMessaging``` start it and use it like this
  ```haxe
	import spilehx.p2pserver.MultiplayerMessaging;

	class MyApp {
		function new() {
			//This loads the supporting code into your page and starts the comms
			MultiplayerMessaging.instance.init(onMultiplayerMessagingReady);

			//To add the onMessage Function
			MultiplayerMessaging.instance.onMessage = onMultiplayerMessage;
		}

		private function onMultiplayerMessagingReady() {
			trace("Messaging ready!!");
		}

		private function onMultiplayerMessage(message:Message){
			// you will get your messages here
			trace("New message!");
			trace(message.data);
		}
		
		private function sendData(){
			// send a message using a function like this.
			// you can send anything, 
			// but be aware that whilst being sent it will be turned into json
			// here is a random example

			var thisCanBeAnyData:Dynamic = {
				foo: "bar",
				n: 1337,
				complexObject: aComplexObject,
				boolsToo: true
			}
			MultiplayerMessaging.instance.send();
		}
	}

  ```

 - Now build your haxe project reload the main page http://localhost:8081 and in the browser dev tools you will see full messages logged each time.
 - ```MultiplayerMessaging``` Is a singleton so can be called from anywhere like this ```MultiplayerMessaging.instance.send(blah)```. Have a look at the [haxelib class](https://github.com/spilehx/hx-simple-web-multiplayer-server/blob/main/haxelib/spilehx/p2pserver/MultiplayerMessaging.hx) to see how it works in detail



### Geeky explanation of what these examples are doing
> [!NOTE]  
> Normally you don't have to read this bit, its just for those interested.

- Whilst running, the server provides its own code to include at http://localhost:8081/framecode.js you can load it and have a look, but its minified, to see whats is in it you [can look here](https://github.com/spilehx/hx-simple-web-multiplayer-server/blob/main/src/spilehx/p2pserver/iframecommscode/IframeCommsScript.hx)
- You never need to worry about this code being out of date as its packaged in the server *handy right!*
- The sample code above sets things up like this:
  - When your webapp is loaded in the iframe we pass it the URL of the parent page, and use that to get the url of the js code.
  - We then add a ```<script>``` tag to the head.
  - This allows your page to send and get messages via a post message to the main page where everything else is done for you.



# The data that is sent

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

