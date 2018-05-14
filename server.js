var net = require('net');
var ws = require('websocket');

var client = net.createConnection({ port: 8080 }, () => {
    // 'connect' listener
    console.log('connected to server!');
  });
  client.on('data', function(data){
      console.log(data.toString('utf8'));
  })
  client.write('read\n');
  client.write('inc\n');
  client.write('read\n');
  client.write('inc\n');

var server = ws.server;

