# A configuration file specific to the site mattiasgeniar.be
# Based on Wordpress (urgh, cookie nightmare)

# Either the admin pages or the login
if (req.url ~ "/wp-(login|admin)") {
	# Don't cache, pass to backend
	return (pass);
}

# Check the cookies for wordpress-specific items
if (req.http.Cookie ~ "wordpress_" || req.http.Cookie ~ "comment_") {
	# A wordpress specific cookie has been set
	return (pass);
}

# Remove any Google Analytics based cookies
set req.http.Cookie = regsuball(req.http.Cookie, "__utm.=[^;]+(; )?", "");

# Are there cookies left with only spaces or that are empty?
if (req.http.cookie ~ "^ *$") {
	remove req.http.cookie;
}

# Anything else left? Strip all cookies and cache it.
unset req.http.Cookie;
return (lookup);
