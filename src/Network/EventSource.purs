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
import Effect
import Data.Function.Uncurried (runFn2, runFn1, Fn2, Fn1)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(Just, Nothing))
import Prelude (class Eq, class Show, Unit, bind, pure, (=<<))
import Web.Event.Event (Event, EventType)
import Web.Event.EventTarget (EventListener, eventListener, EventTarget)
import Web.Event.EventTarget as ET
-------------------------------------------------------------------------------


-- | EventSource class. Inherits from EventTarget
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

derive instance genericReadyState :: Generic ReadyState _
derive instance eqReadyState :: Eq ReadyState

instance showReadyState :: Show ReadyState where
  show = genericShow


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
readyState :: EventSource -> Effect ReadyState
readyState (EventSource target) = do
  state <- runFn1 readyStateImpl target
  pure case state of
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
newEventSource :: URL -> Maybe EventSourceConfig -> Effect EventSource
newEventSource (URL s) Nothing = runFn1 newEventSourceImpl1 s
newEventSource (URL s) (Just c) = runFn2 newEventSourceImpl2 s c


-------------------------------------------------------------------------------
-- | Destructively overwrites the onerror callback for the EventSource
setOnError
    :: EventSource
    -> (Event -> Effect Unit)
    -> Effect Unit
setOnError = cbHelper setOnErrorImpl


-------------------------------------------------------------------------------
-- | Destructively overwrites the onmessage callback for the EventSource
setOnMessage
    :: EventSource
    -> (Event -> Effect Unit)
    -> Effect Unit
setOnMessage = cbHelper setOnMessageImpl


-------------------------------------------------------------------------------
-- | Destructively overwrites the onopen callback for the EventSource
setOnOpen
    :: EventSource
    -> (Event -> Effect Unit)
    -> Effect Unit
setOnOpen = cbHelper setOnOpenImpl


-------------------------------------------------------------------------------
cbHelper
    :: Fn2 EventSource EventListener (Effect Unit)
    -> EventSource
    -> (Event -> Effect Unit)
    -> Effect Unit
cbHelper cb es l= runFn2 cb es =<< eventListener l


-------------------------------------------------------------------------------
-- | Inherited from EventTarget. EventType corresponds to the
-- domain-specific type of event sent from the server.
addEventListener
    :: EventType
    -> (Event -> Effect Unit)
    -> Boolean
    -- ^ Indicates whether the listener should be added for the "capture" phase.
    -> EventSource
    -> Effect Unit
addEventListener ty l useCapture (EventSource target) = do
  l' <- eventListener l
  ET.addEventListener ty l' useCapture target


-------------------------------------------------------------------------------
-- | Inherited from EventTarget. EventType corresponds to the
-- domain-specific type of event sent from the server.
removeEventListener
    :: EventType
    -> (Event -> Effect Unit)
    -> Boolean
    -- ^ Indicates whether the listener should be added for the "capture" phase.
    -> EventSource
    -> Effect Unit
removeEventListener ty l useCapture (EventSource target) = do
  l' <- eventListener l
  ET.removeEventListener ty l' useCapture target


-------------------------------------------------------------------------------
-- | Inherited from EventTarget. EventType corresponds to the
-- domain-specific type of event sent from the server.
dispatchEvent
    :: Event
    -> EventSource
    -> Effect Boolean
dispatchEvent e (EventSource target) = ET.dispatchEvent e target


-------------------------------------------------------------------------------
-- | Get the data from the event.
eventData :: Event -> String
eventData = runFn1 eventDataImpl

-- | Close the event source connection.
close :: EventSource -> Effect Unit
close = runFn1 closeImpl

-------------------------------------------------------------------------------
foreign import newEventSourceImpl1 :: Fn1 String (Effect EventSource)


-------------------------------------------------------------------------------
foreign import newEventSourceImpl2 :: Fn2 String EventSourceConfig (Effect EventSource)


-------------------------------------------------------------------------------
foreign import setOnErrorImpl :: Fn2 EventSource EventListener (Effect Unit)


-------------------------------------------------------------------------------
foreign import setOnMessageImpl :: Fn2 EventSource EventListener (Effect Unit)


-------------------------------------------------------------------------------
foreign import setOnOpenImpl :: Fn2 EventSource EventListener (Effect Unit)


-------------------------------------------------------------------------------
foreign import eventDataImpl :: Fn1 Event String


-------------------------------------------------------------------------------
foreign import readyStateImpl :: Fn1 EventTarget (Effect Int)


-------------------------------------------------------------------------------
foreign import withCredentialsImpl :: Fn1 EventTarget Boolean


-------------------------------------------------------------------------------
foreign import urlImpl :: Fn1 EventTarget String


-------------------------------------------------------------------------------
foreign import closeImpl :: Fn1 EventSource (Effect Unit)
