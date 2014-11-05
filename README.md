Dart App Engine samples
=======================

These examples show how to build apps with Dart for Google AppEngine Managed VMs.

This repository contains the following set of samples:
  * **clientserver**: Shows how to develop a simple client/server app with REST communication
  * **cloud_datastore**: Shows how to use the datastore API
  * **cloud_sql**: Shows how to use CloudSQL
  * **dart_client**: Shows how to develop both, client and server, in Dart
  * **hello_world**: Shows a simple hello world app
  * **memcache**: Shows how to use the memcache API
  * **modules**: Shows how to separate an application into several modules

To get started, try out the [hello_world](https://github.com/dart-lang/appengine_samples/tree/master/hello_world) sample app.

Note: Before running a sample make sure to execute

    $ pub get

inside that sample directory to have all the dependent packages available. For
the `modules_sample`, `pub get` must be executed inside all Dart module
directories.

