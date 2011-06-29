# The vcl_error() procedure
set obj.http.Content-Type = "text/html; charset=utf-8";
set obj.http.Retry-After = "5";

# A readable error page (useful when debugging)
synthetic {"
 <?xml version="1.0" encoding="utf-8"?>
 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
 <html>
   <head>
        <title>"} + obj.status + " " + obj.response + {"</title>
        <style>
                body {
                        font-family: Verdana;
                        font-size: 12px;
                }

                table {
                        border: 0px;
                }

                th {
                        font-size: 16px;
                        font-weight: bold;
                        text-align: left;
                }

                td {
                        vertical-align: top;
                        border-style: dashed;
                        border-color: gray;
                        padding: 3px;
                        border-width: 1px;

                }

                .overflow_div {
                        width: 950px;
                        overflow: auto;
                }

		.subtitle {
			font-size: 14px;
			background-color: #E0F8F7;
		}
        </style>

   </head>

   <body>
        <h1>Error "} + obj.status + " " + obj.response + {"</h1>
        <p>"} + obj.response + {"</p>
        <h3>Varnish Variables:</h3>
        <div class="overflow_div">
           <table width="950px" cellspacing="4" cellpadding="2">
                <tr>
                        <th>Variable</th>
                        <th>Value</th>
                </tr>
		<tr>
			<td colspan="2" class="subtitle">General</td>
		</tr>
                <tr>
                        <td width="20%">XID</td>
                        <td>"} + req.xid + {"</td>
                </tr>
		<tr>
			<td>Time</td>
			<td>"} + now + {"</td>
		</tr>
		<tr>
			<td colspan="2" class="subtitle">Request</td>
		</tr>
                <tr>
                        <td>HTTP host</td>
                        <td>"} + req.http.Host + {"</td>
                </tr>
		<tr>
			<td>Request type</td>
			<td>"} + req.request + {"</td>
		</tr>
		<tr>
                        <td>HTTP Protocol version</td>
                        <td>"} + req.proto + {"</td>
                </tr>
		<tr>
                        <td>URL</td>
                        <td>"} + req.url + {"</td>
                </tr>
                <tr>
			<td>Cookies</td>
			<td>"} + regsuball(req.http.cookie, "; ", "<br />") + {"</td>
		</tr>
		<tr>
			<td>Accept-Encoding</td>
			<td>"} + req.http.Accept-Encoding + {"</td>
		</tr>
		<tr>
			<td>Cache-Control</td>
			<td>"} + req.http.Cache-Control + {"</td>
		</tr>
		<tr>
                        <td>HTTP header</td>
                        <td>"} + req.http.header + {"</td>
                </tr>
		<tr>
                        <td>GZIP supported</td>
                        <td>"} + req.can_gzip + {"</td>
                </tr>
		<tr>
			<td>Backend</td>
			<td>"} + req.backend + {"</td>
		</tr>
		<tr>
			<td colspan="2" class="subtitle">Server</td>
		</tr>
		<tr>
			<td>Identity</td>
			<td>"} + server.identity + {"</td>
		</tr>
		<tr>
			<td>IP:port</td>
			<td>"} + server.ip + {":"} + server.port + {"</td>
		</tr>
		<tr>
			<td colspan="2" class="subtitle">Client</td>
		</tr>
		<tr>
			<td>IP</td>
			<td>"} + client.ip + {"</td>
		</tr>
           </table>
        </div>

        <p>Varnish Error page by <a href="http://mattiasgeniar.be">Mattias Geniar</a>.</p>
   </body>

 </html>
"};
