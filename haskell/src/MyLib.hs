{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}

module MyLib where

import Data.Int (Int32)
import System.IO.Unsafe

foreign export ccall fib :: Int32 -> Int32

foreign import ccall add :: Int32 -> Int32 -> IO Int32

myAdd :: Int32 -> Int32 -> Int32
myAdd a b = unsafePerformIO $ add a b

fib :: Int32 -> Int32
fib 0 = 1
fib 1 = 1
fib n = fib (n - 1) `myAdd` fib (n - 2)

