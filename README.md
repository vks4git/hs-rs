# Description

This repository contains an example of the following pipeline:

- Compile Rust code exporting a function into WebAssembly linkable object
- Compile Haskell code containing FFI to import the function from above into WebAssembly
- Link the two object files together
- Use the WebAssembly file in browser

## Compiling Rust to WASM
You'll need [cargo and rustup](https://doc.rust-lang.org/cargo/getting-started/installation.html)

You'll also need to install plugin for targeting wasm:

```bash
rustup target add wasm32-unknown-unknown
```

After that, compilation can be performed with

```bash
RUSTFLAGS="--emit=obj" cargo build --release --target=wasm32-unknown-unknown
```

This will produce the linkable object file in `target/wasm32-unknown-unknown/release/deps/hello_wasm.o`

## Compiling Haskell to WASM

This library can be compiled into Web assembly and used in a browser.

You'll need to install GHC wasm backend first. See [full article](https://gitlab.haskell.org/haskell-wasm/ghc-wasm-meta) for more details.

The GHCup approach was tested and confirmed to work with some extra steps:

```bash
export CONFIGURE_ARGS="--host=x86_64-linux --with-intree-gmp --with-system-libffi"
curl https://gitlab.haskell.org/haskell-wasm/ghc-wasm-meta/-/raw/master/bootstrap.sh | SKIP_GHC=1 sh
source ~/.ghc-wasm/env
ghcup config add-release-channel https://gitlab.haskell.org/haskell-wasm/ghc-wasm-meta/-/raw/master/ghcup-wasm-0.0.9.yaml
ghcup install ghc wasm32-wasi-9.12 -- $CONFIGURE_ARGS
```

First, copy the compiled Rust object file into `libs/librust.a`.

After that, the library can be compiled with

```bash
cabal --with-compiler=wasm32-wasi-ghc-9.12 --with-hc-pkg=wasm32-wasi-ghc-pkg-9.12 --with-hsc2hs=wasm32-wasi-hsc2hs-9.12 build
```

The compiler will output a file `a.out` in the root directory. This is the WASM module that can be imported and used in a browser.
It currently exports two functions, [mkProofBytesWasm](src/ZkFold/Symbolic/Cardano/Contracts/SmartWallet.hs#L375) and [mkProofBytesMockWasm](src/ZkFold/Symbolic/Cardano/Contracts/SmartWallet.hs#L378), which produce Plonkup proofs that the user possesses a valid JSON Web Token issued by Google.

The library uses JS FFI, so one last step is required to generate a helper file:

```bash
$(wasm32-wasi-ghc-9.12 --print-libdir)/post-link.mjs -i a.out -o ghc_wasm_jsffi.js
```

## Running JS

You'll need [Deno](https://deno.com/) to run the example

Copy the compiled Haskell code (`a.out` and `ghc_wasm_jsffi.js`) into the `js` directory. Rename `a.out` into `linked.wasm`.

Then, run

```bash
deno index.mjs
```

Grant access to the file.

This should print 89 as the 10th Fibonacci number 

## Testing

The whole pipeline can be run with

```bash
./build.sh
```

This should print 89 as the 10th Fibonacci number 


Further reading:

https://ghc.gitlab.haskell.org/ghc/doc/users_guide/wasm.html

https://finley.dev/blog/2024-08-24-ghc-wasm.html


