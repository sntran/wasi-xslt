LIBXML_VERSION=2.12.3
LIBXSLT_VERSION=1.1.39

AR=zig ar
CC=zig cc -target wasm32-wasi
RANLIB=zig ranlib

split-dot = $(word $2,$(subst ., ,$1))

LIBXML_URL=https://download.gnome.org/sources/libxml2/$(call split-dot,$(LIBXML_VERSION),1).$(call split-dot,$(LIBXML_VERSION),2)/libxml2-$(LIBXML_VERSION).tar.xz
LIBXSLT_URL=https://download.gnome.org/sources/libxslt/$(call split-dot,$(LIBXSLT_VERSION),1).$(call split-dot,$(LIBXSLT_VERSION),2)/libxslt-$(LIBXSLT_VERSION).tar.xz

all: xmlcatalog.wasm xmllint.wasm xsltproc.wasm
	file $^

.SECONDEXPANSION:
xmlcatalog.wasm xmllint.wasm: libxml2/$$(subst .wasm,,$$@)
	cp $< $@

xsltproc.wasm: libxslt/xsltproc/xsltproc
	cp $< $@

libxml2/%: libxml2
	cd $< && AR="$(AR)" CC="$(CC)" RANLIB="$(RANLIB)" ./configure --host=wasm32-wasi --enable-static --without-http --without-ftp --without-python --without-zlib --without-lzma
	$(MAKE) --directory $<

libxslt/%: libxslt
	cd $< && AR="$(AR)" CC="$(CC)" RANLIB="$(RANLIB)" ./configure --host=wasm32-wasi --with-libxml-src=../libxml2 --enable-static --without-python --without-crypto
	$(MAKE) --directory $<

libxml2:
	curl -L $(LIBXML_URL) -o libxml2.tar.xz
	tar xf libxml2.tar.xz
	rm libxml2.tar.xz
	mv libxml2-* $@

libxslt:
	curl -L $(LIBXSLT_URL) -o libxslt.tar.xz
	tar xf libxslt.tar.xz
	rm libxslt.tar.xz
	mv libxslt-* $@

clean:
	rm -rf libxslt libxml2 xmlcatalog.wasm xmllint.wasm xsltproc.wasm
