# wasi-xslt

Provides WASI build for tools in `libxml2` and `libxslt` libraries.

## Build

`zig` is used to simplify the build process instead of `clang`.

`libxml2` is built with the following command using official release:

```shell
$ AR="zig ar" CC="zig cc -target wasm32-wasi" RANLIB="zig ranlib" ./configure \
  --host=wasm32-wasi --enable-static \
  --without-http --without-ftp \
  --without-python --without-zlib --without-lzma
$ make
$ file xmlcatalog
xmlcatalog: WebAssembly (wasm) binary module version 0x1 (MVP)
$ file xmllint
xmllint: WebAssembly (wasm) binary module version 0x1 (MVP)
```

`libxslt` is built with the following command using official release:

```shell
$ AR="zig ar" CC="zig cc -target wasm32-wasi" RANLIB="zig ranlib" ./configure \
  --host=wasm32-wasi --with-libxml-src=../libxml2 --enable-static \
  --without-python --without-crypto
$ make
$ file xsltproc/xsltproc
xsltproc: WebAssembly (wasm) binary module version 0x1 (MVP)
```
