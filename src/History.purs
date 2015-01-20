module History
  ( getState
  , pushState
  , replaceState

  , goBack
  , goForward
  , goState

  , subscribeStateChange

  ) where

import History.Raw
import Data.Foreign.EasyFFI
import Control.Monad.Eff
import Control.Reactive
import Control.Reactive.Event
import Control.Apply((*>))

statechange :: String
statechange = "statechange"

(<%>) :: forall a b c eff. (a -> Eff eff b) -> (a -> Eff eff c) -> a -> Eff eff c
(<%>) x y a = x a *> y a

emitStateChange s = emit $ newEvent statechange { state : s }

getData :: forall eff d. Eff (history :: History d | eff) d
getData = unsafeForeignFunction [""] "window.history.state"

getTitle :: forall eff d. Eff (history :: History d | eff) Title
getTitle = unsafeForeignFunction [""] "document.title"

getUrl :: forall eff d. Eff (history :: History d | eff) Url
getUrl = unsafeForeignFunction [""] "location.pathname"

getState :: forall eff d. Eff (history :: History d | eff) (State d)
getState = mkState <$> getData <*> getTitle <*> getUrl

pushState :: forall d eff. State d -> Eff (reactive :: Reactive, history :: History d | eff) Unit
pushState = emitStateChange <%> pushStateRaw

replaceState :: forall d eff. State d -> Eff (reactive :: Reactive, history :: History d | eff) Unit
replaceState = emitStateChange <%> replaceStateRaw

goBack :: forall d eff. Eff (reactive :: Reactive, history :: History d | eff) Unit
goBack = emitStateChange "back" *> goBackRaw

goForward :: forall d eff. Eff (reactive :: Reactive, history :: History d | eff) Unit
goForward = emitStateChange "forward" *> goForwardRaw

goState :: forall d eff. Delta -> Eff (reactive :: Reactive, history :: History d | eff) Unit
goState = emitStateChange' <%> goStateRaw
  where emitStateChange' x = emitStateChange $ "goState(" ++ show x ++ ")"

subscribeStateChange :: forall a b eff.
                        (Event a -> Eff (reactive :: Reactive | eff) b) ->
                        Eff (reactive :: Reactive | eff) Subscription
subscribeStateChange = subscribeEvented statechange
