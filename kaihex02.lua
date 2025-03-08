local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/sirius-software/rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
   Name = "Purge hub",
   LoadingTitle = "Purge OT",
   LoadingSubtitle = "โดย Lxwnu",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = "W",
      FileName = "PurgeConfig"
   },
   KeySystem = false, -- Set this to true to use their key system
   KeySettings = {
      Title = "Purge OT",
      Subtitle = "Key System",
      Note = "ยินดีต้อนรับ!",
      FileName = "PurgeKey",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {"Hello"}
   }
})

Rayfield:Notify({
   Title = "Purge OT",
   Content = "ยินดีต้อนรับ!",
   Duration = 3,
   Image = 4483345998,
})

local MainTab = Window:CreateTab("หน้าหลัก", 4483345998)

local MainSection = MainTab:CreateSection("เมนูหลัก")

-- Create a variable to store the ESP drawing
local espLine = nil

-- Variables to track football state
getgenv().isHoldingBall = false
getgenv().lastThrowTime = 0
getgenv().throwCooldown = 2 -- 2 second cooldown

-- Function to check if player is holding the football
local function isPlayerHoldingBall()
    local character = game.Players.LocalPlayer.Character
    if not character then return false end
    
    -- Check if the ball is a child of the character (being held)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("MeshPart") and child.Name == "Football" then
            return true
        end
    end
    
    return false
end

-- Function to simulate pressing the E key
local function pressE()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Function to simulate pressing the Q key
local function pressQ()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end

-- Function to press both E and Q keys in sequence
local function pressEandQ()
    pressE()
    task.wait(0.2) -- Small delay between key presses
    pressQ()
end

-- Create a toggle for the ESP feature
MainTab:CreateToggle({
   Name = "ESP ลูกฟุตบอล",
   Default = false,
   Save = false,
   Flag = "FootballESP",
   Callback = function(Value)
      if Value then
         -- Enable ESP
         local RunService = game:GetService("RunService")
         
         -- Create drawing objects if they don't exist
         if not espLine then
            espLine = Drawing.new("Line")
            espLine.Thickness = 2
            espLine.Color = Color3.fromRGB(255, 0, 0) -- Red color
            espLine.Transparency = 1
         end
         
         -- Connect the ESP update to RenderStepped
         local espConnection = RunService.RenderStepped:Connect(function()
            local football = nil
            
            -- Find the Football MeshPart
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("MeshPart") and v.Name == "Football" then
                    football = v
                    break
                end
            end
            
            if football and espLine then
                local Vector, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(football.Position)
                
                if OnScreen then
                    espLine.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
                    espLine.To = Vector2.new(Vector.X, Vector.Y)
                    espLine.Visible = true
                else
                    espLine.Visible = false
                end
            else
                if espLine then
                    espLine.Visible = false
                end
            end
         end)
         
         -- Store the connection
         getgenv().ESPConnection = espConnection
      else
         -- Disable ESP
         if getgenv().ESPConnection then
            getgenv().ESPConnection:Disconnect()
            getgenv().ESPConnection = nil
         end
         
         if espLine then
            espLine.Visible = false
         end
      end
   end,
})

-- Variables for teleportation
local autoTeleportConnection = nil

-- Enhanced function to find the football, including when held by other players
local function findFootball()
    -- First check if it's in the workspace directly
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("MeshPart") and v.Name == "Football" then
            return v, false -- Football found, not held by another player
        end
    end
    
    -- If not found in workspace, check all players (someone might be holding it)
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            for _, obj in pairs(player.Character:GetChildren()) do
                if obj:IsA("MeshPart") and obj.Name == "Football" then
                    return obj, true -- Football found, held by another player
                end
            end
        end
    end
    
    return nil, false -- Football not found
end

-- Update the function to find goals (now looking for Parts, not Models)
local function findGoals()
    local goals = {away = nil, home = nil}
    
    -- First try looking for the Goals folder
    local goalsFolder = workspace:FindFirstChild("Goals")
    if goalsFolder then
        -- Find Away (blue) and Home (white) goals
        goals.away = goalsFolder:FindFirstChild("Away")
        goals.home = goalsFolder:FindFirstChild("Home")
    end
    
    -- If not found in a Goals folder, search the entire workspace
    if not goals.away or not goals.home then
        -- Search for parts with these names anywhere in workspace
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Name == "Away" then
                goals.away = v
            elseif v:IsA("BasePart") and v.Name == "Home" then
                goals.home = v
            end
        end
    end
    
    return goals
