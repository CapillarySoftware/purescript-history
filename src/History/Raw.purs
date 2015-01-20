module History.Raw
  ( pushStateRaw
  , replaceStateRaw

  , goBackRaw
  , goForwardRaw
  , goStateRaw

  , mkState

  , History()
  , State()
  , Url()
  , Title()
  , Delta()

  ) where

import Data.Foreign.EasyFFI
import Control.Reactive
import Control.Reactive.Event
import Control.Monad.Eff

type Delta   = Number

type Title   = String

type Url     = String

--- Record representing browser state
--- Passed to and returned by history
type State d = { data   :: d
               , title  :: Title
               , url    :: Url }

stateUpdaterNative :: forall d eff. String ->
                                    d      -> -- State.data
                                    Title  -> -- State.title
                                    Url    -> -- State.url
                                    Eff (history :: History d | eff) Unit
stateUpdaterNative x = unsafeForeignProcedure ["d", "title", "url", ""] $ x ++ "(d,title,url)"

foreign import data History :: * -> !

mkState :: forall d. d -> Title -> Url -> State d
mkState d t u = { title: t, url: u, data: d }

pushStateRaw :: forall d eff. State d -> Eff (history :: History d, reactive :: Reactive | eff) Unit
pushStateRaw s = pushState' s.data s.title s.url
  where
  pushState' :: forall d eff. d -> Title -> Url -> Eff (history :: History d | eff) Unit
  pushState' = stateUpdaterNative "window.history.pushState"

replaceStateRaw :: forall d eff. State d -> Eff (history :: History d, reactive :: Reactive | eff) Unit
replaceStateRaw s = replaceState' s."data" s.title s.url
  where
  replaceState' :: forall d eff. d -> Title -> Url -> Eff (history :: History d | eff) Unit
  replaceState' = stateUpdaterNative "window.history.replaceState"

goBackRaw :: forall d eff. Eff (history :: History d | eff) Unit
goBackRaw = unsafeForeignFunction [""] "window.history.back()"

goForwardRaw :: forall d eff. Eff (history :: History d | eff) Unit
goForwardRaw = unsafeForeignFunction  [""] "window.history.forward()"

goStateRaw :: forall d eff. Delta -> Eff (history :: History d | eff) Unit
goStateRaw = unsafeForeignProcedure ["Δ",""] "window.history.go(Δ)"
