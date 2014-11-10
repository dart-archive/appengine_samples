This sample shows use of modules and the modules API. It has three modules,
two Dart modules and one Python module. The Python module is not using Managed
VMs.

Start it locally using

    $ gcloud preview app run dispatch.yaml default/app.yaml module-python/module-python.yaml module-dart/module-dart.yaml

Navigate to one of the following URLs:

    http://localhost:8080
    http://localhost:8080/module-python/
    http://localhost:8080/module-dart/
