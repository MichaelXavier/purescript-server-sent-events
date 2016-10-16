module Network.EventSource
    ( newEventSource
    , addEventListener
    , removeEventListener
    , dispatchEvent
    , setOnMessage
    , eventData
    , readyState
    , url
    , EventSourceConfig(..)
    , EventSource
    , URL(..)
    , ReadyState(..)
    ) where


-------------------------------------------------------------------------------
import DOM.Event.EventTarget as ET
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import DOM (DOM)
import DOM.Event.Event (Event)
import DOM.Event.EventTarget (EventListener)
import DOM.Event.Types (EventType, EventTarget)
import Data.Function.Uncurried (runFn2, runFn1, Fn2, Fn1)
import Data.Generic (class Generic, gEq, gShow)
import Data.Maybe (Maybe(Just, Nothing))
import Data.Monoid ((<>))
import Partial (crashWith)
import Partial.Unsafe (unsafePartial)
import Prelude (show, class Eq, class Show, Unit)
-------------------------------------------------------------------------------


-- | EventSource class. Inherits from EventTarget
newtype EventSource = EventSource EventTarget


-------------------------------------------------------------------------------
type EventSourceConfig = {
      withCredentials :: Boolean
    }


-------------------------------------------------------------------------------
newtype URL = URL String


derive instance genericURL :: Generic URL


instance showURL :: Show URL where
  show = gShow


instance eqURL :: Eq URL where
  eq = gEq


-------------------------------------------------------------------------------
data ReadyState = CONNECTING
                | OPEN
                | CLOSED


derive instance genericReadyState :: Generic ReadyState


instance showReadyState :: Show ReadyState where
  show = gShow


instance eqReadyState :: Eq ReadyState where
  eq = gEq


-------------------------------------------------------------------------------
readyState :: EventSource -> ReadyState
readyState (EventSource target) = case readyStateImpl target of
  0 -> CONNECTING
  1 -> OPEN
  2 -> CLOSED
  n -> unsafePartial (crashWith ("Invalid EventSource code " <> show n <> ". Valid values are 0,1, and 2."))


-------------------------------------------------------------------------------
url :: EventSource -> URL
url (EventSource target) = URL (urlImpl target)


-------------------------------------------------------------------------------
newEventSource :: forall eff. URL -> Maybe EventSourceConfig -> Eff ( dom :: DOM | eff) EventSource
newEventSource (URL s) Nothing = runFn1 newEventSourceImpl1 s
newEventSource (URL s) (Just c) = runFn2 newEventSourceImpl2 s c


-------------------------------------------------------------------------------
-- | Destructively overwrites the onmessage callback for the EventSource
setOnMessage
    :: forall eff. EventSource
    -> EventListener ( dom :: DOM | eff)
    -> Eff ( dom :: DOM | eff) Unit
setOnMessage = runFn2 setOnMessageImpl


-------------------------------------------------------------------------------
setOnOpen
    :: forall eff. EventSource
    -> EventListener ( dom :: DOM | eff)
    -> Eff ( dom :: DOM | eff) Unit
setOnOpen = runFn2 setOnOpenImpl


-------------------------------------------------------------------------------
-- | Inherited from EventTarget. EventType corresponds to the
-- domain-specific type of event sent from the server.
addEventListener
    :: forall eff. EventType
    -> EventListener (dom :: DOM | eff)
    -> Boolean
    -- ^ Indicates whether the listener should be added for the "capture" phase.
    -> EventSource
    -> Eff (dom :: DOM | eff) Unit
addEventListener ty l useCapture (EventSource target) =
  ET.addEventListener ty l useCapture target


-------------------------------------------------------------------------------
-- | Inherited from EventTarget. EventType corresponds to the
-- domain-specific type of event sent from the server.
removeEventListener
    :: forall eff. EventType
    -> EventListener (dom :: DOM | eff)
    -> Boolean
    -- ^ Indicates whether the listener should be added for the "capture" phase.
    -> EventSource
    -> Eff (dom :: DOM | eff) Unit
removeEventListener ty l useCapture (EventSource target) =
  ET.removeEventListener ty l useCapture target


-------------------------------------------------------------------------------
-- | Inherited from EventTarget. EventType corresponds to the
-- domain-specific type of event sent from the server.
dispatchEvent
    :: forall eff. Event
    -> EventSource
    -> Eff (dom :: DOM, err :: EXCEPTION | eff) Boolean
dispatchEvent e (EventSource target) = ET.dispatchEvent e target


-------------------------------------------------------------------------------
eventData :: Event -> String
eventData = runFn1 eventDataImpl


-------------------------------------------------------------------------------
foreign import newEventSourceImpl1 :: forall eff. Fn1 String (Eff ( dom :: DOM | eff) EventSource)


-------------------------------------------------------------------------------
foreign import newEventSourceImpl2 :: forall eff. Fn2 String EventSourceConfig (Eff ( dom :: DOM | eff) EventSource)


-------------------------------------------------------------------------------
foreign import setOnMessageImpl :: forall eff. Fn2 EventSource (EventListener (dom :: DOM | eff)) (Eff ( dom :: DOM | eff) Unit)


-------------------------------------------------------------------------------
foreign import setOnOpenImpl :: forall eff. Fn2 EventSource (EventListener (dom :: DOM | eff)) (Eff ( dom :: DOM | eff) Unit)


-------------------------------------------------------------------------------
foreign import eventDataImpl :: Fn1 Event String


-------------------------------------------------------------------------------
foreign import readyStateImpl :: Fn1 EventTarget Int


-------------------------------------------------------------------------------
foreign import urlImpl :: Fn1 EventTarget String
