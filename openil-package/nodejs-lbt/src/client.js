/* vim: set expandtab tabstop=4 shiftwidth=4: */

var btnSave = document.getElementById("btnSave");
var btnStartStop = document.getElementById("btnStartStop");

var serverState = {
    running: false,
    flows: {
        iperf: [],
        ping: [],
    }
};

/* Type of e is InputEvent.
 * Type of e.target is HTMLTableCellElement. */
function changeFlow(classes, text) {
    if (classes.contains("source")) {
        this.sourceText = text;
    } else if (classes.contains("destination")) {
        this.destinationText = text;
    } else if (classes.contains("port")) {
        this.port = text;
    } else if (classes.contains("transport")) {
        this.transport = text;
    } else if (classes.contains("bandwidth")) {
        this.bandwidth = text;
    } else if (classes.contains("label")) {
        this.label = text;
    } else if (classes.contains("flow-enabled")) {
        this.enabled = text;
    } else if (classes.contains("interval-type")) {
        this.intervalType = text;
    } else if (classes.contains("interval-ms")) {
        this.intervalMS = text;
    } else if (classes.contains("packet-size")) {
        this.packetSize = text;
    } else {
        console.log("changeFlow failed: classes %s, text %s",
                    classes, text);
        return;
    }
}

function addFlow(flowType) {
    switch (flowType) {
    case "iperf":
        this.push({
            sourceText: "user@hostname:port",
            destinationText: "user@hostname:port",
            port: "n/a",
            transport: "tcp",
            bandwidth: "n/a",
            label: "n/a",
            enabled: false
        });
        break;
    case "ping":
        this.push({
            sourceText: "user@hostname:port",
            destinationText: "user@hostname:port",
            intervalType: "adaptive",
            intervalMS: "n/a",
            packetSize: "64",
            label: "n/a",
            enabled: false
        });
        break;
    default:
        console.log("Invalid selection " + flowType);
        return;
    }
}

function removeFlow(indexToRemove) {
    if (indexToRemove < 0 || indexToRemove >= this.length) {
        window.alert("cannot remove index " + indexToRemove +
                     " from flow array");
        return;
    }
    this.splice(indexToRemove, 1);
}

function populateRow(flowType, flow) {
    var inputEditable = serverState.running ? " " : " contenteditable ";
    var inputDisabled = serverState.running ? ' disabled' : '';
    var index = ' index="' + (this.rowIndex - 1) + '"';

    /* we use the "editable|checkbox|dropdown" class to put input event listeners,
     * and the other classes to easily discern in the common
     * listener which field was changed */
    var flowEnabled     = '<td> <input type="checkbox" class="checkbox flow-enabled"' +
                           index + (flow.enabled ? ' checked' : '') + inputDisabled + '></td>';
    var label           = '<td ' + index + inputEditable + ' class="editable label">' + flow.label + '</td>';
    var sourceText      = '<td ' + index + inputEditable + ' class="editable source">' + flow.sourceText + '</td>';
    var destinationText = '<td ' + index + inputEditable + ' class="editable destination">' + flow.destinationText + '</td>';
    var btnRemove       = '<td> <button type="button" ' + inputDisabled + index +
                          'class="btnRemove">-</button> </td>';
    switch (flowType) {
    case "iperf":
        var port = '<td ' + index + inputEditable + ' class="editable port">' + flow.port + '</td>';
        var transport = '<td>' +
            '<select ' + index + inputDisabled + ' class="dropdown transport" >' +
            '<option value="udp" ' + ((flow.transport == "udp") ? "selected" : "") + '>UDP</option>' +
            '<option value="tcp" ' + ((flow.transport == "tcp") ? "selected" : "") + '>TCP</option>' +
            '</select>' +
            '</td>';
        var bandwidth = '<td ' + index + inputEditable + ' class="editable bandwidth">' + flow.bandwidth + '</td>';
        this.innerHTML = flowEnabled + label + sourceText + destinationText + port + transport + bandwidth + btnRemove;
        break;
    case "ping":
        var intervalType = '<td>' +
            '<select ' + index + inputDisabled + ' class="dropdown interval-type" >' +
            '<option value="periodic" ' + ((flow.intervalType == "periodic") ? "selected" : "") + '>Periodic</option>' +
            '<option value="adaptive" ' + ((flow.intervalType == "adaptive") ? "selected" : "") + '>Adaptive</option>' +
            '</select>' +
            '</td>';
        var intervalMS = '<td ' + index + inputEditable + ' class="editable interval-ms">' + flow.intervalMS + '</td>';
        var packetSize = '<td ' + index + inputEditable + ' class="editable packet-size">' + flow.packetSize + '</td>';
        this.innerHTML = flowEnabled + label + sourceText + destinationText + intervalType + intervalMS + packetSize + btnRemove;
        break;
    default:
        throw new Error("populateRow: invalid flow type " + flowType);
    }
}

