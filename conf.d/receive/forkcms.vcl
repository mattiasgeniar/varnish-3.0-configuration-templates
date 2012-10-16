# A configuration file specific to Fork CMS

# Either the admin pages or the login
if (req.url ~ "(private|backend)") {
    # Don't cache, pass to backend
    return (pass);
}

# Someone placed comments on the site, there are still cookies left
if (req.http.cookie ~ "comment_(website|email|author)") {
    # Don't cache these pages, allow direct request
    return (pass);
}

# If no "comment_" cookies were found, we will simply remove the PHPSESSID 
# If your PHP configuration has a different naming for the PHP Session IDs, change it here
set req.http.Cookie = regsuball(req.http.Cookie, "PHPSESSID=[^;]+(; )?", "");

# Anything else left?
if (!req.http.cookie) {
    unset req.http.cookie;
}

# Try a cache-lookup
return (lookup);
