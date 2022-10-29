-- drawing version of uilistlayout

local UIListLayout = {}

function UIListLayout.getObjectType(Object)
    local objectData = getrawmetatable(Object)
    if objectData then
        return objectData["__type"]
    end
end

function UIListLayout.getObjectSize(Object)
    local objectType = UIListLayout.getObjectType(Object)
    if objectType == "Text" then
        return Object.TextBounds
    end

    return Object.Size
end

function UIListLayout.createUIListLayout(Settings)
    -- // Set default settings 

    Settings = Settings or {}
    Settings.Padding = Settings.Padding or 3
    Settings.SortDirection = Settings.SortDirection or "Ascending" -- Ascending, Descending
    Settings.FillDirection = Settings.FillDirection or "Horizontal"

    Settings.Objects = {}
    
    if not Settings.Parent then return end;
    Settings.HorizontalAlignment = Settings.HorizontalAlignment or "Center"
    Settings.VerticalAlignment = Settings.VerticalAlignment or "Above"

    -- // monitor changes to settings and objects

    local newSettings = {}
    newSettings.Objects = {}
    setmetatable(newSettings, {
        __index = function(self, key)
            return rawget(Settings, key) 
        end,
        __newindex = function(self, key, value)
            rawset(Settings, key, value)
            UIListLayout.updateLayout(Settings)
        end
    })

    setmetatable(newSettings.Objects, {
        __newindex = function(self, key, value)
            rawset(Settings.Objects, key, value)
            UIListLayout.updateLayout(Settings)
        end
    })

    return newSettings
end

function UIListLayout.getObjectsSize(Objects, verticalAlignment)
    local totalObjectsSize = 0
    for i, v in pairs(Objects) do
        local currentSize = UIListLayout.getObjectSize(v) or v.Size
        totalObjectsSize = totalObjectsSize + currentSize[verticalAlignment == false and "X" or "Y"]
    end

    return totalObjectsSize
end

function UIListLayout.getCenterPosition(parentPosition, parentSize, layoutObjects, layoutObjectsCount, uiPadding, verticalAlignment) -- // parentposition is the x or y of the parent
    local objectPositions = {} -- // objectPositions is the x or y of the object
    local totalObjectsSize = UIListLayout.getObjectsSize(layoutObjects, verticalAlignment) -- // totalObjectsSize is the total size of all the objects

    local currentPosition = parentPosition + (parentSize / 2) - (totalObjectsSize / 2) - (uiPadding * (layoutObjectsCount/2))
    for i, v in pairs(layoutObjects) do
        local currentSize = UIListLayout.getObjectSize(v) or v.Size
        objectPositions[i] = currentPosition
        if not verticalAlignment then print(currentPosition) currentPosition = currentPosition + (currentSize.X + uiPadding) end 
    end

    return objectPositions
end

function UIListLayout.getAbovePosition(parentPosition, parentSize, layoutObjects, layoutObjectsCount, uiPadding, topPosition)
    local objectPositions = {}
    
    for i, v in pairs(layoutObjects) do
        local currentSize = UIListLayout.getObjectSize(v) or v.Size

        local newPosition = topPosition == "Above" and parentPosition - uiPadding - currentSize.Y or parentPosition + parentSize + uiPadding
        objectPositions[i] = newPosition
    end

    return objectPositions
end

function UIListLayout.getSidePosition(parentPosition, parentSize, layoutObjects, layoutObjectsCount, uiPadding, sideAlignment)
    local objectPositions = {}

    local currentPosition = sideAlignment == "Left" and parentPosition + uiPadding or parentPosition + parentSize
    for i, v in pairs(layoutObjects) do
        local currentSize = UIListLayout.getObjectSize(v) or v.Size
        objectPositions[i] = currentPosition

        currentPosition = sideAlignment == "Left" and currentPosition + (currentSize.X + uiPadding) or currentPosition + (currentSize.X + uiPadding)
    end

    return objectPositions
end

