# Vaalum #

Retrieve input from a Griffin PowerMate under Linux and use this input to control [spotify-connect-web](https://github.com/Fornoth/spotify-connect-web).

*This repository is provided as supplementary material to a [blog post](https://medium.com/@rprimet/un-bouton-de-volume-ab290a4f74ac). It is specific to a use case and will not be maintained. It has no tests and only basic error handling.* 

## Building

The `evdump` and `ledoff` tools require a C99 compiler and the linux headers.

The `vaalum` tool requires ocaml 4.04 or greater, as well as the `lwt`, `cohttp` and `yojson` libraries.

