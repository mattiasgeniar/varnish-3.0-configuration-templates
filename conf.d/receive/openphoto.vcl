# Don't cache OpenPhoto Cache
if (req.url ~ "^/assets/cache/") {
    return (pass);
}

# Cache static files
if (req.url ~ "\.(css|eot|gif|ico|jpg|js|png|svg|svgz|ttf|txt|woff)") {
    unset req.http.cookie;
}

# Anything else left?
if (!req.http.cookie) {
    unset req.http.cookie;
}

# Try a cache-lookup
return (lookup);
