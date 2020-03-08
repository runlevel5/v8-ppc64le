The goal is to get those precious:

* `libv8_libbase.a`
* `libv8_libplatform.a`
* `libv8_monolith.a`

which are needed to build rubyjs/libv8 rubygem

So, here is the steps:

1. You need a Linux ppc64le to play with 
2. Clone this repo
3. Build the container image:

```
$ podman build . --tag=libv8
```

NOTE: you could use `docker` if you prefer

4. Run the container:

```
$ mkdir -p /tmp/v8
$ podman run -d -v /tmp/v8:/tmp/v8/out.gn/libv8 libv8
$ cp /tmp/v8/obj/*.a /destination # wherever you want them
```
