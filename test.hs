
{-# LANGUAGE EmptyDataDecls #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Test.Framework
import Test.Framework.Providers.HUnit
import Test.Framework.Providers.QuickCheck2
import Test.HUnit
import Test.QuickCheck

import TypeLevel.NaturalNumber

import Data.Eq.Approximate

instance Arbitrary value => Arbitrary (AbsolutelyApproximateValue tolerance value) where
    arbitrary = fmap AbsolutelyApproximateValue arbitrary

instance Arbitrary value => Arbitrary (RelativelyApproximateValue zerotol reltol value) where
    arbitrary = fmap RelativelyApproximateValue arbitrary
type A = AbsolutelyApproximateValue (Digits N5) Double
wrapA :: Double -> A
wrapA = AbsolutelyApproximateValue
unwrapA :: A -> Double
unwrapA = unwrapAbsolutelyApproximateValue
type R = RelativelyApproximateValue (Digits N7) (Digits N5) Double
wrapR :: Double -> R
wrapR = RelativelyApproximateValue
unwrapR :: R -> Double
unwrapR = unwrapRelativelyApproximateValue

main = defaultMain
    [testGroup "Absolutely approximate values"
        [testGroup "Num operations"
            [testProperty "+" $ \a b -> wrapA (unwrapA a + unwrapA b) == a + b
            ,testProperty "-" $ \a b -> wrapA (unwrapA a - unwrapA b) == a - b
            ,testProperty "*" $ \a b -> wrapA (unwrapA a * unwrapA b) == a * b
            ] 
        ,testGroup "Eq operations"
            [testProperty "Inside range" $ \a -> a == a + wrapA 1e-6
            ,testProperty "Outside range" $ \a -> a /= a + wrapA 1e-4
            ]
        ]
    ,testGroup "Relatively approximate values"
        [testGroup "Num operations"
            [testProperty "+" $ \a b -> wrapR (unwrapR a + unwrapR b) == a + b
            ,testProperty "-" $ \a b -> wrapR (unwrapR a - unwrapR b) == a - b
            ,testProperty "*" $ \a b -> wrapR (unwrapR a * unwrapR b) == a * b
            ] 
        ,testGroup "Eq operations"
            [testGroup "Non-zero"
                [testProperty "Inside range" $ \a -> a /= 0 ==> a == a + (a * wrapR 1e-6)
                ,testProperty "Outside range" $ \a -> a /= 0 ==> a /= a + (a * wrapR 1e-4)
                ]
            ,testGroup "Zero"
                [testCase "Inside range" $
                    assertBool "Is the value equal to zero within the tolerance?" $
                        0 == wrapR 1e-8 && wrapR 1e-8 == 0
                ,testCase "Outside range" $
                    assertBool "Is the value not equal to zero within the tolerance?" $
                        0 /= wrapR 1e-6 && wrapR 1e-6 /= 0
                ,testCase "Both inside range" $
                    assertBool "Is the value equal to zero within the tolerance?" $
                        wrapR 1e-20 == wrapR 1e-8 && wrapR 1e-8 == wrapR 1e-20
                ]  
            ]      
        ]
    ]
