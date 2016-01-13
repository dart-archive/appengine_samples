Demonstrates JSON communication using a shared data model with Dart on the
client and server.

To run the sample locally:

    $ pub build web
    $ dev_appserver.py --custom_entrypoint "dart bin/server.dart {port}" app.yaml

Navigate to the following URL:

    http://localhost:8080