function displayServerState() {
    ["iperf", "ping"].forEach((flowType) => {
        var table = document.getElementById(flowType + "-table");
        var tbody = table.getElementsByTagName('tbody')[0];
        var flows = (flowType == "iperf") ? serverState.flows.iperf : serverState.flows.ping;

        tbody.innerHTML = "";
        flows.forEach((f) => {
            var newRow = tbody.insertRow(tbody.rows.length);
            populateRow.call(newRow, flowType, f);
        });
        [].forEach.call(table.getElementsByClassName("btnAdd"), (btnAdd) => {
            btnAdd.disabled = serverState.running;
        });
        /* Put listeners again on DOM objects */
        [].forEach.call(table.getElementsByClassName("btnRemove"), (btnRemove) => {
            btnRemove.onclick = () => {
                removeFlow.call(flows, btnRemove.getAttribute("index"));
                displayServerState();
                btnSave.disabled = false;
                btnStartStop.disabled = true;
            };
        });
        ["editable", "dropdown", "checkbox"].forEach((cellType) => {
            [].forEach.call(table.getElementsByClassName(cellType), (cell) => {
                cell.oninput = (event) => {
                    var index = cell.getAttribute("index");
                    var classes = event.target.classList;
                    var text = cellType == "checkbox" ? event.target.checked :
                               cellType == "dropdown" ? event.target.value :
                               event.target.innerText.trim();
                    changeFlow.call(flows[index], classes, text);
                    btnSave.disabled = false;
                    btnStartStop.disabled = true;
                }
            });
        });
    });
    btnStartStop.innerHTML = (serverState.running) ? "Stop traffic" : "Start traffic";
}

function xchgServerState(requestType, path, toSend) {
    return new Promise((resolve, reject) => {
        /* requestType is GET or PUT */
        var xhr = new XMLHttpRequest();
        xhr.open(requestType, path);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onload = function() {
            if (this.status >= 200 && this.status < 300) {
                try {
                    resolve(JSON.parse(this.responseText));
                } catch (e) {
                    reject(e);
                }
            } else {
                reject(new Error(this.status + ": " + this.responseText));
            }
        };
        if (requestType == "PUT") {
            xhr.send(JSON.stringify(toSend));
        } else if (requestType == "GET") {
            xhr.send();
        }
    });
}

function onSSEEvent(event) {
    try {
        if (!["iperf", "ping", "server-err"].includes(event.type)) {
            throw new Error("invalid event type " + event.type);
        }
        var msg = JSON.parse(event.data);
        if (event.type == "server-err") {
            alert("Server error!\n" + msg.stack + "\n");
            console.log(event);
        } else {
            document.getElementById(event.type + "-gnuplot").innerHTML = msg.svg;
        }
    } catch (e) {
        console.log(e.stack);
        alert(e.name + ' while parsing event "' + event.data +
              '" from server: ' + e.message);
    }
}

function initSSE() {
    sseStream = new EventSource("/sse");
    sseStream.onopen = function() {
        console.log("sse :: connection opened");
    };
    sseStream.onerror = function (event) {
        if (event.eventPhase == EventSource.CLOSED) {
            console.log("sse :: server hung up");
            closeSSE();
        } else {
            console.log("sse :: connection error");
            console.log(event);
        }
    };
    sseStream.onmessage = function (event) {
        console.log("sse stream message: " + event.data);
    };
    sseStream.addEventListener("iperf", onSSEEvent);
    sseStream.addEventListener("ping",  onSSEEvent);
    sseStream.addEventListener("server-err", onSSEEvent);
    /* Close the connection when the window is closed */
    window.addEventListener("beforeunload", closeSSE);
}

function closeSSE() {
    if (typeof(sseStream) != "undefined") {
        console.log("sse :: connection closed");
        sseStream.close();
        refresh();
    }
}

function onServerStateChanged(newState) {
    if (typeof (newState.flows) != "undefined") {
        serverState.flows = newState.flows;
    }
    if (typeof (newState.running) != "undefined") {
        if (serverState.running == false && newState.running == true) {
            serverState.running = true;
            initSSE();
        } else if (serverState.running == true && newState.running == false) {
            serverState.running = false;
            closeSSE();
            document.getElementById("iperf-gnuplot").innerHTML = "";
            document.getElementById("ping-gnuplot").innerHTML = "";
        }
    }
    btnSave.disabled = true;
    btnStartStop.disabled = false;
    console.log(serverState);
    displayServerState();
}

function refresh() {
    Promise.all([
        xchgServerState("GET", "/flows"),
        xchgServerState("GET", "/running")
    ])
    .then((array) => {
        try {
            onServerStateChanged({
                flows: parseRecvFlows(array[0].flows),
                running: array[1].running
            });
        } catch (e) {
            console.log(e.stack);
            alert("Error while processing flows from server: " + e);
        };
    })
    .catch((reason) => { console.log(reason); });
};

