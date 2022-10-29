-- had made this in like 2 minutes

local ChunkUtil = require(game:GetService("ReplicatedStorage").LargeFramework.Modules3.ChunkUtil)

local MineBlock = game:GetService("ReplicatedStorage").Events.MineBlock

local playerPosition = ChunkUtil.worldToCell(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position)
for i = 1, 27 do -- // mine 3x3x3 area
    local currentBlock = playerPosition + Vector3.new(i % 3 - 1, math.floor(i / 3) % 3 - 1, math.floor(i / 9) - 1)
    MineBlock:FireServer(currentBlock)
end
