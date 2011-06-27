# A configuration file specific to the site mattiasgeniar.be
# Based on Wordpress (urgh, cookie nightmare)

# Either the admin pages or the login
if (req.url ~ "/wp-(login|admin)") {
        # Don't cache, pass to backend
        return (pass);
}

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

# Uncomment this to trigger the vcl_error() subroutine, which will HTML output you some variables
#error 601;

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
