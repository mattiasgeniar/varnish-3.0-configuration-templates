# A configuration file specific for Drupal 7

# Either the admin pages or the login
if (req.url ~ "/admin/?") {
    # Don't cache, pass to backend
    return (pass);
}

# Static content unique to the theme can be cached (so no user uploaded images)
# Before you blindly enable this, have a read here: http://mattiasgeniar.be/2012/11/28/stop-caching-static-files/
if (req.url ~ "^/themes/" && req.url ~ "\.(css|js|png|gif|jp(e)?g)") {
    unset req.http.cookie;
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
