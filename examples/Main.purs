-- | Works with the example server in this project
module Main
    ( main
    ) where


-------------------------------------------------------------------------------
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, logShow)
import DOM (DOM)
import DOM.Event.Event (Event)
import DOM.Event.EventTarget (eventListener)
import DOM.Event.Types (EventType(EventType))
import Data.Maybe (Maybe(Nothing))
import Data.Tuple (Tuple(Tuple))
import Network.EventSource (addEventListener, URL(URL), eventData, readyState, setOnMessage, newEventSource, url)
import Prelude (Unit, bind, discard)
-------------------------------------------------------------------------------


main :: forall eff. Eff (dom :: DOM, console :: CONSOLE | eff) Unit
main = do
  es <- newEventSource (URL "/stream") Nothing
  logShow (readyState es)
  logShow (url es)
  setOnMessage es (eventListener handleMessage)
  addEventListener (EventType "boop") (eventListener handleBoop) false es


-------------------------------------------------------------------------------
handleMessage :: forall eff. Event -> Eff (dom :: DOM, console :: CONSOLE | eff) Unit
handleMessage = handle "message"


-------------------------------------------------------------------------------
handleBoop :: forall eff. Event -> Eff (dom :: DOM, console :: CONSOLE | eff) Unit
handleBoop = handle "boop"


-------------------------------------------------------------------------------
handle :: forall eff. String -> Event -> Eff (dom :: DOM, console :: CONSOLE | eff) Unit
handle tag e = logShow (Tuple tag (eventData e))
