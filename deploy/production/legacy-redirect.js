const http = require('node:http');
const origin = 'https://hris.mdmcorp.co.id';
http.createServer((request, response) => {
  const path = request.url?.startsWith('/') ? request.url : '/';
  response.writeHead(308, {Location: origin + path, 'Cache-Control': 'no-store'});
  response.end();
}).listen(3000, '0.0.0.0');
