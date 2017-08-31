# LinkIt Smart 7688 cross compile with Docker

## Build Docker file

```
  $ git clone https://github.com/opjlmi/7688-cross-compile-docker.git
  $ cd 7688-cross-compile-docker
  $ docker build -t mt7688 .
```

## Run Docker container

```
  $ docker run -dit --name 7688-node mt7688
  $ docker attach 7688-node
  [Press Enter again]
```

## Custom 7688 Image

```
  ubuntu:~/openwrt$ make menuconfig
```

******* There are some settings you need to do!**

- `Target System > Ralink RT288x/RT3xxx`
- `Subtarget > MT7688 based boards`
- `Target Profile > LinkIt7688`

******* For Nodejs**

`Languages > Node.js`

- node -> Configuration -> 6.X LTS ( 8.X not support yet )
- node-npm ( Press Blank key let <> become <*> )
- ....and more module you wanna build

Note: <*> and \<M\> are different, \<M\> means build but not build-in to img.


## Build 7688 Image

```
  ubuntu:~/openwrt$ make V=99
```

If your cpu have more core, you can:

```
  ubuntu:~/openwrt$ make V=99 -j4
```

If sccuess, you will see the image file in `bin/ramips/openwrt-ramips-mt7688-LinkIt7688-squashfs-sysupgrade.bin`