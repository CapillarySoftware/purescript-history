# Module Documentation

## Module History

### Types

    type Delta = Number

    data History :: * -> !

    type State d = { url :: Url, title :: Title, "data" :: d }

    type Title = String

    type Url = String


### Values

    getState :: forall eff d. Eff (history :: History d | eff) (State d)

    goBack :: forall d eff. Eff (history :: History d | eff) Unit

    goForward :: forall d eff. Eff (history :: History d | eff) Unit

    goState :: forall d eff. Delta -> Eff (history :: History d | eff) Unit

    pushState :: forall d eff. State d -> Eff (reactive :: Reactive, history :: History d | eff) Unit

    replaceState :: forall d eff. State d -> Eff (reactive :: Reactive, history :: History d | eff) Unit

    subscribeStateChange :: forall a b eff. (Event a -> Eff (reactive :: Reactive | eff) b) -> Eff (reactive :: Reactive | eff) Subscription



