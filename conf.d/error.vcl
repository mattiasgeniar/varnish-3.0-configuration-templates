# The vcl_error() procedure
set obj.http.Content-Type = "text/html; charset=utf-8";
set obj.http.Retry-After = "5";

synthetic {"
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>"} + obj.status + " " + obj.response + {"</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="Backend Error page">
        <meta name="author" content="Pascal A.">
        <meta name="generator" content="vim">
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
        <!-- Le styles -->
        <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.0.4/css/bootstrap.css" rel="stylesheet">
        <style>
            body {
                padding-top: 60px; /* 60px to make the container go all the way to the bottom of the topbar */
            }
        </style>
        <link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.0.4/css/bootstrap-responsive.css" rel="stylesheet">
        <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
        <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
    </head>
    <body>
        <div class="container">
            <h1>Error "} + obj.status + " " + obj.response + {"</h1>
            <div class="alert alert-error"><i class="icon-warning-sign"></i> D&eacute;sol&eacute; mais la page ne peut etre charg&eacute; correctement. <i class="icon-warning-sign"></i></div>
            <div class="alert alert-error"><i class="icon-warning-sign"></i> We're very sorry, but the page could not be loaded properly. <i class="icon-warning-sign"></i></div>
            <blockquote>Toutes nos escuses, Cela va etre fix&eacute; rapidement.<br \>
                This should be fixed very soon, and we apologize for any inconvenience
            </blockquote>

            <hr \>
            <h2>Debug Informations</h2>
            <table class="table table-striped table-bordered table-condensed"><caption>Varnish Variables:</caption>
                <tr>
                    <th>Variable</th>
                    <th>Value</th>
                </tr>
                <tr>
                    <td colspan="2">General</td>
                </tr>
                <tr>
                    <td width="20%">XID</td>
                    <td>"} + req.xid + {"</td>
                </tr>
                <tr>
                    <td>Time</td>
                    <td>"} + now + {"</td>
                </tr>
                <tr>
                    <td colspan="2">Request</td>
                </tr>
                <tr>
                    <td>HTTP host</td>
                    <td>"} + req.http.Host + {"</td>
                </tr>
                <tr>
                    <td>Request type</td>
                    <td>"} + req.request + {"</td>
                </tr>
                <tr>
                    <td>HTTP Protocol version</td>
                    <td>"} + req.proto + {"</td>
                </tr>
                <tr>
                    <td>URL</td>
                    <td>"} + req.url + {"</td>
                </tr>
                <tr>
                    <td>Cookies</td>
                    <td>"} + regsuball(req.http.cookie, "; ", "<br />") + {"</td>
                </tr>
                <tr>
                    <td>Accept-Encoding</td>
                    <td>"} + req.http.Accept-Encoding + {"</td>
                </tr>
                <tr>
                    <td>Cache-Control</td>
                    <td>"} + req.http.Cache-Control + {"</td>
                </tr>
                <tr>
                    <td>HTTP header</td>
                    <td>"} + req.http.header + {"</td>
                </tr>
                <tr>
                    <td>GZIP supported</td>
                    <td>"} + req.can_gzip + {"</td>
                </tr>
                <tr>
                    <td>Backend</td>
                    <td>"} + req.backend + {"</td>
                </tr>
                <tr>
                    <td colspan="2">Server</td>
                </tr>
                <tr>
                    <td>Identity</td>
                    <td>"} + server.identity + {"</td>
                </tr>
                <tr>
                    <td>IP:port</td>
                    <td>"} + server.ip + {":"} + server.port + {"</td>
                </tr>
                <tr>
                    <td colspan="2">Client</td>
                </tr>
                <tr>
                    <td>IP</td>
                    <td>"} + client.ip + {"</td>
                </tr>
            </table>
        </div>
    </div>
    <footer class="container">
        <center>
            <p>Error page</p>
        </center>
    </footer>
</body>
</html>
"};
