# IMPORTANT ANNOUNCEMENT
This package comes as is. Unfortunately we do not have the resources to offer free support, help, or review any PRs. Please feel free to fork or use this package in anyway you like. For paid support options please email us at info@muljin.com.

# msal_guard_widget

MSAL Guard is a highly opinionated implementation of a MSAL protected web application built for use on our client projects.
MSAL Guard consists of splitting applications into public and private sections, each acting as completely seperate mini-applications with no shared routing or services apart from authentication based ones.

MSAL Guard is a companion widget for [MSAL Flutter](https://github.com/Muljin/msal-flutter) and cannot be used without it. Application must be configured to MSAL Flutter, the details of which can be found in its repository.

MSAL Guard is designed only for use against a single audience, using a single client. Other usage is not activity tested nor encouraged.

## Getting Started

To get started, goto the [MSAL Flutter](https://github.com/Muljin/msal-flutter) repository and follow the configuration guade.

Once configured, create a new MsalGuard widget providing your clientid, default scopes used for validating a users authentication status.
Additionally, provide widgets representing the apps authenticated state, unauthenticated state and in progress state.

Additional support and documentation coming soon.