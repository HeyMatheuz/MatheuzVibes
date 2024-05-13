-- Create a ScreenGui to hold the draggable GUI
local gui = Instance.new("ScreenGui")
gui.Parent = game.Players.LocalPlayer.PlayerGui

-- Create a Frame for the draggable GUI
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(52, 73, 94)
frame.BackgroundTransparency = 0.5
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Create a TextLabel to display instructions
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(1, 0, 0.5, 0)
textLabel.Position = UDim2.new(0, 0, 0, 0)
textLabel.BackgroundTransparency = 1
textLabel.Text = "Drag this GUI to move it!"
textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textLabel.TextSize = 20
textLabel.Font = Enum.Font.SourceSansBold
textLabel.Parent = frame

-- Create a TextButton as the toggle button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 0.5, 0)
toggleButton.Position = UDim2.new(0, 0, 0.5, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 20
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Text = "Toggle Jump"
toggleButton.Parent = frame

-- Variables for jump functionality
local isJumping = false
local jumpDelay = 5 -- Customize jump delay here (in seconds)

-- Function to make the character jump
local function jump()
    while isJumping do
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        wait(jumpDelay)
    end
end

-- Event to toggle jump on button click
toggleButton.MouseButton1Click:Connect(function()
    isJumping = not isJumping
    if isJumping then
        toggleButton.Text = "Stop Jump"
        toggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        jump()
    else
        toggleButton.Text = "Toggle Jump"
        toggleButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    end
end)

-- Update toggle button status continuously
game:GetService("RunService").Heartbeat:Connect(function()
    if isJumping then
        toggleButton.Text = "Stop Jump"
        toggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    else
        toggleButton.Text = "Toggle Jump"
        toggleButton.BackgroundColor3 = Color3.fromRGB(41, 128, 185)
    end
end)
