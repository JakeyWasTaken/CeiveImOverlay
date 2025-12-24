return function(ImOverlay, _)
    for i = 1, 10 do
        ImOverlay:Begin(`Recursive {i}`, i == 5 and Color3.new(math.sin(os.clock()) ^ 2) or nil)
    end

    ImOverlay:Text("Im ontop of the world!")

    for _ = 1, 10 do
        ImOverlay:End()
    end
end
