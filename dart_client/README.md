Dart web application
--------------------
This sample shows how to have a web application using Dart code served
by App Engine.

To run the sample locally a separate `pub serve` process is required to
handle the Dart transformers involved when building a Dart web application.
The Dart App Engine application is running in the Docker environment and it
will talk to `pub serve`. Therefore `pub serve` must listen on a network that
the Dart App Engine application can also access. For the normal `boot2docker`
setup the host-only network (192.168.59.0/24) is used.

    $ cd dart_client_sample
    $ pub serve --hostname 192.168.59.3 --port 7777 web

With `pub serve` running, app.yaml needs to be modified to tell the dart
application how to contact `pub serve`. This is achieved by adding the following
section to app.yaml:

    env_variables:
      DART_PUB_SERVE: 'http://192.168.59.3:7777'

Then the application can be run locally via

    $ gcloud preview app run app.yaml

Navigate to the following URL:

    http://localhost:8080

`pub build` needs to be called before deploying the application to create a
static version of the output from the Dart transformers. Afterwards the
application can be deployed:

    $ pub build web
    $ gcloud preview app deploy app.yaml

