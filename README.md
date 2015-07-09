# Description

A couple of programs that implement two well known randomized primality testing algorithms:
[Miller-Rabin](http://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test) and 
[Solovay-Strassen](http://en.wikipedia.org/wiki/Solovay%E2%80%93Strassen_primality_test) 
in Haskell. The idea was to test Haskell's support for
concurrency and parallelization. 

## Dependencies
- [parallel](https://hackage.haskell.org/package/parallel)
- [random](https://hackage.haskell.org/package/random)
- A multicore CPU

#Usage

* Compile

```shell
ghc -threaded -O2 prime.hs --make -fforce-recomp
ghc -threaded -O2 parprime.hs --make -fforce-recomp
```

* Run

```shell
./prime +RTS -N
./parprime +RTS -N
```

