These examples show how to build apps with
[Dart for Google AppEngine Managed VMs][cloud].

This repository contains the following set of samples:
  * **clientserver**: Simple client/server app
  * **cloud_datastore**: Use [Google Cloud Datastore][datastore]
  * **cloud_sql**: Use [Google Cloud SQL][sql]
  * **dart_client**: Develop both, client and server, in Dart
  * **hello_world**: A simple hello world app
  * **memcache**: Use the memcache API
  * **modules**: Separate an application into several modules
  * **simple_request_response**: Access environment/version/modules

To get started, try out the [helloworld] sample app.

Note: Before running a sample make sure to execute

    $ pub get

inside that sample directory to have all the dependent packages available. For
the `modules_sample`, `pub get` must be executed inside all Dart module
directories.

[cloud]: https://www.dartlang.org/cloud/
[datastore]: https://cloud.google.com/datastore/docs
[helloworld]: https://github.com/dart-lang/appengine_samples/tree/master/helloworld
[sql]: https://cloud.google.com/sql/docs
