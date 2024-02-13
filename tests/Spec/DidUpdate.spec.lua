local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CeiveImOverlay = require(ReplicatedStorage:WaitForChild("CeiveImOverlay"))

return function()
    local ImOverlay = CeiveImOverlay.new()

    describe("Did Update", function()
        it("Should update, 2 different text objects", function()
            ImOverlay:Text("Hello")
            ImOverlay:Render()

            expect(ImOverlay.DidUpdate).to.equal(true)

            ImOverlay:Text("Hello 2")
            ImOverlay:Render()

            expect(ImOverlay.DidUpdate).to.equal(true)
        end)

        it("Shouldnt update, no objects", function()
            ImOverlay:Render()

            expect(ImOverlay.DidUpdate).to.equal(false)
        end)

        it("Shouldnt update, same state", function()
            ImOverlay:Text("Hello")
            ImOverlay:Render()
            ImOverlay:Text("Hello")
            ImOverlay:Render()

            expect(ImOverlay.DidUpdate).to.equal(false)
        end)
    end)
end
