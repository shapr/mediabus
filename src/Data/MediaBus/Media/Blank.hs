-- | Type class for media content that has /blank/ values, that represent a
-- neutral media content such as silence or a black image.
module Data.MediaBus.Media.Blank
    ( CanGenerateBlankMedia(..)
    , CanBeBlank(..)
    ) where

import           Data.MediaBus.Basics.Ticks
import           Data.MediaBus.Media.Segment
import           Data.Time.Clock
import           Control.Lens
import           Data.Proxy

-- | Types that can have /blank/ values.
class CanBeBlank a where
    -- | Generate the value that represents neutral media content.
    blank :: a

-- | Types that have a dynamic duration, for example a audio sample buffers, can
-- implement this type class to provide methods for generating blank media
-- content (e.g. silence) for a certain duration.
class CanGenerateBlankMedia a where
    -- | Generate the value that represents neutral media content, and has at
    -- least the given duration.
    blankFor :: NominalDiffTime -> a
    blankFor dt = blankForTicks (nominalDiffTime # dt :: PicoSeconds)
    -- | Generate the value that represents neutral media content, and has at
    -- least the given duration given as 'Ticks'
    blankForTicks :: CanBeTicks r i => Ticks r i -> a
    blankForTicks ticks = blankFor (from nominalDiffTime # ticks)

instance (HasStaticDuration d, CanGenerateBlankMedia a) =>
         CanBeBlank (Segment d a) where
    blank = MkSegment (blankFor (getStaticDuration (Proxy :: Proxy d)))
