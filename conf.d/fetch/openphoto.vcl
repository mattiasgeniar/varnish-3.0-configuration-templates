if (req.url ~ "\.(css|eot|gif|ico|jpg|js|png|svg|svgz|ttf|txt|woff)") {
    unset beresp.http.cookie;
}

# A TTL of 1 day
set beresp.ttl = 86400s;
