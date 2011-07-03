# A configuration file specific for Drupal 7

# Either the admin pages or the login
if (req.url ~ "/admin/?") {
        # Don't cache, pass to backend
        return (pass);
}

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

# Static content unique to the theme can be cached (so no user uploaded images)
if (req.url ~ "/themes/" && req.url ~ "\.(css|js|png|gif|jp(e)?g)") {
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

# Don't cache the install, update or cron files in Drupal
if (req.url ~ "install\.php|update\.php|cron\.php") {
	return (pass);
}

# Uncomment this to trigger the vcl_error() subroutine, which will HTML output you some variables (HTTP 700 = pretty debug)
#error 700;

# Anything else left?
if (!req.http.cookie) {
        unset req.http.cookie;
}

# Try a cache-lookup
return (lookup);
