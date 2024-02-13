return function(ImOverlay, _)
    for i = 1, 10 do
        ImOverlay:Begin(`Recursive {i}`)
    end

    ImOverlay:Text("Im ontop of the world!")

    for _ = 1, 10 do
        ImOverlay:End()
    end
end