function UIListLayout.setObjectPositions(Axis, Objects, Positions)
    for i, v in pairs(Objects) do 
        local oldPosition = v.Position[Axis]
        local newPosition = Positions[i]
        if not newPosition then continue end;

        local newXPosition = Axis == "X" and newPosition or v.Position.X 
        local newYPosition = Axis == "Y" and newPosition or v.Position.Y
        v.Position = Vector2New(newXPosition, newYPosition)
    end 
end

function UIListLayout.updateLayout(Settings)
    local layoutParent = Settings.Parent
    local layoutObjects = Settings.Objects

    local parentPosition = layoutParent.Position 
    local parentSize = layoutParent.Size

    local parentPositionX = parentPosition.X
    local parentPositionY = parentPosition.Y

    local parentSizeX = parentSize.X
    local parentSizeY = parentSize.Y

    local uiPadding = Settings.Padding
    local HorizontalAlignment = Settings.HorizontalAlignment
    local VerticalAlignment = Settings.VerticalAlignment

    local layoutObjectsCount = #layoutObjects
    
    local objectPositionsX = HorizontalAlignment == "Center" and UIListLayout.getCenterPosition(parentPositionX, parentSizeX, layoutObjects, layoutObjectsCount, uiPadding, false) or UIListLayout.getSidePosition(parentPositionX, parentSizeX, layoutObjects, layoutObjectsCount, uiPadding, HorizontalAlignment)
    local objectPositionsY = VerticalAlignment == "Center" and UIListLayout.getCenterPosition(parentPositionY, parentSizeY, layoutObjects, layoutObjectsCount, uiPadding, true) or UIListLayout.getAbovePosition(parentPositionY, parentSizeY, layoutObjects, layoutObjectsCount, uiPadding, VerticalAlignment)

    UIListLayout.setObjectPositions("X", layoutObjects, objectPositionsX)
    UIListLayout.setObjectPositions("Y", layoutObjects, objectPositionsY)
end

-- example

local mainSquare = Drawing.new("Square")
mainSquare.Size = Vector2New(200, 300)
mainSquare.Position = Vector2New(500, 500)
mainSquare.Visible = true 
mainSquare.Filled = true 
mainSquare.Thickness = 0
mainSquare.Color = Color3.fromRGB(19, 130, 226)
mainSquare.Transparency = 0.5

local outlineSquare = Drawing.new("Square")
outlineSquare.Size = Vector2New(200, 300)
outlineSquare.Position = Vector2New(500, 500)
outlineSquare.Visible = true
outlineSquare.Filled = false
outlineSquare.Thickness = 1
outlineSquare.Color = Color3.fromRGB(0, 0, 0)

local aboveLayout = createUIListLayout({Parent = mainSquare, HorizontalAlignment = "Center", VerticalAlignment = "Above", Padding = 3})
local belowLayout = createUIListLayout({Parent = mainSquare, HorizontalAlignment = "Center", VerticalAlignment = "Below", Padding = 3})

local playerName = Drawing.new("Text")
playerName.Size = 24
playerName.Text = "perhapsbutinroblox"
playerName.Visible = true
playerName.Color = Color3.fromRGB(19, 130, 226)
playerName.OutlineColor = Color3.fromRGB(0, 0, 0)
playerName.Outline = true 

aboveLayout.Objects[1] = playerName

local playerDistance = Drawing.new("Text")
playerDistance.Size = 22
playerDistance.Text = "0m away |"
playerDistance.Visible = true
playerDistance.Color = Color3.fromRGB(19, 130, 226)
playerDistance.OutlineColor = Color3.fromRGB(0, 0, 0)
playerDistance.Outline = true 

belowLayout.Objects[1] = playerDistance

local playerHealth = Drawing.new("Text")
playerHealth.Size = 22
playerHealth.Text = "100/100 health"
playerHealth.Visible = true
playerHealth.Color = Color3.fromRGB(49, 173, 0)
playerHealth.OutlineColor = Color3.fromRGB(0, 0, 0)
playerHealth.Outline = true 

belowLayout.Objects[2] = playerHealth

wait(5)

mainSquare:Remove()
outlineSquare:Remove()
playerName:Remove()
playerDistance:Remove()
playerHealth:Remove()
