# Linux\* kernel for Clear Containers

This repository provides Linux patches and configuration for
Clear Containers. 

## Patches and configuration

The patches are located in `patches-4.9.x/`, they should be used to build a kernel
for Containers Guest.

The configuration suggested for a Clear Container Guest can be found in 
`kernel-config-4.9.x`.


## Build a kernel

You can use the script `build-kernel.sh` to build a kernel.

1. Prepare a kernel, the sub-command `prepare`from the script `./build-kernel.sh`
will download the Linux source code and apply the patches in `patches-4.9.x/`
and use the configuration in `kernel-config-4.9.x`.
```
./build-kernel.sh prepare
```

After run the command successfully the kernel source code will be locate in the
current working directory in a directory called `cc-linux`.

2. Build a kernel, after prepare a kernel use the sub-command `build` from the script
`build-kernel.sh`

```
./build-kernel.sh build
```

This sub-command will build the kernel source code and generate a kernel binary in
`cc-linux/vmlinux`.

## Modify kernel

### Add changes to source code

You can modify the source code adding more patches in the directory `patches-4.9.x/` and
run `./build-kernel.sh prepare`

### Modify configuration

To modify the kernel configuration modify the confing in `kernel-config-4.9.x` or go to
`cc-linux` and use Linux kernel kconfig tools.

```
./build-kernel.sh prepare
cd cc-linux/
make nconfig
```
