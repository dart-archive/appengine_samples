Dart App Engine samples
=======================

This repository contains a set of samples for Dart running on App Engine.

Simple request response sample
------------------------------
This sample shows the basic request handling. Start it locally using:

    $ gcloud app run <path to app.yaml>

Navigate to one of the following URLs

    http://localhost:8080
    http://localhost:8080/_utils/headers
    http://localhost:8080/_utils/environment

Memcache sample
---------------
This sample shows use of the Memcache API. Start it locally using:

    $ gcloud app run <path to app.yaml> --api-host 0.0.0.0

Depending on the setup of the machine this is running on the address `0.0.0.0`
might need to be replaced with the actual IP address of a local interface. 

Navigate to:

    http://localhost:8080

Cloud datastore sample
----------------------
This sample shows use of the Cloud Datastore API. Start it locally using

    $ gcloud app run <path to app.yaml> --api-host 0.0.0.0

Depending on the setup of the machine this is running on the address `0.0.0.0`
might need to be replaced with the actual IP address of a local interface. 

Navigate to:

    http://localhost:8080
