# A configuration file specific to Fork CMS

# Either the admin pages or the login
if (req.url ~ "(private|backend)") {
        # Don't cache, pass to backend
        return (pass);
}

# Remove the "has_js" cookie
set req.http.Cookie = regsuball(req.http.Cookie, "has_js=[^;]+(; )?", "");

# Remove any Google Analytics based cookies
set req.http.Cookie = regsuball(req.http.Cookie, "__utm.=[^;]+(; )?", "");

# Are there cookies left with only spaces or that are empty?
if (req.http.cookie ~ "^ *$") {
        unset req.http.cookie;
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

# Someone placed comments on the site, there are still cookies left
if (req.http.cookie ~ "comment_(website|email|author)") {
	# Don't cache these pages, allow direct request
	return (pass);
}

# If no "comment_" cookies were found, we will simply remove the PHPSESSID 
# If your PHP configuration has a different naming for the PHP Session IDs, change it here
set req.http.Cookie = regsuball(req.http.Cookie, "PHPSESSID=[^;]+(; )?", "");

# Static content gets an additional "m=timestamp" suffix appended to it, which is worthless
if (req.url ~ "\.(css|js)") {
	# Replace the "m=1309719542" with "m=1", so it's unique
	set req.url = regsuball(req.url, "m=([0-9])+", "m=1");
}

# Uncomment this to trigger the vcl_error() subroutine, which will HTML output you some variables (HTTP 700 = pretty debug)
#error 700;

# Anything else left?
if (!req.http.cookie) {
        unset req.http.cookie;
}

# Try a cache-lookup
return (lookup);
