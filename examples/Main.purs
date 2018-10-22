-- | Works with the example server in this project
module Main
    ( main
    ) where


-------------------------------------------------------------------------------
import Effect (Effect)
import Effect.Class.Console (logShow)
import Web.Event.Event (Event, EventType(EventType), timeStamp)
import Data.Maybe (Maybe(Nothing))
import Data.Tuple (Tuple(Tuple))
import Network.EventSource (addEventListener, URL(URL), eventData, readyState, setOnError, setOnOpen, setOnMessage, newEventSource, url)
import Prelude (Unit, bind, discard, (<>), show)
-------------------------------------------------------------------------------


main :: Effect Unit
main = do
  es <- newEventSource (URL "/stream") Nothing
  rs <- readyState es
  logShow rs
  logShow (url es)
  setOnOpen es handleOpen
  setOnError es handleError
  setOnMessage es handleMessage
  addEventListener (EventType "boop") handleBoop false es


-------------------------------------------------------------------------------
handleOpen :: Event -> Effect Unit
handleOpen ev = logShow ("Connection is open (" <> show (timeStamp ev) <> ").")


-------------------------------------------------------------------------------
handleError :: Event -> Effect Unit
handleError ev = logShow ("EventSource failed (" <> show (timeStamp ev) <> ").")


-------------------------------------------------------------------------------
handleMessage :: Event -> Effect Unit
handleMessage = handle "message"


-------------------------------------------------------------------------------
handleBoop :: Event -> Effect Unit
handleBoop = handle "boop"


-------------------------------------------------------------------------------
handle :: String -> Event -> Effect Unit
handle tag e = logShow (Tuple tag (eventData e))
