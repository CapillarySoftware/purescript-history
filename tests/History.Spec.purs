module History.Spec where

    --- NOTE THIS IS ONLY WORKS BECAUSE HISTORY CAN NOT BE RESET 
    --- SO TESTS HAVE SIDE EFFECTS, AND RELY ON EACH OTHER

import History
import Test.Mocha
import Test.Chai
import Control.Monad.Eff
import Control.Reactive.Event
import Control.Reactive.Timer

expectStateToMatch os = do
  ts <- getState
  expect os.url `toEqual` ts.url
  -- This works in Chrome but not PhantomJS
  -- expect os."data" `toDeepEqual` ts."data"

expectDetailStateToBe os e = do
  let d = unwrapEventDetail e
  expect d.state `toDeepEqual` os
  
spec = describe "History" $ do
  let os   = {title : "wowzers!",   url : "/foo", "data" : { foo : 1 }}
  let os'  = {title : "wowzers!!",  url : "/bar", "data" : { foo : 2 }}
  let os'' = {title : "wowzers!!!", url : "/baz", "data" : { foo : 3 }}
  
  it "initial state should have no title" $ do
    ts <- getState
    expect ts.title `toEqual` ""

  it "pushState should change the state" $ do
    pushState os
    expectStateToMatch os

  itAsync "pushState should fire statechange" $ \done -> do
    sub <- subscribeStateChange  \e -> do
      expectDetailStateToBe os' e
      itIs done
      return Unit
    pushState os'
    expectStateToMatch os'
    unsubscribe sub

  it "replaceState should change the state" $ do
    replaceState os''
    expectStateToMatch os''

  itAsync "replaceState should fire statechange" $ \done -> do 
    sub <- subscribeStateChange  \e -> do
      expectDetailStateToBe os e
      itIs done    
      return Unit
    replaceState os
    expectStateToMatch os
    unsubscribe sub

  itAsync "goBack should go back a state" $ \done -> do
    expectStateToMatch os
    pushState os'
    expectStateToMatch os'

    sub <- subscribeStateChange $ expectDetailStateToBe "back"
    goBack
    unsubscribe sub
    
    timeout 5 $ do
      expectStateToMatch os      
      itIs done

  itAsync "goForward should go forward a state" $ \done -> do
    expectStateToMatch os

    sub <- subscribeStateChange $ expectDetailStateToBe "forward"
    goForward
    unsubscribe sub

    timeout 5 $ do
      expectStateToMatch os'
      itIs done

  -- itAsync "go accepts a number to move in the state" $ \done -> do
  --   sub <- subscribeStateChange $ expectDetailStateToBe "goState(-1)"
  --   expectStateToMatch os'
    
  --   goState (-1)
    
  --   unsubscribe sub

  --   timeout 5 $ do
  --     expectStateToMatch os
  --     itIs done