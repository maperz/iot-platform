# IoT Hub

Hub part of the IoT platform. The hub takes care of connecting devices to clients locally and the server remotely.
Every network will require a single Hub running for multiple devices/sensors/clients on the network.

### Roadmap / Future plans

| Status | Goal                                                 |
| :----: | ---------------------------------------------------- |
|   ✅    | Enable connection to all local devices               |
|   ✅    | Enable remote connection via global gateway server   |
|   ✅    | Provide local REST API for data/status queries       |
|   ✅    | Persist device states for temporal / history queries |
|   ⬜️    | ...                                                  |

### Running via container

This repository builds ready to use container equipped with all Hub dependencies for both *x86* and *arm* architecture.

- `ghcr.io/maperz/iot-hub` for *x86*

- `ghcr.io/maperz/iot-hub/arm` for *arm*

To run the hub via docker execute the following command:

```shell
sudo docker run -p 5000:5000 -p 1883:1883 ghcr.io/maperz/iot-hub/arm
```

This will make sure that all ports required are opened and configured properly.
If more control is required, e.g. a different HubId shall be configured or the server base url is different, this configurations can be set via docker environement variables flag "-e ...". Since data running in the container is typically not persisted is is often required to mount a host folder into the container and then configure the `StorageConfig__DatabasePath` option to reference a sqlite file in this persistent folder.

```shell
sudo docker run -p 5000:5000 -p 1883:1883 -e "HubConfig__HubId=Hub123" -v $(pwd)/hubdata:/data -e "StorageConfig__DatabasePath=/data/devices.db" ghcr.io/maperz/iot-hub/arm
```

### Build and run

To build and run this project locally make sure that all source files are located locally. Then execute the following command in the Hub folder.

``` shell
dotnet restore
dotnet build
```

Or run the project via the following command:

``` shell
dotnet run
```

