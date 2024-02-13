return function(ImOverlay, State)
    ImOverlay:Text("Rainbow!", Color3.new(math.cos(os.clock())^2, math.sin(os.clock() + math.pi / 2)^2, math.sin(os.clock())^2))
end
