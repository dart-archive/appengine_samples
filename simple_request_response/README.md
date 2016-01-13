Simple request response sample
------------------------------
This sample shows the basic request handling. Start it locally using:

    $ dev_appserver.py --custom_entrypoint "dart bin/server.dart {port}" app.yaml

Navigate to one of the following URLs:

    http://localhost:8080
    http://localhost:8080/_utils/headers
    http://localhost:8080/_utils/environment
    http://localhost:8080/_utils/version
