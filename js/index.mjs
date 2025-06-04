import { WASI } from "https://cdn.jsdelivr.net/npm/@runno/wasi@0.7.0/dist/wasi.js";
import ghc_wasm_jsffi from "./ghc_wasm_jsffi.js";
import fs from "node:fs";

async function initialiseWASI() {
    const wasi = new WASI({
        stdout: (out) => console.log("[wasm stdout]", out),
    });
    
    const jsffiExports = {};
    const src = fs.readFileSync('./linked.wasm');
    const wasm_bin = await WebAssembly.instantiate(
        src,
        Object.assign(
            { ghc_wasm_jsffi: ghc_wasm_jsffi(jsffiExports) },
            wasi.getImportObject()
        )
    );
    Object.assign(jsffiExports, wasm_bin.instance.exports);
    
    wasi.initialize(wasm_bin, {
        ghc_wasm_jsffi: ghc_wasm_jsffi(jsffiExports),
    });

    wasi.instance.exports.hs_init(0,0);
    
    return wasi.instance; 
}

const instance = await initialiseWASI();
console.log(`\n\nDemo: 10th Fibonacci number is ${instance.exports.fib(10)}`);
