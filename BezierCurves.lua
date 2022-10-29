local bezierCurves = {}
local Vector2New = Vector2.new
local DrawingNew = Drawing.new
local mathpi = math.pi

local mathcos = math.cos 
local mathrad = math.rad 
local mathsin = math.sin 
function bezierCurves:draw2D(Position)
    local drawSquare = DrawingNew("Circle")
    drawSquare.Thickness = 1
    drawSquare.Color = Color3.fromRGB(0, 0, 0)
    drawSquare.Filled = true
    drawSquare.Radius = 1
    drawSquare.NumSides = 16
    drawSquare.Position = Position
    drawSquare.Visible = true

    return drawSquare
end

function bezierCurves:draw3D(Position)
    local drawPart = Instance.new("Part")
    drawPart.Anchored = true
    drawPart.CanCollide = false
    drawPart.Size = Vector3.new(1, 1, 1)
    drawPart.Position = Position
    drawPart.Transparency = 0
    drawPart.Parent = workspace

    return drawPart
end

-- Distance multiplier is between 2, 10
-- X Multiplier is between 1, 10
-- Y Multiplier is between 1, 10
function bezierCurves:create2dMidpoint(Point, Endpoint, XMultiplier, YMultiplier, DistanceMultiplier)
    local PointX = Point.X
    local PointY = Point.Y

    local EndpointX = Endpoint.X
    local EndpointY = Endpoint.Y

    local pointsDistance = (Point - Endpoint).magnitude / DistanceMultiplier
    local pointsAngle = math.atan2(EndpointY - PointY, EndpointX - PointX) * (180/mathpi) + 90

    local midpointX = (PointX + EndpointX) / XMultiplier
    local midpointY = (PointY + EndpointY) / YMultiplier

    if PointX > midpointX then midPointX = PointX elseif EndpointX < midpointX then midPointX = EndpointX end
    if PointY > midpointY then midPointY = PointY elseif EndpointY < midpointY then midPointY = EndpointY end

    local controlPoint = Vector2New(midpointX + pointsDistance * mathcos(mathrad(pointsAngle)), midpointY + pointsDistance * mathsin(mathrad(pointsAngle)))

    return controlPoint
end

function bezierCurves:create3dMidpoint(Point, Endpoint, XMultiplier, YMultiplier, ZMultiplier, DistanceMultiplier)
    local PointX = Point.X
    local PointY = Point.Y
    local PointZ = Point.Z

    local EndpointX = Endpoint.X
    local EndpointY = Endpoint.Y
    local EndpointZ = Endpoint.Z

    local pointsDistance = (Point - Endpoint).magnitude / DistanceMultiplier
    local pointsAngle = math.atan2(EndpointY - PointY, EndpointX - PointX) * (180/mathpi) + 90

    local midpointX = (PointX + EndpointX) / XMultiplier
    local midpointY = (PointY + EndpointY) / YMultiplier
    local midpointZ = (PointZ + EndpointZ) / ZMultiplier

    if PointX > midpointX then midPointX = PointX elseif EndpointX < midpointX then midPointX = EndpointX end
    if PointY > midpointY then midPointY = PointY elseif EndpointY < midpointY then midPointY = EndpointY end
    if PointZ > midpointZ then midPointZ = PointZ elseif EndpointZ < midpointZ then midPointZ = EndpointZ end

    local controlPoint = Vector3.new(midpointX + pointsDistance * mathcos(mathrad(pointsAngle)), midpointY + pointsDistance * mathsin(mathrad(pointsAngle)), midpointZ)

    return controlPoint
end

function bezierCurves:create2dQuadraticCurve(Point, Midpoint, Endpoint)
    local PointX = Point.X
    local PointY = Point.Y

    local MidpointX = Midpoint.X
    local MidpointY = Midpoint.Y

    local EndpointX = Endpoint.X
    local EndpointY = Endpoint.Y
    local function getPoint(t)
        local subtractedT = 1 - t 
        local subtractedpowerT = subtractedT ^ 2
        local powerT = t ^ 2
        local subtractedTtimesT =  2 * subtractedT * t

        local x = subtractedpowerT * PointX + subtractedTtimesT * MidpointX + powerT * EndpointX
        local y = subtractedpowerT * PointY + subtractedTtimesT * MidpointY + powerT * EndpointY
        return Vector2New(x, y)
    end

    local drawPoints = {}
    local function drawCurve(Accuracy)
        Accuracy = Accuracy or 0.01

        for t = 0, 1, Accuracy do
            task.spawn(function()
                local circleTime = getPoint(t)
                local Circle = self:draw2D(circleTime)
                
                drawPoints[t] = Circle
            end)
        end
    end

    local function removeDrawing()
        for circleTime, Circle in pairs(drawPoints) do
            Circle:Remove()
        end
    end

    local function updateDrawing()
        for circleTime, Circle in pairs(drawPoints) do
            Circle.Position = getPoint(circleTime)
        end
    end

    local function updateCurve(Point, Midpoint, Endpoint)
        PointX = Point.X
        PointY = Point.Y

        MidpointX = Midpoint.X
        MidpointY = Midpoint.Y

        EndpointX = Endpoint.X
        EndpointY = Endpoint.Y
    end

    return {getPoint = getPoint, drawCurve = drawCurve, updateDrawing = updateDrawing, updateCurve = updateCurve}
