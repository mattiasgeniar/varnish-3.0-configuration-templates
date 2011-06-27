# Default backend definition.  Set this to point to your content
# server.
backend default {
	# I have Virtual Hosts that only listen to the Public IP
	# so no 127.0.0.1 for me
	.host = "193.239.210.183";
     	.port = "80";
}

# Handle the HTTP request received by the client 
sub vcl_recv {
	if (req.restarts == 0) {
 		if (req.http.x-forwarded-for) {
 	    		set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
	 	} else {
			set req.http.X-Forwarded-For = client.ip;
	 	}
     	}

	# Normalize the header, remove the port (in case you're testing this on various TCP ports)
	set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");

     	if (req.request != "GET" &&
       		req.request != "HEAD" &&
      	 	req.request != "PUT" &&
       		req.request != "POST" &&
       		req.request != "TRACE" &&
       		req.request != "OPTIONS" &&
      	 	req.request != "DELETE") {
         		/* Non-RFC2616 or CONNECT which is weird. */
         		return (pipe);
     	}

	if (req.request != "GET" && req.request != "HEAD") {
         	# We only deal with GET and HEAD by default
         	return (pass);
     	}

	# Include the correct Virtual Host configuration file
	if (req.http.Host == "mattiasgeniar.be") {
		# A site-specific VCL for the vcl-receive
		include "/usr/local/etc/varnish/conf.d/mattiasgeniar.be-receive.vcl";

		# The Wordpress-specific VCL
		include "/usr/local/etc/varnish/conf.d/_wordpress-receive.vcl";
		
	} elseif (req.http.Host == "buyzegemhof.be") {
		# A site-specific VCL for the vcl-receive
		include "/usr/local/etc/varnish/conf.d/buyzegemhof.be-receive.vcl";

		# The wordpress-specific VCL
		#include "/usr/local/etc/varnish/conf.d/_wordpress-receive.vcl";		
	}

     	if (req.http.Authorization || req.http.Cookie) {
         	# Not cacheable by default
         	return (pass);
     	}

	return (lookup);
}
 
sub vcl_pipe {
     	# Note that only the first request to the backend will have
     	# X-Forwarded-For set.  If you use X-Forwarded-For and want to
     	# have it set for all requests, make sure to have:
     	# set bereq.http.connection = "close";
     	# here.  It is not set by default as it might break some broken web
     	# applications, like IIS with NTLM authentication.
	return (pipe);
}
 
sub vcl_pass {
	return (pass);
}
 
# The data on which the hashing will take place
sub vcl_hash {
     	hash_data(req.url);
     	if (req.http.host) {
         	hash_data(req.http.host);
     	} else {
         	hash_data(server.ip);
     	}

	# If the client supports compression, keep that in a different cache
    	if (req.http.Accept-Encoding) {
        	hash_data(req.http.Accept-Encoding);
	}
     
	return (hash);
}
 
sub vcl_hit {
	return (deliver);
}
 
sub vcl_miss {
	return (fetch);
}

# Handle the HTTP request coming from our backend 
sub vcl_fetch {
     	if (beresp.ttl <= 0s || beresp.http.Set-Cookie || beresp.http.Vary == "*") {
 		set beresp.ttl = 120s;
 		return (hit_for_pass);
     	}

	if (req.http.Host == "mattiasgeniar.be") {
		# A host specific VCL
		include "/usr/local/etc/varnish/conf.d/mattiasgeniar.be-fetch.vcl";

		# Since this is a Wordpress setup, the Wordpress-specific Fetch
		include "/usr/local/etc/varnish/conf.d/_wordpress-fetch.vcl";
	} elseif (req.http.Host == "www.buyzegemhof.be") {
		# A host specific VCL
		include "/usr/local/etc/varnish/conf.d/buyzegemhof.be-fetch.vcl";

		# Since this is a Wordpress setup, the wordpress-specific Fetch
		#include "/usr/local/etc/varnish/conf.d/_wordpress-fetch.vcl";
	}

     	return (deliver);
}
 
# The routine when we deliver the HTTP request to the user
# Last chance to modify headers that are sent to the client
sub vcl_deliver {
	if (obj.hits > 0) { 
		set resp.http.X-Cache = "cached";
	} else {
		set resp.http.x-Cache = "uncached";
	}

	# Remove some headers: PHP version
	unset resp.http.X-Powered-By;
	# Remove some headers: Apache version & OS
	unset resp.http.Server;

	return (deliver);
}
 
sub vcl_error {
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
			<td width="20%">XID</td>
			<td>"} + req.xid + {"</td>
		</tr>
		<tr>
                        <td>HTTP host</td>
                        <td>"} + req.http.Host + {"</td>
                </tr>
		<tr>
                        <td>Cookies</td>
                        <td>"} + regsuball(req.http.cookie, "; ", "<br />") + {"</td>
                </tr>
	   </table>
	</div>

     	<p>Varnish cache server</p>
   </body>
 </html>
 	"};


     	return (deliver);
}
 
sub vcl_init {
 	return (ok);
}
 
sub vcl_fini {
 	return (ok);
}
