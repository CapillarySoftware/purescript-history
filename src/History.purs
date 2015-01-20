module History
  ( getState
  , pushState
  , replaceState    
  
  , goBack
  , goForward
  , goState
  
  , subscribeStateChange
  
  , History()
  , State()
  , Url()
  , Title()
  , Delta()
  ) where

import Data.Foreign.EasyFFI
import Control.Monad.Eff
import Control.Reactive
import Control.Reactive.Event

type Title   = String

type Url     = String

type Delta   = Number

--- Record representing browser state 
--- Passed to and returned by history
type State d = 
  { data   :: d
  , title  :: Title 
  , url    :: Url    
  }

mkState :: forall d. d -> Title -> Url -> State d
mkState d t u = { title: t, url: u, data: d }

foreign import data History :: * -> !

getData :: forall eff d. Eff (history :: History d | eff) d
getData = unsafeForeignFunction [""] "window.history.state"

getTitle :: forall eff d. Eff (history :: History d | eff) Title 
getTitle = unsafeForeignFunction [""] "document.title"

getUrl :: forall eff d. Eff (history :: History d | eff) Url
getUrl = unsafeForeignFunction [""] "location.pathname"

getState :: forall eff d. Eff (history :: History d | eff) (State d)
getState = mkState <$> getData <*> getTitle <*> getUrl

stateUpdaterNative :: forall d eff. String ->
                      d       -> -- State.data
                      Title   -> -- State.title 
                      Url     -> -- State.url
                      Eff (history :: History d | eff) Unit
stateUpdaterNative x = unsafeForeignProcedure ["d", "title", "url", ""] $ x ++ "(d,title,url)"

statechange :: String
statechange = "statechange"

pushState :: forall d eff. State d -> Eff (history :: History d, reactive :: Reactive | eff) Unit
pushState s = pushState' s.data s.title s.url  
  where
  pushState' :: forall d eff. d -> Title -> Url -> Eff (history :: History d | eff) Unit
  pushState' = stateUpdaterNative "window.history.pushState"

replaceState :: forall d eff. State d -> Eff (history :: History d, reactive :: Reactive | eff) Unit
replaceState s = replaceState' s."data" s.title s.url
  where
  replaceState' :: forall d eff. d -> Title -> Url -> Eff (history :: History d | eff) Unit
  replaceState' = stateUpdaterNative "window.history.replaceState"

subscribeStateChange :: forall a b eff. 
                        (Event a -> Eff (reactive :: Reactive | eff) b) -> 
                        Eff (reactive :: Reactive | eff) Subscription
subscribeStateChange = subscribeEvented statechange

goBack :: forall d eff. Eff (history :: History d | eff) Unit
goBack = unsafeForeignFunction [""] "window.history.back()"

goForward :: forall d eff. Eff (history :: History d | eff) Unit
goForward = unsafeForeignFunction  [""] "window.history.forward()"

goState :: forall d eff. Delta -> Eff (history :: History d | eff) Unit
goState = unsafeForeignProcedure ["Δ",""] "window.history.go(Δ)"


