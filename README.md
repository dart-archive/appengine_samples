Dart App Engine samples
=======================

This repository contains the following set of samples for Dart running on App
Engine:
  * cloud_datastore_sample: shows how to use the datastore API
  * cloud_sql_sample: shows how to use CloudSQL
  * dart_client_sample: shows how to develop both, client and server, in Dart
  * memcache_sample: shows how to use the memcache API
  * modules_sample: shows how to separate an application into several modules
  * simple_request_response_sample: shows a simple hello world app

Before running a sample make sure to execute

    $ pub get

inside that sample directory to have all the dependent packages available. For
the `modules_sample`, `pub get` must be executed inside all Dart module
directories.
