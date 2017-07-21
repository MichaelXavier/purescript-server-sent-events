-- | An interface to the Server-Sent Events API (SSE).
-- |
-- | Not all browsers support this API. See [Browser Compatibility](https://developer.mozilla.org/en-US/docs/Web/API/EventSource#Browser_compatibility).
-- |
-- | [Specification](https://html.spec.whatwg.org/multipage/server-sent-events.html)
module Network.EventSource
    ( newEventSource
    , addEventListener
    , removeEventListener
    , dispatchEvent
    , setOnError
    , setOnMessage
    , setOnOpen
    , eventData
    , readyState
    , withCredentials
    , url
    , close
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
import DOM.Event.EventTarget (EventListener, eventListener)
import DOM.Event.Types (EventType, EventTarget)
import Data.Function.Uncurried (runFn2, runFn1, Fn2, Fn1)
import Data.Generic (class Generic, gShow)
import Data.Maybe (Maybe(Just, Nothing))
import Prelude (class Eq, class Show, Unit)
-------------------------------------------------------------------------------


-- | EventSource class. Inherits from EventTargetk
-- | It connects to a server over HTTP and receives events in
-- | `text/event-stream` format without closing the connection.
newtype EventSource = EventSource EventTarget


-------------------------------------------------------------------------------
-- | Indicate if CORS should be set to include credentials.
-- | Default: false
type EventSourceConfig = {
      withCredentials :: Boolean
    }


-------------------------------------------------------------------------------
-- | The URL of the source e.g. `"/stream"`.
newtype URL = URL String

derive newtype instance showURL :: Show URL
derive newtype instance eqURL :: Eq URL


-------------------------------------------------------------------------------
-- | Represents the state of the connection.
data ReadyState = CONNECTING
                | OPEN
                | CLOSED

derive instance genericReadyState :: Generic ReadyState
derive instance eqReadyState :: Eq ReadyState

instance showReadyState :: Show ReadyState where
  show = gShow


-------------------------------------------------------------------------------
-- | The state of the EventSource connection.
-- |
-- | **CONNECTING** The connection has not yet been established, or it
-- | was closed and the user agent is reconnecting.
-- |
-- | **OPEN** The user agent has an open connection and is dispatching
-- | as it receives them.
-- |
-- | **CLOSED** The connection is not open, and the user agent is not
-- | trying to reconnect. Either there was a fatal error or the close()
-- | method was invoked.
readyState :: EventSource -> ReadyState
readyState (EventSource target) = case runFn1 readyStateImpl target of
  0 -> CONNECTING
  1 -> OPEN
  _ -> CLOSED


-------------------------------------------------------------------------------
-- | Indicate whether the EventSource object was instantiated with
-- | CORS credentials set.
withCredentials :: EventSource -> Boolean
withCredentials (EventSource target) = runFn1 withCredentialsImpl target


-------------------------------------------------------------------------------
url :: EventSource -> URL
url (EventSource target) = URL (runFn1 urlImpl target)


-------------------------------------------------------------------------------
newEventSource :: forall eff. URL -> Maybe EventSourceConfig -> Eff ( dom :: DOM | eff) EventSource
newEventSource (URL s) Nothing = runFn1 newEventSourceImpl1 s
newEventSource (URL s) (Just c) = runFn2 newEventSourceImpl2 s c


-------------------------------------------------------------------------------
-- | Destructively overwrites the onerror callback for the EventSource
setOnError
    :: forall eff. EventSource
    -> (Event -> Eff (dom :: DOM | eff) Unit)
    -> Eff ( dom :: DOM | eff) Unit
setOnError = cbHelper setOnErrorImpl


-------------------------------------------------------------------------------
-- | Destructively overwrites the onmessage callback for the EventSource
setOnMessage
    :: forall eff. EventSource
    -> (Event -> Eff (dom :: DOM | eff) Unit)
    -> Eff ( dom :: DOM | eff) Unit
setOnMessage = cbHelper setOnMessageImpl


-------------------------------------------------------------------------------
-- | Destructively overwrites the onopen callback for the EventSource
setOnOpen
    :: forall eff. EventSource
    -> (Event -> Eff (dom :: DOM | eff) Unit)
    -> Eff ( dom :: DOM | eff) Unit
setOnOpen = cbHelper setOnOpenImpl


-------------------------------------------------------------------------------
cbHelper
    :: forall eff. Fn2 EventSource (EventListener (dom :: DOM | eff)) (Eff ( dom :: DOM | eff) Unit)
    -> EventSource
    -> (Event -> Eff (dom :: DOM | eff) Unit)
    -> Eff ( dom :: DOM | eff) Unit
cbHelper cb es l= runFn2 cb es (eventListener l)


-------------------------------------------------------------------------------
-- | Inherited from EventTarget. EventType corresponds to the
-- domain-specific type of event sent from the server.
addEventListener
    :: forall eff. EventType
    -> (Event -> Eff (dom :: DOM | eff) Unit)
    -> Boolean
    -- ^ Indicates whether the listener should be added for the "capture" phase.
    -> EventSource
    -> Eff (dom :: DOM | eff) Unit
addEventListener ty l useCapture (EventSource target) =
  ET.addEventListener ty (eventListener l) useCapture target


-------------------------------------------------------------------------------
-- | Inherited from EventTarget. EventType corresponds to the
-- domain-specific type of event sent from the server.
removeEventListener
    :: forall eff. EventType
    -> (Event -> Eff (dom :: DOM | eff) Unit)
    -> Boolean
    -- ^ Indicates whether the listener should be added for the "capture" phase.
    -> EventSource
    -> Eff (dom :: DOM | eff) Unit
removeEventListener ty l useCapture (EventSource target) =
  ET.removeEventListener ty (eventListener l) useCapture target


-------------------------------------------------------------------------------
-- | Inherited from EventTarget. EventType corresponds to the
-- domain-specific type of event sent from the server.
dispatchEvent
    :: forall eff. Event
    -> EventSource
    -> Eff (dom :: DOM, err :: EXCEPTION | eff) Boolean
dispatchEvent e (EventSource target) = ET.dispatchEvent e target


-------------------------------------------------------------------------------
-- | Get the data from the event.
eventData :: Event -> String
eventData = runFn1 eventDataImpl

-- | Close the event source connection.
close :: forall eff. EventSource -> Eff (dom :: DOM | eff) Unit
close = runFn1 closeImpl

-------------------------------------------------------------------------------
foreign import newEventSourceImpl1 :: forall eff. Fn1 String (Eff ( dom :: DOM | eff) EventSource)


-------------------------------------------------------------------------------
foreign import newEventSourceImpl2 :: forall eff. Fn2 String EventSourceConfig (Eff ( dom :: DOM | eff) EventSource)


-------------------------------------------------------------------------------
foreign import setOnErrorImpl :: forall eff. Fn2 EventSource (EventListener (dom :: DOM | eff)) (Eff ( dom :: DOM | eff) Unit)


-------------------------------------------------------------------------------
foreign import setOnMessageImpl :: forall eff. Fn2 EventSource (EventListener (dom :: DOM | eff)) (Eff ( dom :: DOM | eff) Unit)


-------------------------------------------------------------------------------
foreign import setOnOpenImpl :: forall eff. Fn2 EventSource (EventListener (dom :: DOM | eff)) (Eff ( dom :: DOM | eff) Unit)


-------------------------------------------------------------------------------
foreign import eventDataImpl :: Fn1 Event String


-------------------------------------------------------------------------------
foreign import readyStateImpl :: Fn1 EventTarget Int


-------------------------------------------------------------------------------
foreign import withCredentialsImpl :: Fn1 EventTarget Boolean


-------------------------------------------------------------------------------
foreign import urlImpl :: Fn1 EventTarget String


-------------------------------------------------------------------------------
foreign import closeImpl :: forall eff. Fn1 EventSource (Eff ( dom :: DOM | eff) Unit)
