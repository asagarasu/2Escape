var net = require('net');

var client = net.createConnection({ port: 8080 }, () => {
    // 'connect' listener
    console.log('connected to server!');
  });
  client.on('data', function(data){
      console.log(data.toString('utf8'));
  })
  client.write('read');
  client.write('inc');
  client.write('read');
  client.write('inc');