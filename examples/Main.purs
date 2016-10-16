-- | Works with the example server in this project
module Main
    ( main
    ) where


-------------------------------------------------------------------------------
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (logShow, CONSOLE, log)
import DOM (DOM)
import DOM.Event.Event (Event)
import DOM.Event.EventTarget (eventListener)
import Data.Maybe (Maybe(Nothing))
import Network.EventSource (URL(URL), eventData, readyState, setOnMessage, newEventSource, url)
import Prelude ((<<<), Unit, bind)
-------------------------------------------------------------------------------


main :: forall eff. Eff (dom :: DOM, console :: CONSOLE | eff) Unit
main = do
  es <- newEventSource (URL "/stream") Nothing
  logShow (readyState es)
  logShow (url es)
  setOnMessage es (eventListener handler)


-------------------------------------------------------------------------------
handler :: forall eff. Event -> Eff (dom :: DOM, console :: CONSOLE | eff) Unit
handler = log <<< eventData
