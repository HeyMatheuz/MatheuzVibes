-- Made by geodude#2619
-- Thanks lolcat, kardin!

-- Modified by Oleksandr.M#2109 to go to gold first and pick it up, correctly initialize and be stoppable at any moment

if game.PlaceId ~= 6839171747 or game.ReplicatedStorage.GameData.Floor.Value ~= "Rooms" then
	game.StarterGui:SetCore("SendNotification", { Title = "Invalid Place"; Text = "The game detected appears to not be rooms. Please execute this while in rooms!" })
 
	local Sound = Instance.new("Sound")
	Sound.Parent = game.SoundService
	Sound.SoundId = "rbxassetid://550209561"
	Sound.Volume = 5
	Sound.PlayOnRemove = true
	Sound:Destroy()
 
	return
elseif workspace:FindFirstChild("PathFindPartsFolder") then
    game.StarterGui:SetCore("SendNotification", { Title = "Script restart detected"; Text = "If you are having issues and the bot is broken, please contact me! geodude#2619" })
 
	local Sound = Instance.new("Sound")
	Sound.Parent = game.SoundService
	Sound.SoundId = "rbxassetid://550209561"
	Sound.Volume = 5
	Sound.PlayOnRemove = true
	Sound:Destroy()
 
	return
end
 
local PathfindingService = game:GetService("PathfindingService")
local VirtualInputManager = game:GetService('VirtualInputManager')
local LocalPlayer = game.Players.LocalPlayer
local LatestRoom = game.ReplicatedStorage.GameData.LatestRoom
local UserInputService = game:GetService("UserInputService")
 
local Cooldown = false
 
if game.CoreGui:FindFirstChild("PathFindGUI") then
    game.CoreGui:FindFirstChild("PathFindGUI"):Destroy()
end
 
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PathFindGUI"
ScreenGui.Parent = game.CoreGui
 
local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = ScreenGui
 
TextLabel.Size = UDim2.new(0,350,0,100)
TextLabel.TextSize = 48
TextLabel.TextStrokeColor3 = Color3.new(1,1,1)
TextLabel.TextStrokeTransparency = 0
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "..."
 
local GC = getconnections or get_signal_cons
if GC then
    for i,v in pairs(GC(LocalPlayer.Idled)) do
        if v["Disable"] then
            v["Disable"](v)
        elseif v["Disconnect"] then
            v["Disconnect"](v)
        end
    end
end
 
local Folder = Instance.new("Folder")
Folder.Parent = workspace
Folder.Name = "PathFindPartsFolder"
 
if LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules:FindFirstChild("A90") then
    LocalPlayer.PlayerGui.MainUI.Initiator.Main_Game.RemoteListener.Modules.A90.Name = "lol" -- Fuck you A90
end
 