end

function bezierCurves:create3dQuadraticCurve(Point, Midpoint, Endpoint)
    local PointX = Point.X
    local PointY = Point.Y
    local PointZ = Point.Z

    local MidpointX = Midpoint.X
    local MidpointY = Midpoint.Y
    local MidpointZ = Midpoint.Z

    local EndpointX = Endpoint.X
    local EndpointY = Endpoint.Y
    local EndpointZ = Endpoint.Z
    local function getPoint(t)
        local subtractedT = 1 - t 
        local subtractedpowerT = subtractedT ^ 2
        local powerT = t ^ 2
        local subtractedTtimesT =  2 * subtractedT * t

        local x = subtractedpowerT * PointX + subtractedTtimesT * MidpointX + powerT * EndpointX
        local y = subtractedpowerT * PointY + subtractedTtimesT * MidpointY + powerT * EndpointY
        local z = subtractedpowerT * PointZ + subtractedTtimesT * MidpointZ + powerT * EndpointZ
        return Vector3.new(x, y, z)
    end

    local drawPoints = {}
    local function drawCurve(Accuracy)
        Accuracy = Accuracy or 0.01

        for t = 0, 1, Accuracy do
            task.spawn(function()
                local circleTime = getPoint(t)
                local Circle = self:draw3D(circleTime)
                
                drawPoints[t] = Circle
            end)
        end
    end

    local function removeDrawing()
        for circleTime, Circle in pairs(drawPoints) do
            Circle:Destroy()
        end
    end

    local function updateDrawing()
        for circleTime, Circle in pairs(drawPoints) do
            Circle.Position = getPoint(circleTime)
        end
    end

    local function updateCurve(Point, Midpoint, Endpoint)
        PointX = Point.X
        PointY = Point.Y
        PointZ = Point.Z

        MidpointX = Midpoint.X
        MidpointY = Midpoint.Y
        MidpointZ = Midpoint.Z

        EndpointX = Endpoint.X
        EndpointY = Endpoint.Y
        EndpointZ = Endpoint.Z
    end

    return {getPoint = getPoint, drawCurve = drawCurve, updateDrawing = updateDrawing, updateCurve = updateCurve}
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local playerMouse = UserInputService:GetMouseLocation()
local targetPosition = workspace.CurrentCamera.ViewportSize / 2

local quadCurve = bezierCurves:create2dQuadraticCurve(playerMouse, bezierCurves:get2dMidpoint(playerMouse, targetPosition), targetPosition)

quadCurve.drawCurve(0.001)

local updateCurve = quadCurve.updateCurve
local updateDrawing = quadCurve.updateDrawing

local controlPoint = Drawing.new("Square")
controlPoint.Thickness = 1
controlPoint.Color = Color3.fromRGB(0, 0, 255)
controlPoint.Filled = true
controlPoint.Size = Vector2.new(15, 15)
controlPoint.Visible = true

RunService.RenderStepped:Connect(function()
    playerMouse = UserInputService:GetMouseLocation()
    targetPosition = workspace.CurrentCamera.ViewportSize / 2

    local midPoint = bezierCurves:create2dMidpoint(playerMouse, targetPosition, 2, 2, 4)

    controlPoint.Position = midPoint
    updateCurve(playerMouse, midPoint, targetPosition)
    updateDrawing()
end)

-- // 3d quadratic curve

local playerPosition = workspace.CurrentCamera.CFrame.Position
local targetPosition = game.Players.Gigachad612.Character.HumanoidRootPart.Position

local quadCurve3d = bezierCurves:create3dQuadraticCurve(playerPosition, bezierCurves:create3dMidpoint(playerPosition, targetPosition, 2, 2, 2, 2), targetPosition)
quadCurve3d.drawCurve(0.001)
