const ws = require('websocket');
const net = require('net');
var WebSocketServer = ws.server;
const http = require('http');
require('events').EventEmitter.prototype._maxListeners = 100;

var ocamlport = parseInt(process.argv.slice(2)[0]);
var jsport = parseInt(process.argv.slice(2)[1]);
require('dns').lookup(require('os').hostname(), function (err, add, fam) {
    console.log('Your websocket server is created at: ws://'+ add + ":" + jsport);
  })

var server = http.createServer(function(request, response) {});
  server.listen(jsport, function() {
      console.log((new Date()) + " Server is listening on port "
        + jsport);
   });
  
  wsServer = new WebSocketServer({
      httpServer: server
    });
  
  
  var flag = false; 
  
  var clients = []

  var client = net.createConnection({ port: ocamlport }, () => {
    // 'connect' listener
    console.log('connected to server!');
  });
  
  client.on('data', function(data){
      console.log(data.toString('utf8'))
      for(i = 0; i < clients.length; i++)
        clients[i].sendUTF(data.toString('utf8'));
  });
  
  wsServer.on('request', function(request) {
        console.log((new Date()) + ' Connection from origin '
            + request.origin + '. Current number of connections: ' + (clients.length + 1));
  
        var connection = request.accept(null, request.origin);
        clients.push(connection);
        connection.on('message', function(message) {
            client.write(message.utf8Data.concat('\n'));
        });

        connection.on('close', function(connection) {
            var index = clients.indexOf(connection);
            if (index > -1){
                clients.splice(index, 1);
            }
            console.log((new Date()) + ' Connection from origin '
            + request.origin + ' has disconnected. Current number of connections: ' + clients.length);
        });
  });