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

On related topic, if you want to build libv8 rubygem, please follow these steps:

```
$ git clone https://github.com/rubyjs/libv8.git
$ cd libv8
$ mkdir -p vendor/v8/out.gn/libv8/obj
$ cp /tmp/v8/obj/*.a vendor/v8/out.gn/libv8/obj/
$ mv /tmp/v8/include vendor/v8/
$ sed -i "s/VERSION.*/VERSION\ =\ \"7.3.495.0\"/g" lib/libv8/version.rb # update version to match the v8
$ sed -i "s/task\ :binary\ =>.*/task\ :binary\ do/g" Rakefile # skip the :compile step
$ bundle exec rake binary # the built gem is placed in pkg/libv8-7.3.495-powerpc64le-linux.gem
```
