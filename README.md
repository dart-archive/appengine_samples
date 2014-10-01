Dart App Engine samples
=======================

This repository contains a set of samples for Dart running on App Engine.

Before running a sample make sure to execute

    pub get

inside that sample directory to have all the dependent packages available.

Simple request response sample
------------------------------
This sample shows the basic request handling. Start it locally using:

    $ gcloud preview app run <path to app.yaml>

Navigate to one of the following URLs:

    http://localhost:8080
    http://localhost:8080/_utils/headers
    http://localhost:8080/_utils/environment
    http://localhost:8080/_utils/version

Memcache sample
---------------
This sample shows use of the Memcache API. Start it locally using:

    $ gcloud preview app run <path to app.yaml>

Depending on the setup of the machine this is running on the address `0.0.0.0`
might need to be replaced with the actual IP address of a local interface. 

Navigate to:

    http://localhost:8080

Cloud datastore sample
----------------------
This sample shows use of the Cloud Datastore API. Start it locally using

    $ gcloud preview app run <path to app.yaml>

Depending on the setup of the machine this is running on the address `0.0.0.0`
might need to be replaced with the actual IP address of a local interface. 

Navigate to:

    http://localhost:8080

Cloud SQL sample
----------------------
This sample shows use of the usage of Cloud SQL with Dart. First the setup
instructions in cloud_sql_sample/README.md must be followed. Afterwards the
application can be started using

    $ gcloud preview app run <path to app.yaml>

Navigate to:

    http://localhost:8080


Modules sample
--------------
This sample shows use of modules and the modules API. It has three modules,
two Dart modules and one Python module. The Python module is not using Managed
VMs.

Start it locally using

    $ cd modules_sample
    $ gcloud preview app run dispatch.yaml default/app.yaml module1/module1.yaml module2/module2.yaml

Navigate to one of the following URLs:

    http://localhost:8080
    http://localhost:8080/module1/
    http://localhost:8080/module2/

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

With `pub serve` running start the development server with option
`--dart-pub-serve` pointing to the `pub serve` process.

    $ cd dart_client_sample
    $ gcloud preview app run app.yaml --dart-pub-serve 192.168.59.3:7777

Navigate to the following URL:

    http://localhost:8080

When this application is deployed `pub build` will run to create a static
version of the output from the Dart transformers. This requires the `pub`
command to be available. If `pub` is not available via the PATH environment
variable the option `--dart-sdk-path` and be used to point `gcloud` to it.

    $ gcloud preview app deploy app.yaml --dart-sdk-path <path to Dart SDK>
