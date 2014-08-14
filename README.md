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
