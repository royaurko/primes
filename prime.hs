import System.Random
import Control.Parallel
import System.Time


-- Calculate Jacobi Symbol

jacobi :: Integer -> Integer -> Integer
jacobi 1 _ = 0
jacobi 2 n = case (n `mod` 8) of
		1 -> 1
		3 -> -1
		5 -> -1
		7 -> 1
jacobi 0 _ = 0
jacobi a n | even a = jacobi 2 n * jacobi (a `div` 2)  n
           | a >= n = jacobi (a `mod` n) n
	   | a `mod` 4 == 3 &&
             n `mod` 4 == 3 = - jacobi n a
           | otherwise      = jacobi n a

-- Solovoy Strassen Primality Test


  
ssprimality :: Integer -> Integer -> Bool -> IO Bool
ssprimality n k b = do
		      r1 <- getStdGen
		      let (a,r2) = randomR (0,n-1) r1
		      setStdGen r2
		      y <- (if ((gcd a n)/=1) 
		      		then (return False) 
		      		else (return (((a^((n-1) `div` 2)) `mod` n)==((jacobi a n) `mod` n)))) 
		      if (k==0) then (return (b||y)) 
		      		else (ssprimality n (k-1) y)
		


solovoyStrassen :: Integer -> Integer -> IO Bool
solovoyStrassen n k = ssprimality n k False

-- End of Solovoy Strassen Primality Test

-- Miller Rabin Primality Test

millerRabin :: Integer -> Integer -> IO Bool
millerRabin n k = millerRabinTest n k False

millerRabinTest :: Integer -> Integer -> Bool -> IO Bool
millerRabinTest n k b = do
			r1 <- getStdGen
			let (a,r2) = randomR (2,n-2) r1
			setStdGen r2
			let y = millerRabinPrimality n a in
				if (k==0) then (return (b||y)) 
					  else (millerRabinTest n (k-1) y)
			

millerRabinPrimality :: Integer -> Integer -> Bool
millerRabinPrimality n a
    | a <= 1 || a >= (n-1) =
        error $ "millerRabinPrimality: a out of range ("
              ++ show a ++ " for "++ show n ++ ")"
    | n < 2 = False
    | even n = False
    | b0 == 1 || b0 == n1 = True
    | otherwise = iter (tail b)
    where
        n1 = n-1
        (k,m) = find2km n1
        b0 = powMod n a m
        b = take (fromIntegral k) $ iterate (squareMod n) b0
        iter [] = False
        iter (x:xs)
            | x == 1 = False
            | x == n1 = True
            | otherwise = iter xs


find2km :: Integral a => a -> (a,a)
find2km n = f 0 n
    where
        f k m
            | r == 1 = (k,m)
            | otherwise = f (k+1) q
            where (q,r) = quotRem m 2

squareMod :: Integral a => a -> a -> a
squareMod a b = (b*b) `rem` a

mulMod :: Integral a => a -> a -> a -> a
mulMod a b c = (b*c) `mod` a

pow1 :: (Num a, Integral b) => (a -> a -> a) -> (a -> a) -> a -> b -> a
pow1 _ _ _ 0 = 1
pow1 mul sq x1 n1 = f x1 n1 1
    where
        f x n y
            | n == 1 = x `mul` y
            | r == 0 = f x2 q y
            | otherwise = f x2 q (x `mul` y)
            where
                 (q,r) = quotRem n 2
                 x2 = sq x


pow :: (Num a, Integral b) => a -> b -> a
pow = pow1 (*) (\x -> x*x)

powMod :: Integral a => a -> a -> a -> a
powMod m = pow1 (mulMod m) (squareMod m)

-- End of Miller Rabin Primality test

-- The sequential part of the program.

testPrimalitySeq :: Integer -> Integer -> IO Bool
testPrimalitySeq n k = do
			y <- solovoyStrassen n k
			z <- millerRabin n k
			return (y&&z)


--The parallel part of the program

testPrimalityPar :: Integer -> Integer -> IO Bool
testPrimalityPar n k = do
			 (solovoyStrassen n k) `par` 
			 	((millerRabin n k) `pseq` 
			 		(result (millerRabin n k) (solovoyStrassen n k)))
			   

result :: IO Bool -> IO Bool -> IO Bool
result ss mr = do
		 y <- ss
		 z <- mr
		 return (y&&z)

secDiff :: ClockTime -> ClockTime -> Float
secDiff (TOD secs1 psecs1) (TOD secs2 psecs2) = fromInteger (psecs2 - psecs1) / 
							(1e5 + fromInteger (secs2 - secs1))


main = do
	n <- getLine	
	t0 <- getClockTime
	x <- testPrimalitySeq (read n) 100
	t1 <- getClockTime
	if x then (putStrLn "True (Sequential)") else (putStrLn "False (Sequential)")
	putStrLn (show (secDiff t0 t1))
	t2 <- getClockTime
	z <- testPrimalityPar (read n) 100
	t3 <- getClockTime
	if z then (putStrLn "True (Parallel)") else (putStrLn "False (Parallel)")
	putStrLn (show (secDiff t2 t3))
   
    