function parseSentLoginData(string) {
    var loginData = {
        user: "",
        hostname: "",
        port: ""
    };
    var arr = string.split(":");
    if (arr.length == 2) {
        loginData.port = Number(arr[1]);
    } else if (arr.length == 1) {
        loginData.port = 22;
    } else {
        throw new Error("Invalid login format: " + string);
    }
    arr = arr[0].split("@");
    if (arr.length == 2) {
        loginData.user = arr[0];
        loginData.hostname = arr[1];
    } else if (arr.length == 1) {
        loginData.user = "root";
        loginData.hostname = arr[0];
    } else {
        throw new Error("Invalid login format: " + string);
    }
    return loginData;
}

function parseRecvLoginData(loginData) {
    return (loginData.user || "root") + "@" + loginData.hostname + ":" + (loginData.port || "22");
}

function curateFlowsForSend(flows) {
    var newFlows = { iperf: [], ping: [] };
    flows.iperf.forEach((f) => {
        if (!["tcp", "udp"].includes(f.transport)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid transport " + f.transport);
        }
        if (![true, false].includes(f.enabled)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid enabled state " + f.enabled);
        }
        if (f.transport == "udp" && isNaN(f.bandwidth)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid bandwidth limit " + f.bandwidth);
        }
        if (isNaN(f.port)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid port " + f.port);
        }
        newFlows.iperf.push({
            source: parseSentLoginData(f.sourceText),
            destination: parseSentLoginData(f.destinationText),
            port: +f.port,
            transport: f.transport,
            bandwidth: (f.transport == "udp") ? +f.bandwidth : -1,
            enabled: f.enabled,
            label: f.label
        });
    });
    flows.ping.forEach((f) => {
        if (!["adaptive", "periodic"].includes(f.intervalType)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid interval type " + f.intervalType);
        }
        if (f.intervalType == "periodic" && isNaN(f.intervalMS)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid interval period " + f.intervalMS);
        }
        if (isNaN(f.packetSize)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid packet size " + f.packetSize);
        }
        newFlows.ping.push({
            source: parseSentLoginData(f.sourceText),
            destination: parseSentLoginData(f.destinationText),
            intervalType: f.intervalType,
            intervalMS: (f.intervalType == "periodic") ? +f.intervalMS : -1,
            packetSize: f.packetSize,
            enabled: f.enabled,
            label: f.label
        });
    });
    return newFlows;
}

function parseRecvFlows(flows) {
    var newFlows = { iperf: [], ping: [] };
    flows.iperf.forEach((f) => {
        if (!["tcp", "udp"].includes(f.transport)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid transport " + f.transport);
        }
        if (![true, false].includes(f.enabled)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid enabled state " + f.enabled);
        }
        if (f.transport == "udp" && isNaN(f.bandwidth)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid bandwidth limit " + f.bandwidth);
        }
        if (isNaN(f.port)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid port " + f.port);
        }
        newFlows.iperf.push({
            sourceText: parseRecvLoginData(f.source),
            destinationText: parseRecvLoginData(f.destination),
            port: +f.port,
            transport: f.transport,
            bandwidth: (f.transport == "udp") ? +f.bandwidth : "n/a",
            enabled: f.enabled,
            label: f.label
        });
    });
    flows.ping.forEach((f) => {
        if (!["adaptive", "periodic"].includes(f.intervalType)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid interval type " + f.intervalType);
        }
        if (f.intervalType == "periodic" && isNaN(f.intervalMS)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid interval period " + f.intervalMS);
        }
        if (isNaN(f.packetSize)) {
            throw new Error("flow " + JSON.stringify(f) + ": invalid packet size " + f.packetSize);
        }
        newFlows.ping.push({
            sourceText: parseRecvLoginData(f.source),
            destinationText: parseRecvLoginData(f.destination),
            intervalType: f.intervalType,
            intervalMS: (f.intervalType == "periodic") ? +f.intervalMS : "n/a",
            packetSize: f.packetSize,
            enabled: f.enabled,
            label: f.label
        });
    });
    return newFlows;
}

window.onload = () => {
    refresh();
    ["iperf", "ping"].forEach((flowType) => {
        var table = document.getElementById(flowType + "-table");
        [].forEach.call(table.getElementsByClassName("btnAdd"), (btnAdd) => {
            btnAdd.onclick = () => {
                addFlow.call(serverState.flows[flowType], flowType);
                displayServerState();
                btnSave.disabled = false;
                btnStartStop.disabled = true;
            }
        });
    });
    btnSave.onclick = () => {
        try {
            xchgServerState("PUT", "/flows", { flows: curateFlowsForSend(serverState.flows) })
            .then((recvState) => { onServerStateChanged({ flows: parseRecvFlows(recvState.flows)}) })
            .catch((reason) => { console.log(reason); });
        } catch(e) {
            console.log(e.stack);
            alert("Invalid flow configuration: " + e);
        };
    };
    btnStartStop.onclick = () => {
        xchgServerState("PUT", "/running", {
            running: !serverState.running
        })
        .then((state) => { onServerStateChanged({ running: state.running }); })
        .catch((reason) => { console.log(reason); });
    };
}
