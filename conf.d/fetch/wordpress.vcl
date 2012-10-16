# The vcl_fetch routine, when the request is fetched from the backend

# For static content related to the theme, strip all backend cookies
if (req.url ~ "\.(html|css|js|png|gif|jp(e?)g)") {
    unset beresp.http.cookie;
    set beresp.ttl = 1d;
} else {
    # A TTL of 30 minutes
    set beresp.ttl = 1h;
}
