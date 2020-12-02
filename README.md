# nsz-extractor
nsz tool docker image with automatic decompression on watched directory and optional nut server update hook

Architectures supported by this image are:

* linux/amd64
* linux/arm64
* linux/armhf

## Quick Start

Pull latest build from docker hub

```
docker pull mellotanica/nsz-extractor:latest
````

### Command line mode

Launch the nsz-extractor docker container with the following command:

```
docker run \
    -v $HOME/.switch:/opt/switch:ro \
    -e PUID=$(id -u) \
    -e PGID=$(id -g) \
    mellotanica/nsz-extractor:latest \
    nsz [nsz-options]
```

specifiying the required options.

### Daemon/autoextraction mode

Launch the nsz-extractor docker container with the following command:

``` 
docker run -d \
    --name=nsz-extractor \
    -v $NSZ:/compressed:rw \
    -v $NSP:/extracted:rw \
    -v $HOME/.switch:/opt/switch:ro \
    -e PUID=$(id -u) \
    -e PGID=$(id -g) \
    -e DELETE=false \
    mellotanica/nsz-extractor:latest
```

Where:

* $NSZ: is the folder where the compressed files are located
* $NSP: is the folder where the extracted files will be dropped
* $HOME/.switch: must contain a valid prod.keys file
* PUID: is the user id that will be used inside the container for writing the output files
* PGID: is the group id that will be used inside the container for writing the output files
* DELETE: if true, compressed files will be removed upon successful decompression

