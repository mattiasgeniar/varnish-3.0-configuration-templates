## Varnish Configuration Templates (boilerplate)

### 🚀 Need help implementing Varnish?

I'm available [for consultancy](https://ma.ttias.be/consultancy/) if you're struggling with implementing Varnish and speeding up your site. Don't be afraid to [reach out!](https://ma.ttias.be/consultancy/)

### Warning: Varnish 3 is [end-of-life](https://ma.ttias.be/varnish-cache-3-0-is-end-of-life/)

You can still use Varnish 3 of course, but there will be no more security or bug fixes to the Varnish 3.x release. It's probably wise to focus your Varnish adventures on the new [varnish 4 VCL config template](https://ma.ttias.be/varnish-4-0-0-released-together-with-configuration-templates/).


### Installation

You can use the configuration templates found in this repository to quickly get started with a complete Varnish configuration that offers support for most functionality. Start of by looking into "production.vcl" and taking the bits you need, copy it to your own default.vcl.

### What is it?

A set of configuration samples used for Varnish 3.0. This includes templates for:
* Wordpress
* Drupal (works decently for Drupal 7, depends on your addons obviously)
* Joomla (WIP)
* Fork CMS
* OpenPhoto

And various configuration for:

* Server-side URL rewriting
* Clean error pages for debugging
* Virtual Host implementations
* Various header normalizations
* Cookie manipulations
* 301/302 redirects from within Varnish

### Common troubleshooting

Common list of errors and their fixes:

* [FetchError http first read error: -1 11 (Resource temporarily unavailable)](https://ma.ttias.be/varnish-fetcherror-http-first-read-error-1-11-resource-temporarily-unavailable/)
* [FetchError: straight insufficient bytes](https://ma.ttias.be/varnish-fetcherror-straight-insufficient-bytes/)
* [FetchError: Gunzip+ESI Failed at the very end](https://ma.ttias.be/varnish-fetcherror-testgunzip-gunzip-esi-failed-very-end/)

Basic troubleshooting:

* [Test if your Varnish VCL compiles and Varnish starts](https://ma.ttias.be/varnish-running-in-foreground-but-fails-to-run-as-servicedaemon/)
* [See which cookies are being stripped in your VCL](https://ma.ttias.be/varnish-tip-see-cookies-stripped-vcl/)
* [Reload Varnish VCL without losing cache data](https://ma.ttias.be/reload-varnish-vcl-without-losing-cache-data/)
* [Combine Apache'S HTTP authentication with Varnish IP whitelisting](https://ma.ttias.be/apache-http-authentication-with-x-forwarded-for-ip-whitelisting-in-varnish/)

[Click here for a Varnish 4 VCL config template](https://github.com/mattiasgeniar/varnish-4.0-configuration-templates)

[Click here for a Varnish 5 VCL config template](https://github.com/mattiasgeniar/varnish-5.0-configuration-templates)
