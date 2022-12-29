
This folder contains 3 examples of using the `openid_client` package with a `keycloak` server:

* `flutter_example` - a flutter example
* `io_example` - a command line example
* `browser_example` - a browser (non-flutter) example

## The keycloak server

The examples use a keycloak server running on `http://localhost:8080/auth/realms/myrealm`. 

The keycloak server can be started by using the `docker-compose.yml` file in the `example/keycloak-docker` folder:

```bash
cd example/keycloak-docker
docker-compose up
```

## flutter_example

This example shows how to use the `openid_client` package with a `keycloak` server in a flutter application. It has been tested on the following platforms:

* Android
* iOS
* Web
* MacOS

The app will show a single *login* button. Once pressed, a browser will be opened and the user will be asked to login or register. After a successful login, the user info will be shown.


## io_example

This example can be run by:

```bash
dart run example/io_example/io_example.dart
```

Once started, a browser will be opened and the user will be asked to login or register. After a successful login, the user info will be printed to the command line.

## browser_example

Run this example by:

```bash
cd example/browser_example
webdev serve web:8888
```

Then open `http://localhost:8888` in a browser. Once the page is loaded, a login button will be shown. Once pressed, a browser will be opened and the user will be asked to login or register. After a successful login, the user info will be shown.



