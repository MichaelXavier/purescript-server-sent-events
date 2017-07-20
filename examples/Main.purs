-- | Works with the example server in this project
module Main
    ( main
    ) where


-------------------------------------------------------------------------------
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, logShow)
import DOM (DOM)
import DOM.Event.Event (Event, timeStamp)
import DOM.Event.Types (EventType(EventType))
import Data.Maybe (Maybe(Nothing))
import Data.Tuple (Tuple(Tuple))
import Network.EventSource (addEventListener, URL(URL), eventData, readyState, setOnError, setOnOpen, setOnMessage, newEventSource, url)
import Prelude (Unit, bind, discard, (<>), show)
-------------------------------------------------------------------------------


main :: forall eff. Eff (dom :: DOM, console :: CONSOLE | eff) Unit
main = do
  es <- newEventSource (URL "/stream") Nothing
  logShow (readyState es)
  logShow (url es)
  setOnOpen es handleOpen
  setOnError es handleError
  setOnMessage es handleMessage
  addEventListener (EventType "boop") handleBoop false es


-------------------------------------------------------------------------------
handleOpen :: forall eff. Event -> Eff (dom :: DOM, console :: CONSOLE | eff) Unit
handleOpen ev = logShow ("Connection is open (" <> show (timeStamp ev) <> ").")


-------------------------------------------------------------------------------
handleError :: forall eff. Event -> Eff (dom :: DOM, console :: CONSOLE | eff) Unit
handleError ev = logShow ("EventSource failed (" <> show (timeStamp ev) <> ").")


-------------------------------------------------------------------------------
handleMessage :: forall eff. Event -> Eff (dom :: DOM, console :: CONSOLE | eff) Unit
handleMessage = handle "message"


-------------------------------------------------------------------------------
handleBoop :: forall eff. Event -> Eff (dom :: DOM, console :: CONSOLE | eff) Unit
handleBoop = handle "boop"


-------------------------------------------------------------------------------
handle :: forall eff. String -> Event -> Eff (dom :: DOM, console :: CONSOLE | eff) Unit
handle tag e = logShow (Tuple tag (eventData e))
