local Network;
local NetworkScript = game:GetService("ReplicatedStorage").Modules.Shared.Network
for i, v in pairs(getgc(true)) do 
    if typeof(v) == "table" and typeof(rawget(v, "Network")) == "table" then 
        Network = v.Network 
    elseif typeof(v) == "function" and islclosure(v) and getfenv(v).script == NetworkScript then 
        local functionConstants = getconstants(v)
        if #functionConstants ~= 9 or getinfo(v).name ~= "" or functionConstants[9] ~= 0 or functionConstants[8] ~= "l" then continue end 

        setconstant(v, 9, math.huge)
        setconstant(v, 8, "s")
    end 
end

getgenv().Settings = {
    ['BodyPart'] = 'Head';
};
 
local Settings = getgenv().Settings;
local Players = game:GetService('Players');
local Player = Players.LocalPlayer;
local Camera = workspace.CurrentCamera;
local Mouse = Player:GetMouse();
local RunService = game:GetService('RunService');

local playersFolder = workspace.MapFolder.Players
local SecondaryObjects = workspace.MapFolder.Map.SecondaryObjects

function checkPart(shootPosition, PartPosition, ignoreTable, Character)
    local rayCast = Ray.new(shootPosition, (PartPosition - shootPosition).unit * 500)
    local Hit, Position, Normal = workspace:FindPartOnRayWithIgnoreList(rayCast, ignoreTable)
    if Hit and Hit:FindFirstAncestorWhichIsA("Model") == Character then return true end 

    return false 
end

function checkParts(shootPosition, ignoreTable, Character)
    local Parts = {"Head", "LeftLowerArm", "RightLowerArm", "HumanoidRootPart", "LeftLowerLeg", "RightLowerLeg"}
    for i, v in pairs(Parts) do
        local Part = Character:FindFirstChild(v)
        if not Part then continue end
        if checkPart(shootPosition, Part.Position, ignoreTable, Character) then return true, Part end
    end 

    return false
end

local function GetNearest(ignoreTable)
    for i, v in pairs(workspace.RaycastIgnore:GetChildren()) do 
        table.insert(ignoreTable, v)
    end

    local shootPosition = playersFolder[Player.Name].Weapon and playersFolder[Player.Name].Weapon:FindFirstChild("Object") and playersFolder[Player.Name].Weapon.Object:FindFirstChild("Muzzle") and playersFolder[Player.Name].Weapon.Object.Muzzle.Position
    if not shootPosition then return end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    for i, v in pairs(Players:GetPlayers()) do
        if (v == Player) or (v.SelectedTeam.Value == Player.SelectedTeam.Value) then continue end
        local Character = playersFolder:FindFirstChild(v.Name)
        if not Character then continue end

        local BodyPart = Character:FindFirstChild(Settings.BodyPart)
        if not BodyPart then continue end

        local Distance = (BodyPart.Position - shootPosition).Magnitude
        if Distance < closestDistance then
            local hitPart, Part = checkParts(shootPosition, ignoreTable, Character)
            if hitPart then
                closestPlayer = Part
                closestDistance = Distance
            end
        end
    end

    return closestPlayer
end
 
local function ResolveRotation(Target)
   return CFrame.new(Camera.CFrame['p'], Target.CFrame['p']);
end;
 
local function WTS(Object)
    local Screen = Camera:WorldToViewportPoint(Object)
    return Vector2.new(Screen.x, Screen.y);
end;

local oldFireServer = Network.FireServer
Network.FireServer = function(Self, Event, Arguments, ...)
    if Event == "FireBullet" then 
        local Nearest = GetNearest(Arguments[1].Ignore)
        
        if (not Nearest) then
            return oldFireServer(Self, Event, Arguments, ...)
        end
        
        local ResolvedRotation = ResolveRotation(Nearest);
        local OriginCFrame = ResolvedRotation;
        local RotationMatrix = Nearest.CFrame.Rotation
        if Arguments[1] and typeof(Arguments[1]) == "table" then -- // multiple bullets
            for i, v in pairs(Arguments) do 
                if not typeof(v) == "table" then continue end
                v.OriginCFrame = OriginCFrame
                v.RotationMatrix = RotationMatrix
            end 
        end;
    end

    return oldFireServer(Self, Event, Arguments, ...)
end
