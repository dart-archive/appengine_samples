Dart web application
--------------------
This sample shows how to have a web application using Dart code served
by App Engine.

To run the sample locally a separate `pub serve` process is required to
handle the Dart transformers involved when building a Dart web application.

    $ pub serve --port 7777 web
    Loading source assets...
    Serving dart_client web on http://localhost:7777
    Build completed successfully

Then the application can be run locally via (see also
[package:appengine](https://github.com/dart-lang/appengine/blob/master/README.md))

    $ export GCLOUD_PROJECT=<project-id>
    $ export GCLOUD_KEY=<service-account-key.json>
    $ export DART_PUB_SERVE=http://localhost:7777
    $ dart bin/server.dart

Navigate to the following URL:

    http://localhost:8080

`pub run build_runner build` needs to be called before deploying the 
application to create a static version of the output from the Dart 
transformers. Afterwards the application can be deployed with 
`gcloud app deploy`:

    $ pub run build_runner build
    $ gcloud app deploy app.yaml

