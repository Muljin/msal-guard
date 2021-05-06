## Very Early alpha release
Warning, this package is in very early release and will be subjected to constant breaking changes with no warning.
## [0.0.1-alpha.12]
* more fixes
## [0.0.1-alpha.11]
* bug fix in handling of multiple authorities
## [0.0.1-alpha.10]
* Updated to msalflutter alpha5, and added logic to try to handle multiple authorities for social sign in options.
## [0.0.1-alpha.9]
* bug fixes for override authority not being await and value sent.
## [0.0.1-alpha.8]
* Added login authority override to allow using different policies when working with social login providers
* updated for msal flutter 2.0.0-alpha.4 to support changes
## [0.0.1-alpha.7]
* Defaulting to content-type: application/json
## [0.0.1-alpha.6]
* Moved to sal flutter 2.0.0-alpha.3
## [0.0.1-alpha.5]
* Moved to msal flutter 2.0.0-alpha.2 for iOS support
## [0.0.1-alpha.4]
* bug fix for setting baseurl
## [0.0.1-alpha.3]
* Added apiBase url to msal guard itself to be passed onto AuthenticatedHttp service
## [0.0.1-alpha.2]
* Updated to include base url property on AuthenticatedHttp service and changed parameters for calls to be strings.

## [0.0.1-alpha.1] - Very Early alpha release
First release for the test MSAL Guard library, a companion library to Msal Flutter.
WARNING: This release is mostly for internal testing. This library is NOT to be used in production. It is VERY early alpha and is subject to regular and repeated breaking changes with no warning and limited documentation
* Created first version of msal guard widget
* Created first version of authentication service used to handle logic
* Created first version of authenticated http service used for making authenticated http calls.
