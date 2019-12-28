# Go 1.13.5 compiler Docker Container

For for compiling **go** ([golang](https://golang.org/)) based applications using Docker.

## Docker Container usage

Put your source in `./mpapp/` and then run something like:

```
$ ./dc-run ./build.sh
```

See the file `./mpapp/build-mailslurper.sh` for an example build script.

## Required Docker Image
The Docker Image **app-go\_native\_compiler-\<ARCH\>** will automaticly be downloaded from the Docker Hub.  
The source for the image can be found here [https://github.com/tsitle/dockerimage-app-go\_native\_compiler](https://github.com/tsitle/dockerimage-app-go_native_compiler).
