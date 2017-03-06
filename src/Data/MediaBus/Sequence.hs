module Data.MediaBus.Sequence
    ( SeqNum(..)
    , type SeqNum8
    , type SeqNum16
    , type SeqNum32
    , type SeqNum64
    , HasSeqNum(..)
    , fromSeqNum
    ) where

import           Test.QuickCheck            ( Arbitrary(..) )
import           Data.MediaBus.Monotone
import           Data.MediaBus.Series
import           Control.Lens
import           Data.Default
import           Text.Printf
import           GHC.Generics               ( Generic )
import           Control.DeepSeq
import           System.Random
import           Data.Word

class SetSeqNum t (GetSeqNum t) ~ t =>
      HasSeqNum t where
    type GetSeqNum t
    type SetSeqNum t s
    seqNum :: Lens t (SetSeqNum t s) (GetSeqNum t) s

instance (HasSeqNum a, HasSeqNum b, GetSeqNum a ~ GetSeqNum b) =>
         HasSeqNum (Series a b) where
    type GetSeqNum (Series a b) = GetSeqNum a
    type SetSeqNum (Series a b) t = Series (SetSeqNum a t) (SetSeqNum b t)
    seqNum f (Start !a) = Start <$> seqNum f a
    seqNum f (Next !b) = Next <$> seqNum f b

newtype SeqNum s = MkSeqNum { _fromSeqNum :: s }
    deriving (Num, Eq, Bounded, Enum, LocalOrd, Arbitrary, Default, Generic, Random)

type SeqNum8 = SeqNum Word8

type SeqNum16 = SeqNum Word16

type SeqNum32 = SeqNum Word32

type SeqNum64 = SeqNum Word64

instance NFData s =>
         NFData (SeqNum s)

makeLenses ''SeqNum

instance HasSeqNum (SeqNum s) where
    type GetSeqNum (SeqNum s) = s
    type SetSeqNum (SeqNum s) s' = SeqNum s'
    seqNum = fromSeqNum

instance Show s =>
         Show (SeqNum s) where
    show (MkSeqNum s) = printf "SEQNUM: %10s" (show s)

instance (Eq a, LocalOrd a) =>
         Ord (SeqNum a) where
    compare !x !y
        | x == y = EQ
        | x `succeeds` y = GT
        | otherwise = LT

deriving instance (Real a, Num a, Eq a, LocalOrd a) => Real
         (SeqNum a)

deriving instance (Integral a, Enum a, Real a, Eq a, LocalOrd a) =>
         Integral (SeqNum a)
