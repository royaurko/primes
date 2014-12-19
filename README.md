#Description

A couple of programs that implement two well known randomized primality testing algorithms:
[Miller-Rabin](http://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test) and 
[Solovay-Strassen](http://en.wikipedia.org/wiki/Solovay%E2%80%93Strassen_primality_test) 
in Haskell. The idea was to test Haskell's support for
concurrency and parallelization. To run it you need a multicore machine.

#Usage

* To run the two programs you must have a Haskell compiler installed.

* Install the parallel package from Hackage. For instance by typing

```

$ cabal install parallel

```
   at the command prompt, if you have cabal installed.

* Install the random package from Hackage. For instance by typing

```

$ cabal install random

```

* To compile type

```

$ ghc -threaded -O2 <program name>.hs --make -fforce-recomp

```

* To run the program use

```

$ ./<program name> +RTS -N

```

