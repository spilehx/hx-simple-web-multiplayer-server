package spilehx.p2pserver.server.restservicemanager.routes;

import weblink.Request;
import spilehx.core.http.RestDataObject;
import weblink.Weblink;
import spilehx.core.http.Route;

class DebugContentRoute extends Route {
	private static final NO_CONNECT_IMG:String = "data:image/gif;base64,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";
	private static final BG_COLOUR:String = "#303030";
	private static final FONT_COLOUR:String = "#959595";
	private static final CONNECTING_MSG:String = "Connecting";
	private static final FONT_SIZE:String = "1.4rem";
	private static final PAGE_OPACITY:String = "0.8";

	private var pageContent:String;

	public function new(server:Weblink) {
		pageContent = getContent();
		super("/debugclient.html", new RestDataObject(), Route.GET_METHOD, server);
	}

	override function onRequest(request:Request) {
		this.response.send(pageContent);
	}

	private function getContent():String {
		return '
			<!doctype html>
			<html>
				<head>
					<script src="/framecode.js"></script>
					<script>

						// setup canvas
						var canvas = {};
        				var ctx = {};

						function start() {
							console.log("Starting Debug Client ");
							frameMessaging.onHostMessage = onHostMessage;
							frameMessaging.init(window.location.protocol+"//"+window.location.host);
							addCanvas();
						}
						
						function onHostMessage(msg) {
							var type = msg.type;
							var data = msg.data;
							// console.log("Message-->"+type);
							// console.log("Messassssge-->"+JSON.stringify(msg.data));

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
									// console.log("SOCKET_KEEPALIVE");
								break;

								case "SOCKET_MESSAGE":
									console.log("SOCKET_MESSAGE");
									onSocketMessage(data);
								break;
							}
						}

						function onSocketMessage(payload){
							var data = payload.data;
							var users = data.users;
							populateTable(users);
						
						}
						
						function populateTable(data){
							const tableContainer = document.getElementById("tableContainer");
							tableContainer.innerHTML = "";

							const table = document.createElement("table");
							table.border = "1";
							table.style.width = "100%";
							table.style.borderCollapse = "collapse";
							table.cellPadding = "6";
							table.cellSpacing = "0";

							const columns = ["wsUUID", "userID", "data"];

							const thead = document.createElement("thead");
							const headerRow = document.createElement("tr");

							columns.forEach(col => {
								const th = document.createElement("th");
								th.textContent = col;
								headerRow.appendChild(th);
							});

							thead.appendChild(headerRow);
							table.appendChild(thead);

							const tbody = document.createElement("tbody");

							Object.entries(data).forEach(([key, value]) => {
								const row = document.createElement("tr");

								columns.forEach(col => {
									const td = document.createElement("td");
									if (col === "data" && typeof value[col] === "object" && value[col] !== null) {
										td.textContent = JSON.stringify(value[col]);
									} else {
										td.textContent = value[col] ?? "";
									}
									row.appendChild(td);
								});

								tbody.appendChild(row);
							});

							table.appendChild(tbody);
							tableContainer.appendChild(table);
						}

						

						function addCanvas(){
							canvas = document.getElementById("c");
							canvas.style.width = "100%";

        				 	ctx = canvas.getContext("2d");

							ctx.save();
							ctx.fillStyle = "#f0f0f0";
							ctx.fillRect(0, 0, canvas.width, canvas.height);
							ctx.restore();

							window.addEventListener("resize", () => {
								resizeCanvasToDisplaySize();
							});

							canvas.addEventListener("mousemove", (event) => {
								const rect = canvas.getBoundingClientRect();

								const xCss = event.clientX - rect.left;
								const yCss = event.clientY - rect.top;

								// Convert CSS pixels -> canvas pixels
								const x = xCss * (canvas.width / rect.width);
								const y = yCss * (canvas.height / rect.height);

								sendMousePosData(x, y);
							});
						}
							
						function resizeCanvasToDisplaySize() {
							const dpr = window.devicePixelRatio || 1;
							const rect = canvas.getBoundingClientRect();

							canvas.width  = Math.round(rect.width  * dpr);
							canvas.height = Math.round(rect.height * dpr);

							// So draw calls can use CSS pixels if you want:
							ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
						}

						function drawDot(x, y, r = 4, color = "red") {
							console.log(x);
							ctx.beginPath();
							ctx.fillStyle = color;
							ctx.arc(x, y, r, 0, Math.PI * 2);
							ctx.fill();
						}
						function clearDots() {
							ctx.clearRect(0, 0, canvas.width, canvas.height);
						}

						function sendMousePosData(mouseX, mouseY){
							 var data = {
								mouseX: mouseX,
								mouseY: mouseY
							};

							
							frameMessaging.sendGlobalMessage(data);
						}

						function updateCanvasFromData(users){
						
							Object.values(users).forEach(user => {
								if (user.globalData.data != null) {								
									var mx = user.globalData.data.mouseX;
									var my = user.globalData.data.mouseY;

									console.log(my);
									drawDot(mx, my, 2, colorFromUUID(user.wsUUID));
								}
							});
						}

						function colorFromUUID(uuid) {
							let hash = 0;

							for (let i = 0; i < uuid.length; i++) {
								hash = uuid.charCodeAt(i) + ((hash << 5) - hash);
								hash |= 0; // force 32-bit
							}

							const hue = Math.abs(hash) % 360;
							return "hsl("+hue+", 70%, 50%)";
						}
						
						window.onload = function () {
							start();
						};
					</script>
				</head>
				<body>
					<div id="tableContainer"></div>
					<div id="canvasContainer">
						<canvas id="c"></canvas>
					</div>
				</body>
			</html>
		';
	}
}