function getLocker()
    local Closest
 
    for i,v in pairs(workspace.CurrentRooms:GetDescendants()) do
        if v.Name == "Rooms_Locker" then
            if v:FindFirstChild("Door") and v:FindFirstChild("HiddenPlayer") then
                if v.HiddenPlayer.Value == nil then
                    if v.Door.Position.Y > -3 then -- Prevents going to the lower lockers in the room with the bridge 
                        if Closest == nil then
                            Closest = v.Door
                        else
                            if (LocalPlayer.Character.HumanoidRootPart.Position - v.Door.Position).Magnitude < (Closest.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                Closest = v.Door
                            end
                        end
                    end
                end
            end
        end
    end
    return Closest
end

function getGold()
    local Closest
    
    for dr = 0, 2, 1 do -- look several rooms behind (possible to miss some if path is close to the door)
        local iter_room = workspace.CurrentRooms[LatestRoom.Value - dr]
        if iter_room ~= nil then
            for i,v in pairs(iter_room:GetDescendants()) do
                if v.Name == "GoldPile" then
                    if v:FindFirstChild("Hitbox") then
                        local part = v.Hitbox.Part
                        if part.Position.Y > -5 then -- Prevents going to the lower gold piles in the room with the bridge 
                            if Closest == nil then
                                Closest = part
                            else
                                if (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude < (Closest.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude then
                                    Closest = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return Closest
end
 
function getPath()
    local Part
 
    local Entity = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
    if Entity and Entity.Main.Position.Y > -4 then
        Part = getLocker()
    else
        Part = getGold()
        if LatestRoom.Value == 1000 then
            if workspace.CurrentRooms[LatestRoom.Value]:FindFirstChild("RoomsDoor_Exit") then
                Part = workspace.CurrentRooms[LatestRoom.Value].RoomsDoor_Exit.Door
            end
        end
        if Part == nil then
            if workspace.CurrentRooms[LatestRoom.Value]:FindFirstChild("Door") then
                Part = workspace.CurrentRooms[LatestRoom.Value].Door.Door
            end
        end
    end
    return Part
end
 
local oldspeed = LocalPlayer.Character.Humanoid.WalkSpeed
local oldcollider = LocalPlayer.Character.Collision.Size
 
local rsconn = game:GetService("RunService").RenderStepped:connect(function()
    LocalPlayer.Character.HumanoidRootPart.CanCollide = false
    LocalPlayer.Character.Collision.CanCollide = false
    LocalPlayer.Character.Collision.Size = Vector3.new(8,LocalPlayer.Character.Collision.Size.Y,8)
 
    LocalPlayer.Character.Humanoid.WalkSpeed = 21
 
    local Path = getPath()
 
    local Entity = workspace:FindFirstChild("A60") or workspace:FindFirstChild("A120")
    if Entity then
        if Path then
            if Path.Parent.Name == "Rooms_Locker" then
                if Entity.Main.Position.Y > -20 then
                    if (LocalPlayer.Character.HumanoidRootPart.Position - Path.Position).Magnitude < 2 then
                        if LocalPlayer.Character.HumanoidRootPart.Anchored == false then
                            fireproximityprompt(Path.Parent.HidePrompt)
                        end
                    end
                end
            end
        end
        if Entity.Main.Position.Y < -20 then
            if LocalPlayer.Character.HumanoidRootPart.Anchored == true then
                LocalPlayer.Character:SetAttribute("Hiding", false)
            end
        end
    else
        if LocalPlayer.Character.HumanoidRootPart.Anchored == true then
            LocalPlayer.Character:SetAttribute("Hiding", false)
        end
    end
end)

local Working = true

local lrconn 
lrconn = LatestRoom:GetPropertyChangedSignal("Value"):Connect(function()
    TextLabel.Text = "Room: "..math.clamp(LatestRoom.Value, 1,1000)
 
    if LatestRoom.Value ~= 1000 then
        LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable
    else
		LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse
		Folder:ClearAllChildren()
		lrconn:Disconnect()
		rsconn:Disconnect()
	    LocalPlayer.Character.Humanoid.WalkSpeed = oldspeed
        LocalPlayer.Character.Collision.Size = oldcollider
		LocalPlayer.Character.Collision.CanCollide = true
		Working = false
		
        local Sound = Instance.new("Sound")
        Sound.Parent = game.SoundService
        Sound.SoundId = "rbxassetid://4590662766"
        Sound.Volume = 3
        Sound.PlayOnRemove = true
        Sound:Destroy()

        game.StarterGui:SetCore("SendNotification", { Title = "youtube.com/geoduude"; Text = "Thank you for using my script!" })
        return
    end
end)

LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.Scriptable

local connection
connection = UserInputService.InputBegan:Connect(function(inputObject: InputObject, gameProcessed:boolean)
	if gameProcessed then return end
	if inputObject.KeyCode == Enum.KeyCode.Z then
		Working = false
		connection:Disconnect()
		game.StarterGui:SetCore("SendNotification", { Title = "Stopped"; Text = "Execution stopped!" })
		LocalPlayer.DevComputerMovementMode = Enum.DevComputerMovementMode.KeyboardMouse
		Folder:Destroy()
		ScreenGui:Destroy()
		lrconn:Disconnect()
		rsconn:Disconnect()
	    LocalPlayer.Character.Humanoid.WalkSpeed = oldspeed
        LocalPlayer.Character.Collision.Size = oldcollider
		LocalPlayer.Character.Collision.CanCollide = true
	end	
end)

game.StarterGui:SetCore("SendNotification", { Title = "Notice!"; Text = "Press Z button to stop the script" })
 
local fuzzy = {0, -0.5, 0.5, -1, 1, -2, 2, -3, 3, -4, 4}
 
while Working do
 
    local Destination = getPath()
    
    local DestIsGold = (Destination.name == "Part" and Destination.Parent.Name == "Hitbox" and Destination.Parent.Parent.Name == "GoldPile")
    local DestIsExit = (Destination.name == "Door" and Destination.Parent.Name == "RoomsDoor_Exit")
    
    if (LocalPlayer.Character.HumanoidRootPart.Position - Destination.Position).Magnitude < 8 then
        if DestIsGold then
            fireproximityprompt(Destination.Parent.Parent.LootPrompt)
            Destination = getPath()
        end
        if DestIsExit then
            fireproximityprompt(Destination.EnterPrompt)
        end
    end
 
    local path = PathfindingService:CreatePath({ WaypointSpacing = 1, AgentRadius = 0.1, AgentHeight = 1, AgentCanJump = false })
    local src = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0,3,0)
    local dest = Destination.Position
    path:ComputeAsync(src, dest)
    
    if path.Status == Enum.PathStatus.NoPath then
        -- try fuzzy shift location to sides
        for ix, dx in pairs(fuzzy) do
            for iz, dz in pairs(fuzzy) do
                dest = Vector3.new(Destination.Position.X + dx, src.Y, Destination.Position.Z + dz)
                path:ComputeAsync(src, dest)
                if path.Status ~= Enum.PathStatus.NoPath then break end
            end
            if path.Status ~= Enum.PathStatus.NoPath then break end
        end
    end
    
    Folder:ClearAllChildren()
    local dpart = Instance.new("Part")
    dpart.Size = Vector3.new(2,2,2)
    dpart.Position = dest
    dpart.Shape = "Cylinder"
    dpart.Rotation = Vector3.new(0,0,90)
    dpart.Material = "SmoothPlastic"
    dpart.Anchored = true
    dpart.CanCollide = false
    dpart.Parent = Folder
    
    if path.Status ~= Enum.PathStatus.NoPath then

        local Waypoints = path:GetWaypoints()
 
        for _, Waypoint in pairs(Waypoints) do
            local part = Instance.new("Part")
            part.Size = Vector3.new(1,1,1)
            part.Position = Waypoint.Position
            part.Shape = "Cylinder"
            part.Rotation = Vector3.new(0,0,90)
            part.Material = "SmoothPlastic"
            part.Anchored = true
            part.CanCollide = false
            part.Parent = Folder
        end
 
        for _, Waypoint in pairs(Waypoints) do
            if LocalPlayer.Character.HumanoidRootPart.Anchored == false and Working == true then
                LocalPlayer.Character.Humanoid:MoveTo(Waypoint.Position)
                LocalPlayer.Character.Humanoid.MoveToFinished:Wait()
            end
        end
    end
end
