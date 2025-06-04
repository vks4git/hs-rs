#!/bin/bash

cd rust
if [ -d target ] 
then 
    #cleanup
    rm -rf target
fi

# compile rust
RUSTFLAGS="--emit=obj" cargo build --release --target=wasm32-unknown-unknown

# .o file is actually a static library suitable for linking
cp target/wasm32-unknown-unknown/release/deps/hello_wasm.o ../haskell/libs/librust.a

cd ../haskell
# cleanup (previous builds might mess up compilation especially if target was not wasm)
cabal clean

# compile Haskell
cabal --with-compiler=wasm32-wasi-ghc-9.12 --with-hc-pkg=wasm32-wasi-ghc-pkg-9.12 --with-hsc2hs=wasm32-wasi-hsc2hs-9.12 build
$(wasm32-wasi-ghc-9.12 --print-libdir)/post-link.mjs -i a.out -o ghc_wasm_jsffi.js

# move everything into the demo directory
mv ghc_wasm_jsffi.js ../js/
mv a.out ../js/linked.wasm

# run demo
cd ../js
deno index.mjs 
