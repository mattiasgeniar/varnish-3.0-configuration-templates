# Default backend definition.  Set this to point to your content
# server.
backend default {
	# I have Virtual Hosts that only listen to the Public IP
	# so no 127.0.0.1 for me
	# Backend is running on port 81
	.host = "193.239.210.183";
   	.port = "81";
	.first_byte_timeout = 300s;
}

acl purge {
	# For now, I'll only allow purges coming from localhost
	"127.0.0.1";
	"localhost";
}

# Handle the HTTP request received by the client 
sub vcl_recv {
	if (req.restarts == 0) {
 		if (req.http.X-Forwarded-For) {
 	    		set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
	 	} else {
			set req.http.X-Forwarded-For = client.ip;
	 	}
   	}

	# Normalize the header, remove the port (in case you're testing this on various TCP ports)
	set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");

	# Allow purging
	if (req.request == "PURGE") {
		if (!client.ip ~ purge) {
			# Not from an allowed IP? Then die with an error.
			error 405 "This IP is not allowed to send PURGE requests.";
		}
	
		# If you got this stage (and didn't error out above), do a cache-lookup
		# That will force entry into vcl_hit() or vcl_miss() below and purge the actual cache
		return (lookup);
	}

	# Only deal with "normal" types
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

	# Some generic URL manipulation, useful for all templates that follow
	# First remove the Google Analytics added parameters, useless for our backend
	if(req.url ~ "(\?|&)(utm_source|utm_medium|utm_campaign|gclid|cx|ie|cof|siteurl)=") {
		set req.url = regsuball(req.url, "&(utm_source|utm_medium|utm_campaign|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)", "");
		set req.url = regsuball(req.url, "\?(utm_source|utm_medium|utm_campaign|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)", "?");
		set req.url = regsub(req.url, "\?&", "?");
		set req.url = regsub(req.url, "\?$", "");
	}

	# Some generic cookie manipulation, useful for all templates that follow
	# Remove the "has_js" cookie
	set req.http.Cookie = regsuball(req.http.Cookie, "has_js=[^;]+(; )?", "");
	# Remove any Google Analytics based cookies
	set req.http.Cookie = regsuball(req.http.Cookie, "__utm.=[^;]+(; )?", "");
	# Remove the Quant Capital cookies (added by some plugin, all __qca)
	set req.http.Cookie = regsuball(req.http.Cookie, "__qc.=[^;]+(; )?", "");

	# Are there cookies left with only spaces or that are empty?
	if (req.http.cookie ~ "^ *$") {
		unset req.http.cookie;
	}

	# Normalize Accept-Encoding header
	# straight from the manual: https://www.varnish-cache.org/docs/3.0/tutorial/vary.html
	if (req.http.Accept-Encoding) {
		if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
			# No point in compressing these
			remove req.http.Accept-Encoding;
		} elsif (req.http.Accept-Encoding ~ "gzip") {
			set req.http.Accept-Encoding = "gzip";
		} elsif (req.http.Accept-Encoding ~ "deflate") {
			set req.http.Accept-Encoding = "deflate";
		} else {
			# unkown algorithm
			remove req.http.Accept-Encoding;
		}
	}

	# Include the correct Virtual Host configuration file
	if (req.http.Host == "mattiasgeniar.be" || req.http.Host == "geniar.be" || req.http.host == "minimatti.be") {
		# Redirect the user if it's not on the "real" domain name (a 301 permanent redirect, SEO)
		if (req.http.Host != "mattiasgeniar.be") {
			error 701 "mattiasgeniar.be";
		}

		# A site-specific VCL for the vcl-receive
		include "/usr/local/etc/varnish/conf.d/mattiasgeniar.be-receive.vcl";

		# The Wordpress-specific VCL
		include "/usr/local/etc/varnish/conf.d/_wordpress-receive.vcl";
		
	} elseif (req.http.Host ~ "(www\.)?buyzegemhof.be") {
		# Redirect the user if it's not on the "real" domain
		if (req.http.Host != "www.buyzegemhof.be") {
			error 701 "www.buyzegemhof.be";
		}

		# A site-specific VCL for the vcl-receive
		include "/usr/local/etc/varnish/conf.d/buyzegemhof.be-receive.vcl";

		# The wordpress-specific VCL
		include "/usr/local/etc/varnish/conf.d/_wordpress-receive.vcl";

	} elseif (req.http.Host ~ "drupal.mojah.be") {
		# A site-specific VCL for the vcl-receive
		include "/usr/local/etc/varnish/conf.d/drupal.mojah.be-receive.vcl";

		# The Drupal 7-specific VCL
		include "/usr/local/etc/varnish/conf.d/_drupal_7-receive.vcl";

	} elseif (req.http.Host ~ "forkcms.mojah.be") {
		# A site-specific VCL for the vcl-receive
		include "/usr/local/etc/varnish/conf.d/forkcms.mojah.be-receive.vcl";

		# The Drupal 7-specific VCL
		include "/usr/local/etc/varnish/conf.d/_forkcms-receive.vcl";

	} elseif (req.http.Host == "pwgen.mattiasgeniar.be") {
		return (pass);
	} elseif (req.http.Host == "dev.mozbx.net") {
		# Don't interfere with my devving
		return (pass);
	} else {
		# Something not specified? Pass, I probably don't want it cached.
		return (pass);
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

	set bereq.http.Connection = "Close";
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
	# Allow purges
	if (req.request == "PURGE") {
		purge;
		error 200 "Purged.";
	}

	return (deliver);
}
 
sub vcl_miss {
	# Allow purges
	if (req.request == "PURGE") {
		purge;
		error 200 "URL Purged.";
	}
        
	return (fetch);
}

# Handle the HTTP request coming from our backend 
sub vcl_fetch {
	# I can use direct matching on the host, since I normalized the host header in the VCL Receive
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

	} elseif (req.http.Host == "drupal.mojah.be") {
		# A host specific VCL
		include "/usr/local/etc/varnish/conf.d/drupal.mojah.be-fetch.vcl";
		
		# Include the Drupal 7 specific VCL
		include "/usr/local/etc/varnish/conf.d/_drupal_7-fetch.vcl";

	} elseif (req.http.Host == "forkcms.mojah.be") {
		# A host specific VCL
		include "/usr/local/etc/varnish/conf.d/forkcms.mojah.be-fetch.vcl";

		# Include the Fork CMS specific VCL
		include "/usr/local/etc/varnish/conf.d/_forkcms-fetch.vcl";
	}

	# Temporarily removed
	#if (beresp.ttl <= 0s || beresp.http.Set-Cookie || beresp.http.Vary == "*") {
	#	set beresp.ttl = 120s;
	#	return (hit_for_pass);
	#}

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
	if (obj.status == 700) {
		# Include a general error message handler for debugging purposes
		include "/usr/local/etc/varnish/conf.d/_error.vcl";

	} elseif (obj.status == 701) {
		# Redirect error handler
		set obj.http.Location = "http://" + obj.response + req.url;
		# Change this to 302 if you want temporary redirects
		set obj.status = 301;
		return (deliver);
	}

   	return (deliver);
}
 
sub vcl_init {
 	return (ok);
}
 
sub vcl_fini {
 	return (ok);
}
