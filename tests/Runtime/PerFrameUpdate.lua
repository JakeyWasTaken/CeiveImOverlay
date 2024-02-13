return function(ImOverlay, State)
    ImOverlay:Text(`Delta Time: {State.DeltaTime}`)
    ImOverlay:Text(`Fps: {1 / State.DeltaTime}`)
    ImOverlay:Text(`Did Update: {ImOverlay.DidUpdate}`)
end
