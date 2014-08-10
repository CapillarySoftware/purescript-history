# Module Documentation

## Module History

### Types

    data History :: !

    type State d = { url :: Url, title :: Title, "data" :: {  | d } }


### Values

    getState :: forall eff d. Eff (history :: History | eff) (State d)

    subscribeStateChange :: forall a b eff. (Event a -> Eff (reactive :: Reactive | eff) b) -> Eff (reactive :: Reactive | eff) Subscription



