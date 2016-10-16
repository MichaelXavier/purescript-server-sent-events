-- | Works with the example server in this project
module Main
    ( main
    ) where


-------------------------------------------------------------------------------
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import DOM.Event.Event (Event)
import Data.Maybe (Maybe(Nothing))
import Network.EventSource (EVENTSOURCE, URL(URL), eventData, setOnMessage, newEventSource)
import Prelude ((<<<), Unit, bind)
-------------------------------------------------------------------------------


main :: forall eff. Eff (eventsource :: EVENTSOURCE | eff) Unit
main = do
  es <- newEventSource (URL "/stream") Nothing
  setOnMessage es handler


-------------------------------------------------------------------------------
handler :: forall eff. Event -> Eff (console :: CONSOLE | eff) Unit
handler = log <<< eventData
