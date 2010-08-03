
{-# LANGUAGE EmptyDataDecls #-}

module Data.Eq.Approximate where

import Control.Arrow
import Data.Function

import TypeLevel.NaturalNumber

{-|
    The newtype AbsolutelyApproximateValue is a wrapper that can contain an arbitrary value tagged with a tolerance.
-}
newtype AbsolutelyApproximateValue absolute_tolerance value =
        AbsolutelyApproximateValue { unwrapAbsolutelyApproximateValue :: value }

data Digits n
class AbsoluteTolerance tolerance where
    absoluteToleranceOf ::
        Fractional value =>
        AbsolutelyApproximateValue tolerance value ->
        value
instance (AbsoluteTolerance tolerance
         ,Ord value
         ,Fractional value
         ) =>
         Show (AbsolutelyApproximateValue tolerance value)
  where
    show x =
        show (unwrapAbsolutelyApproximateValue x)
        ++ " +/- " ++
        show (absoluteToleranceOf x)
instance (AbsoluteTolerance tolerance
         ,Ord value
         ,Fractional value
         ) =>
         Eq (AbsolutelyApproximateValue tolerance value)
  where
    a == b =
        abs (x - y) <= absoluteToleranceOf a
      where
        x = unwrapAbsolutelyApproximateValue a
        y = unwrapAbsolutelyApproximateValue b
instance (AbsoluteTolerance tolerance
         ,Ord value
         ,Fractional value
         ) =>
         Ord (AbsolutelyApproximateValue tolerance value)
  where
    compare a b
      | a == b    = EQ
      | otherwise = compare x y
      where
        x = unwrapAbsolutelyApproximateValue a
        y = unwrapAbsolutelyApproximateValue b
instance Enum value => Enum (AbsolutelyApproximateValue tolerance value) where
    succ = liftAAV1 succ
    pred = liftAAV1 pred
    toEnum = wrapAAV . toEnum
    fromEnum = unwrapAAVAndApply fromEnum
    enumFrom = map wrapAAV . enumFrom . unwrapAAV
    enumFromThen a b = map wrapAAV (enumFromThen (unwrapAAV a) (unwrapAAV b))
    enumFromTo a b = map wrapAAV (enumFromTo (unwrapAAV a) (unwrapAAV b))
    enumFromThenTo a b c = map wrapAAV (enumFromThenTo (unwrapAAV a) (unwrapAAV b) (unwrapAAV c))
instance
    (AbsoluteTolerance tolerance
    ,Ord value
    ,Fractional value
    ) => Num (AbsolutelyApproximateValue tolerance value)
  where
    (+) = liftAAV2 (+)
    (*) = liftAAV2 (*)
    (-) = liftAAV2 (-)
    negate = liftAAV1 negate
    abs = liftAAV1 abs
    signum = liftAAV1 signum
    fromInteger = wrapAAV . fromInteger
instance
    (AbsoluteTolerance tolerance
    ,Ord value
    ,Fractional value
    ,Real value
    ) => Real (AbsolutelyApproximateValue tolerance value)
  where
    toRational = unwrapAAVAndApply toRational
instance
    (AbsoluteTolerance tolerance
    ,Ord value
    ,Fractional value
    ,Integral value
    ) => Integral (AbsolutelyApproximateValue tolerance value)
  where
    quot = liftAAV2 quot
    rem = liftAAV2 rem
    div = liftAAV2 div
    mod = liftAAV2 mod
    quotRem a b = (wrapAAV *** wrapAAV) $ (quotRem `on` unwrapAAV) a b
    divMod a b = (wrapAAV *** wrapAAV) $ (divMod `on` unwrapAAV) a b
    toInteger = toInteger . unwrapAAV
instance
    (AbsoluteTolerance tolerance
    ,Ord value
    ,Fractional value
    ) => Fractional (AbsolutelyApproximateValue tolerance value)
  where
    (/) = liftAAV2 (/)
    recip = liftAAV1 recip
    fromRational = wrapAAV . fromRational
instance
    (AbsoluteTolerance tolerance
    ,Ord value
    ,Floating value
    ) => Floating (AbsolutelyApproximateValue tolerance value)
  where
    pi = wrapAAV pi
    exp = liftAAV1 exp
    sqrt = liftAAV1 sqrt
    log = liftAAV1 log
    (**) = liftAAV2 (**)
    logBase = liftAAV2 logBase
    sin = liftAAV1 sin
    tan = liftAAV1 tan
    cos = liftAAV1 cos
    asin = liftAAV1 asin
    atan = liftAAV1 atan
    acos = liftAAV1 acos
    sinh = liftAAV1 sinh
    tanh = liftAAV1 tanh
    cosh = liftAAV1 cosh
    asinh = liftAAV1 asinh
    atanh = liftAAV1 atanh
    acosh = liftAAV1 acosh
instance
    (AbsoluteTolerance tolerance
    ,Ord value
    ,RealFrac value
    ) => RealFrac (AbsolutelyApproximateValue tolerance value)
  where
    properFraction = second wrapAAV . unwrapAAVAndApply properFraction
    truncate = unwrapAAVAndApply truncate
    round = unwrapAAVAndApply round
    ceiling = unwrapAAVAndApply ceiling
    floor = unwrapAAVAndApply floor
instance
    (AbsoluteTolerance tolerance
    ,Ord value
    ,RealFloat value
    ) => RealFloat (AbsolutelyApproximateValue tolerance value)
  where
    floatRadix = unwrapAAVAndApply floatRadix
    floatDigits = unwrapAAVAndApply floatDigits
    floatRange = unwrapAAVAndApply floatRange
    decodeFloat = unwrapAAVAndApply decodeFloat
    encodeFloat x y = wrapAAV (encodeFloat x y)
    exponent = unwrapAAVAndApply exponent
    significand = liftAAV1 significand
    scaleFloat i = liftAAV1 (scaleFloat i)
    isNaN = unwrapAAVAndApply isNaN
    isInfinite = unwrapAAVAndApply isInfinite
    isDenormalized = unwrapAAVAndApply isDenormalized
    isNegativeZero = unwrapAAVAndApply isNegativeZero
    isIEEE = unwrapAAVAndApply isIEEE
    atan2 = liftAAV2 atan2
instance NaturalNumber n => AbsoluteTolerance (Digits n) where
    absoluteToleranceOf =
        recip
        .
        fromInteger
        .
        ((10::Integer) ^)
        .
        getDigitsOfAbsoluteTolerance
getDigitsOfAbsoluteTolerance ::
    NaturalNumber n =>
    AbsolutelyApproximateValue (Digits n) value ->
    Int
getDigitsOfAbsoluteTolerance = naturalNumberAsInt . getDigits
  where
    getDigits :: AbsolutelyApproximateValue (Digits n) value -> n
    getDigits _ = undefined
{-# INLINE wrapAAV #-}
{-# INLINE unwrapAAV #-}
{-# INLINE liftAAV1 #-}
{-# INLINE liftAAV2 #-}
{-# INLINE unwrapAAVAndApply #-}
wrapAAV = AbsolutelyApproximateValue
unwrapAAV = unwrapAbsolutelyApproximateValue
liftAAV1 f = wrapAAV . f . unwrapAAV
liftAAV2 f a b = wrapAAV (f (unwrapAAV a) (unwrapAAV b))
unwrapAAVAndApply f = f . unwrapAAV
