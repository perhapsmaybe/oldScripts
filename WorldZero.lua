-- got scammed after making this tbh

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profiles = ReplicatedStorage.Profiles

local PlayerProfile = Profiles[LocalPlayer.Name]
local PlayerInventory = PlayerProfile.Inventory
local PlayerEquipped = PlayerProfile.Equip 
local PlayerPet = PlayerEquipped.Pet

local Repository = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(Repository..'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(Repository..'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(Repository..'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'World // Zero',
    Center = true, 
    AutoShow = true,
})

local mainTab = Window:AddTab('Main')
local UISettings = Window:AddTab('UI Settings')

local mainGroupbox = mainTab:AddLeftGroupbox('Pets')
local menuSettings = UISettings:AddLeftGroupbox('Menu')

local autoFeed = mainGroupbox:AddToggle("autoFeed", {
    Text = "Auto Feed",
    Default = false,
    Tooltip = "Automatically feed your current equipped pet."
})

local stopOnPerks = mainGroupbox:AddToggle("stopOnPerks", {
    Text = "Stop on Perks",
    Default = false,
    Tooltip = "Stops feeding when you get the desired perks."
})


local petPerksData = {}
local displayPerks = {}
for i, v in pairs(getgc(true)) do 
    if typeof(v) == "table" and typeof(rawget(v, "PetFoodDrop")) == "table" then 
        for i1, v1 in pairs(v) do 
            if typeof(v1) ~= "table" or v1.Cooldown or v1 then continue end 
            if not petPerksData[i1] then 
                petPerksData[i1] = true
            end
        end
    end
end

for i, v in pairs(petPerksData) do 
    table.insert(displayPerks, i)
end

local petPerks = mainGroupbox:AddDropdown("petPerks", {
    Values = displayPerks,
    Default = 1,
    Multi = false,
    Text = "Pet Perks",
    Tooltip = "The perks you want to get on your pet."
})

local FeedPet = game:GetService("ReplicatedStorage").Shared.Pets.FeedPet

function feedPet()
    for i, v in pairs(PlayerInventory.Items:GetChildren()) do 
        if #v:GetChildren() ~= 2 then continue; end 
        
        FeedPet:FireServer(v, true)
    end
end
task.spawn(function()
    while true do 
        task.wait()

        if Toggles.autoFeed.Value then 
            if Toggles.stopOnPerks.Value then  
                local currentPet = PlayerPet:FindFirstChildWhichIsA("Folder")
                
                local Perk1 = currentPet:FindFirstChild("Perk1")
                local Perk2 = currentPet:FindFirstChild("Perk2")
                local Perk3 = currentPet:FindFirstChild("Perk3")

                local expectedValue = petPerksData[Options.petPerks.Value]
                if Perk1 and Perk1:IsA("StringValue") and Perk1.Value == expectedValue or Perk2 and Perk2:IsA("StringValue") and Perk2.Value == expectedValue or Perk3 and Perk3:IsA("StringValue") and Perk3.Value == expectedValue then 
                else 
                    feedPet()
                end
            else 
                feedPet()
            end 
        end
    end 
end)

Library:OnUnload(function()
    Library.Unloaded = true
end)

menuSettings:AddButton('Unload', function() Library:Unload() end)
menuSettings:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' }) 

Library.ToggleKeybind = Options.MenuKeybind 

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() 

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 

ThemeManager:SetFolder('Armonius')
SaveManager:SetFolder('Armonius/WorldZero')

SaveManager:BuildConfigSection(UISettings) 

ThemeManager:ApplyToTab(UISettings)
SaveManager:LoadAutoloadConfig()
