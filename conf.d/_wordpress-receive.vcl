# A configuration file specific to Wordpress 3.x

# Either the admin pages or the login
if (req.url ~ "/wp-(login|admin)") {
        # Don't cache, pass to backend
        return (pass);
}

# Remove the "has_js" cookie
set req.http.Cookie = regsuball(req.http.Cookie, "has_js=[^;]+(; )?", "");

# Remove any Google Analytics based cookies
set req.http.Cookie = regsuball(req.http.Cookie, "__utm.=[^;]+(; )?", "");

# Remove the Quant Capital cookies (added by some plugin, all __qca)
set req.http.Cookie = regsuball(req.http.Cookie, "__qc.=[^;]+(; )?", "");

# Remove the wp-settings-1 cookie
set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-1=[^;]+(; )?", "");

# Remove the wp-settings-time-1 cookie
set req.http.Cookie = regsuball(req.http.Cookie, "wp-settings-time-1=[^;]+(; )?", "");

# Remove the wp test cookie
set req.http.Cookie = regsuball(req.http.Cookie, "wordpress_test_cookie=[^;]+(; )?", "");

# Are there cookies left with only spaces or that are empty?
if (req.http.cookie ~ "^ *$") {
        unset req.http.cookie;
}

# Static content unique to the theme can be cached (so no user uploaded images)
# The reason I don't take the wp-content/uploads is because of cache size on bigger blogs
# that would fill up with all those files getting pushed into cache
if (req.url ~ "wp-content/themes/" && req.url ~ "\.(css|js|png|gif|jp(e)?g)") {
	unset req.http.cookie;
}

# Even if no cookies are present, I don't want my "uploads" to be cached due to their potential size
if (req.url ~ "/wp-content/uploads/") {
	return (pass);
}

# Normalize Accept-Encoding header (straight from the manual: https://www.varnish-cache.org/docs/3.0/tutorial/vary.html)
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

# Uncomment this to trigger the vcl_error() subroutine, which will HTML output you some variables (HTTP 700 = pretty debug)
#error 700;

# Check the cookies for wordpress-specific items
if (req.http.Cookie ~ "wordpress_" || req.http.Cookie ~ "comment_") {
        # A wordpress specific cookie has been set
	return (pass);
}

# Anything else left?
if (!req.http.cookie) {
	unset req.http.cookie;
}

# Try a cache-lookup
return (lookup);
