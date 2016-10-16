module Network.EventSource
    ( newEventSource
    , setOnMessage
    , eventData
    , EventSourceConfig(..)
    , EVENTSOURCE()
    , EventSource
    , URL(..)
    ) where


-------------------------------------------------------------------------------
import Control.Monad.Eff (Eff)
import DOM.Event.Event (Event)
import Data.Function.Uncurried (runFn2, runFn1, Fn2, Fn1)
import Data.Maybe (Maybe(Just, Nothing))
import Prelude (Unit)
-------------------------------------------------------------------------------


-- | Effect type for event source operations
foreign import data EVENTSOURCE :: !


-- | EventSource class
foreign import data EventSource :: *


-------------------------------------------------------------------------------
type EventSourceConfig = {
      withCredentials :: Boolean
    }


-------------------------------------------------------------------------------
newtype URL = URL String


-------------------------------------------------------------------------------
newEventSource :: forall eff. URL -> Maybe EventSourceConfig -> Eff ( eventsource :: EVENTSOURCE | eff) EventSource
newEventSource (URL s) Nothing = runFn1 newEventSourceImpl1 s
newEventSource (URL s) (Just c) = runFn2 newEventSourceImpl2 s c


-------------------------------------------------------------------------------
-- | Destructively overwrites the onmessage callback for the EventSource
setOnMessage
    :: forall eff handlerEff. EventSource
    -> (Event -> Eff handlerEff Unit)
    -> Eff ( eventsource :: EVENTSOURCE | eff) Unit
setOnMessage = runFn2 setOnMessageImpl


-------------------------------------------------------------------------------
eventData :: Event -> String
eventData = runFn1 eventDataImpl

-------------------------------------------------------------------------------
foreign import newEventSourceImpl1 :: forall eff. Fn1 String (Eff ( eventsource :: EVENTSOURCE | eff) EventSource)


-------------------------------------------------------------------------------
foreign import newEventSourceImpl2 :: forall eff. Fn2 String EventSourceConfig (Eff ( eventsource :: EVENTSOURCE | eff) EventSource)


-------------------------------------------------------------------------------
foreign import setOnMessageImpl :: forall eff handlerEff. Fn2 EventSource (Event -> Eff handlerEff Unit) (Eff ( eventsource :: EVENTSOURCE | eff) Unit)


-------------------------------------------------------------------------------
foreign import eventDataImpl :: Fn1 Event String