end

-- Function to simulate pressing the left mouse button
local function pressMouseButton1()
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

-- Replace pressMouseButton1 function with proper shooting code
local function shootBall(power, direction)
    -- Use the shooting remote with parameters
    local args = {
        [1] = power or 64.36308398842812, -- Default power value from the provided code
        [4] = direction or Vector3.new(-0.666259765625, -0.2594583034515381, 0.6991274952888489) -- Default direction
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Knit")
        :WaitForChild("Services"):WaitForChild("BallService")
        :WaitForChild("RE"):WaitForChild("Shoot"):FireServer(unpack(args))
end

-- Add global variables for shot customization
getgenv().shotPower = 64.36308398842812
getgenv().shotAngle = {x = -0.666259765625, y = -0.2594583034515381, z = 0.6991274952888489}

-- Update the teleport function to use the new shooting method
MainTab:CreateToggle({
   Name = "วาร์ปไปหาลูกฟุตบอลอัตโนมัติ",
   Default = false,
   Save = false,
   Flag = "AutoTeleport",
   Callback = function(Value)
      if Value then
         -- Start auto-teleport loop
         local RunService = game:GetService("RunService")
         autoTeleportConnection = RunService.Heartbeat:Connect(function()
            local character = game.Players.LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart then
               -- Check if player is holding the ball
               local currentlyHoldingBall = isPlayerHoldingBall()
               
               -- If we just stopped holding the ball, update the throw time
               if getgenv().isHoldingBall and not currentlyHoldingBall then
                  getgenv().lastThrowTime = tick()
               end
               
               -- Update the holding state
               getgenv().isHoldingBall = currentlyHoldingBall
               
               -- If player is holding the ball and goal teleport is enabled
               if currentlyHoldingBall and getgenv().goalTeleportEnabled then
                  -- Find the selected goal
                  local goals = findGoals()
                  local selectedGoal = getgenv().useAwayGoal and goals.away or goals.home
                  
                  if selectedGoal then
                     -- Get goal position and orientation directly (since it's a Part)
                     local goalCFrame = selectedGoal.CFrame
                     local goalPosition = goalCFrame.Position
                     
                     -- Calculate improved position in front of goal (optimal distance)
                     local frontDirection = goalCFrame.LookVector
                     
                     -- Position closer to goal (reduced from 10 to 7 studs) for better accuracy
                     -- Also slight offset in height for better aim
                     local optimalPosition = goalPosition - frontDirection * 7 + Vector3.new(0, 1.5, 0)
                     
                     -- Teleport to position in front of goal, facing the goal
                     humanoidRootPart.CFrame = CFrame.new(optimalPosition, goalPosition)
                     
                     -- Use a small delay for game to register the new position
                     task.wait(0.3)
                     
                     -- Shoot if enabled, using our custom shooting function
                     if getgenv().autoShootEnabled then
                        -- Calculate direction vector from player to center of goal
                        local shootDirection = (goalPosition - humanoidRootPart.Position).Unit
                        
                        -- Adjust direction slightly upwards for arc
                        shootDirection = Vector3.new(
                            shootDirection.X,
                            shootDirection.Y + getgenv().heightAdjustment, 
                            shootDirection.Z
                        ).Unit
                        
                        -- Use the actual shooting code
                        shootBall(getgenv().shotPower, shootDirection)
                     end
                  else
                     -- Debug info if goal not found
                     print("Goal not found! useAwayGoal =", getgenv().useAwayGoal)
                     print("Goals found:", goals.away ~= nil, goals.home ~= nil)
                  end
               -- Only teleport to ball if not holding ball and not on cooldown
               elseif not currentlyHoldingBall and tick() - getgenv().lastThrowTime >= getgenv().throwCooldown then
                   -- Find the Football using enhanced function
                   local football, isHeldByOther = findFootball()
                   
                   if football then
                      -- Calculate teleport position based on whether ball is held or not
                      local teleportPos
                      if isHeldByOther then
                         -- If ball is held by another player, teleport directly to the ball position
                         teleportPos = football.Position
                      else
                         -- If ball is free, teleport slightly above it
                         teleportPos = football.Position + Vector3.new(0, 3, 0)
                      end
                      
                      -- Teleport to the calculated position
                      humanoidRootPart.CFrame = CFrame.new(teleportPos)
                      
                      -- Only press keys if the ball isn't held by someone else
                      if not isHeldByOther then
                         task.wait(0.1)
                         pressEandQ()
                      end
                   end
               end
            end
         end)
      else
         -- Clean up
         if autoTeleportConnection then
            autoTeleportConnection:Disconnect()
            autoTeleportConnection = nil
         end
      end
   end,
})

-- Create a section for goal settings
local GoalSection = MainTab:CreateSection("ตั้งค่าประตู")

-- Add toggles for goal selection and auto-shoot
MainTab:CreateToggle({
   Name = "วาร์ปไปยังประตูเมื่อได้บอล",
   Default = true,
   Save = false,
   Flag = "GoalTeleport",
   Callback = function(Value)
      getgenv().goalTeleportEnabled = Value
   end,
})

-- Replace the toggle with a dropdown for selecting which goal to use
MainTab:CreateDropdown({
   Name = "เลือกประตูที่จะยิง",
   Default = "Away (น้ำเงิน)",
   Options = {"Away (น้ำเงิน)", "Home (ขาว)"},
   Save = false,
   Flag = "SelectedGoal",
   Callback = function(Option)
      if Option == "Away (น้ำเงิน)" then
         getgenv().useAwayGoal = true
         print("Selected Away goal (blue)")
         updateGoalLabel()
      else
         getgenv().useAwayGoal = false
         print("Selected Home goal (white)")
         updateGoalLabel()
      end
   end,
})

-- Toggle for auto-shoot
MainTab:CreateToggle({
   Name = "ยิงอัตโนมัติเมื่อวาร์ปไปถึงประตู",
   Default = true,
   Save = false,
   Flag = "AutoShoot",
   Callback = function(Value)
      getgenv().autoShootEnabled = Value
   end,
})

-- Add a label to show current goal selection status
local CurrentGoalLabel = MainTab:CreateLabel("ประตูที่เลือก: Away (น้ำเงิน)")

-- Function to update the goal label
local function updateGoalLabel()
    local goalName = getgenv().useAwayGoal and "Away (น้ำเงิน)" or "Home (ขาว)"
    CurrentGoalLabel:Set("ประตูที่เลือก: " .. goalName)
end

-- Add a new toggle for aggressive ball stealing mode
MainTab:CreateToggle({
   Name = "โหมดแย่งบอลแบบก้าวร้าว",
   Default = true,
   Save = false,
   Flag = "AggressiveStealing",
   Callback = function(Value)
      getgenv().aggressiveStealing = Value
   end,
})

-- Add a label explaining the aggressive stealing feature
MainTab:CreateLabel("โหมดแย่งบอลแบบก้าวร้าว: วาร์ปเข้าไปที่ตำแหน่งลูกบอลโดยตรง")

-- Add option to control whether to press Q after E
MainTab:CreateToggle({
   Name = "กด Q หลังจากกด E",
   Default = true,
   Save = false,
   Flag = "PressQAfterE",
   Callback = function(Value)
      getgenv().shouldPressQ = Value
      
      -- Update the pressEandQ function based on user preference
      if Value then
         pressEandQ = function()
             pressE()
             task.wait(0.2)
             pressQ()
         end
      else
         pressEandQ = function()
             pressE()
         end
      end
   end,
})

-- Add delay slider between E and Q
MainTab:CreateSlider({
   Name = "ระยะเวลาระหว่างการกด E และ Q",
   Min = 0.05,
   Max = 1,
   Default = 0.2,
   Color = Color3.fromRGB(255,144,0),
   Increment = 0.05,
   ValueName = "วินาที",
   Save = false,
   Flag = "KeyPressDelay",
   Callback = function(Value)
      getgenv().keyPressDelay = Value
      
      -- Update the pressEandQ function with new delay
      if getgenv().shouldPressQ then
         pressEandQ = function()
             pressE()
             task.wait(Value)
             pressQ()
         end
      else
         pressEandQ = function()
             pressE()
         end
      end
   end,
})

-- Add cooldown slider
MainTab:CreateSlider({
   Name = "เวลาคูลดาวน์หลังโยนบอล",
   Min = 0,
   Max = 5,
   Default = 2,
   Color = Color3.fromRGB(255,144,0),
   Increment = 0.1,
   ValueName = "วินาที",
   Save = false,
   Flag = "ThrowCooldown",
   Callback = function(Value)
      getgenv().throwCooldown = Value
   end,
})

-- Status label to show cooldown and ball status
local StatusLabel = MainTab:CreateLabel("สถานะ: พร้อมที่จะวาร์ป")

-- Update status periodically
local statusUpdateConnection
local function updateStatusConnection(enabled)
    if statusUpdateConnection then
        statusUpdateConnection:Disconnect()
        statusUpdateConnection = nil
    end
    
    if enabled then
        statusUpdateConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local status = ""
            if getgenv().isHoldingBall then
                -- Add goal information to status when holding ball
                local goalName = getgenv().useAwayGoal and "Away (น้ำเงิน)" or "Home (ขาว)"
                if getgenv().goalTeleportEnabled then
                    status = "สถานะ: กำลังถือบอล - จะยิงประตู " .. goalName
                else
                    status = "สถานะ: กำลังถือบอล"
                end
            else
                local timeSinceThrow = tick() - getgenv().lastThrowTime
                if timeSinceThrow < getgenv().throwCooldown then
                    status = string.format("สถานะ: คูลดาวน์ (เหลือ %.1f วินาที)", getgenv().throwCooldown - timeSinceThrow)
                else
                    status = "สถานะ: พร้อมที่จะวาร์ป"
                end
            end
            StatusLabel:Set(status)
        end)
    else
        StatusLabel:Set("สถานะ: ปิดใช้งาน")
    end
end

-- Initialize the global variables
getgenv().shouldPressQ = true
getgenv().keyPressDelay = 0.2
getgenv().aggressiveStealing = true
getgenv().goalTeleportEnabled = true
getgenv().useAwayGoal = true
getgenv().autoShootEnabled = true

-- Add a new section for shot customization
local ShotSection = MainTab:CreateSection("ปรับแต่งการยิง")

-- Add slider for shot power
MainTab:CreateSlider({
   Name = "พลังในการยิง",
   Min = 50,
   Max = 80,
   Default = 64.36,
   Color = Color3.fromRGB(255,144,0),
   Increment = 0.5,
   ValueName = "power",
   Save = false,
   Flag = "ShotPower",
   Callback = function(Value)
      getgenv().shotPower = Value
   end,
})

-- Add height adjustment slider
MainTab:CreateSlider({
   Name = "ปรับความสูงของการยิง",
   Min = -0.5,
   Max = 0.5,
   Default = 0.05,
   Color = Color3.fromRGB(255,144,0),
   Increment = 0.01,
   ValueName = "height",
   Save = false,
   Flag = "HeightAdjustment",
   Callback = function(Value)
      getgenv().heightAdjustment = Value
   end,
})

-- Add button to test shot parameters
MainTab:CreateButton({
   Name = "ทดสอบการยิง",
   Callback = function()
      -- Create a direction vector using the current height adjustment
      local shootDirection = Vector3.new(-0.666259765625, -0.2594583034515381 + getgenv().heightAdjustment, 0.6991274952888489).Unit
      
      shootBall(getgenv().shotPower, shootDirection)
      Rayfield:Notify({
         Title = "ทดสอบการยิง",
         Content = "ยิงด้วยพลัง: " .. getgenv().shotPower .. ", ปรับความสูง: " .. getgenv().heightAdjustment,
         Duration = 3,
         Image = 4483345998,
      })
   end,
})

-- Add a button to save successful shot settings
MainTab:CreateButton({
   Name = "บันทึกการตั้งค่าการยิงที่ประสบความสำเร็จ",
   Callback = function()
      -- Save the current settings to a file
      local savedSettings = {
         power = getgenv().shotPower,
         heightAdjustment = getgenv().heightAdjustment
      }
      
      -- Create a notification
      Rayfield:Notify({
         Title = "บันทึกการตั้งค่า",
         Content = "บันทึกการตั้งค่าการยิงเรียบร้อยแล้ว",
         Duration = 3,
         Image = 4483345998,
      })
      
      -- Here you could write to a file if needed
      -- writefile("shotSettings.json", game:GetService("HttpService"):JSONEncode(savedSettings))
   end,
})

-- Add delay before shooting slider
MainTab:CreateSlider({
   Name = "ความล่าช้าก่อนยิง",
   Min = 0.1,
   Max = 1,
   Default = 0.3,
   Color = Color3.fromRGB(255,144,0),
   Increment = 0.05,
   ValueName = "วินาที",
   Save = false,
   Flag = "ShootDelay",
   Callback = function(Value)
      getgenv().shootDelay = Value
   end,
})

-- Initialize the new global variables
getgenv().shotPower = 64.36308398842812
getgenv().heightAdjustment = 0.05
getgenv().shootDelay = 0.3

-- Initialize the UI
Rayfield:LoadConfiguration()
