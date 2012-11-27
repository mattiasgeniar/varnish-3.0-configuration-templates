# The vcl_fetch routine, when the request is fetched from the backend

# For static content related to the theme, strip all backend cookies
# Before you blindly enable this, have a read here: http://mattiasgeniar.be/2012/11/28/stop-caching-static-files/
if (req.url ~ "^/themes/" && req.url ~ "\.(css|js|png|gif|jp(e?)g)") {
	unset beresp.http.cookie;
}

# A TTL of 30 minutes
set beresp.ttl = 1800s;
