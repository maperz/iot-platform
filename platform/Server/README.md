# IoT Server

Hub part of the IoT platform. The hub takes care of connecting devices to clients locally and the server remotely.
Every network will require a single Hub running for multiple devices/sensors/clients on the network.

### Roadmap / Future plans

| Status | Goal                                                   |
| :----: | ------------------------------------------------------ |
|   ✅    | Provide minimal gateway functionality to Hub           |
|   ✅    | Support muliple Hubs connected to Server               |
|   ✅    | Support user authentication to connect to Hub instance |
|   ⬜️    | ...                                                    |

### Running via container

This repository builds ready to use container equipped with all Serverdependencies for both *x86* and *arm* architecture.

- `ghcr.io/maperz/iot-server` for *x86*

- `ghcr.io/maperz/iot-server/arm` for *arm*

To run the servervia docker execute the following command:

```shell
sudo docker run -p 5000:5000 ghcr.io/maperz/iot-server/arm
```



### Build and run

To build and run this project locally make sure that all source files are located locally. Then execute the following command in the Server folder.

``` shell
dotnet restore
dotnet build
```

Or run the project via the following command:

``` shell
dotnet run
```

