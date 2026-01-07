--// Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// Save values (anti reset)
_G.MiyuSettings = {
	WalkSpeed = 16,
	JumpPower = 50
}

--// Window
local Window = Rayfield:CreateWindow({
	Name = "💠 Miyu Script Hub | Server 💠",
	LoadingTitle = "🎲Miyu Hub",
	LoadingSubtitle = "By MiyuKasumi",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "MiyuHub",
		FileName = "MainConfig"
	},
	Discord = { Enabled = false },
	KeySystem = false
})

--// Anti reset when respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	task.wait(0.3)
	hum.WalkSpeed = _G.MiyuSettings.WalkSpeed
	hum.JumpPower = _G.MiyuSettings.JumpPower
end)

--// Notify
Rayfield:Notify({
	Title = "Executed Successfully",
	Content = "Enjoy Miyu Hub 💖",
	Duration = 5
})

--// ===== MAIN TAB =====
local MainTab = Window:CreateTab("💠 Main")
MainTab:CreateSection("🛠Local Player")
-- Infinite Jump Toggle
_G.infinjump = false

MainTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Flag = "InfiniteJump",
	Callback = function(Value)
		_G.infinjump = Value
	end
})

-- Infinite Jump Logic (chỉ chạy 1 lần)
UIS.JumpRequest:Connect(function()
	if _G.infinjump then
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- WalkSpeed Slider
MainTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {1, 350},
	Increment = 1,
	CurrentValue = 16,
	Flag = "WS",
	Callback = function(v)
		_G.MiyuSettings.WalkSpeed = v
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end
})

-- JumpPower Slider
MainTab:CreateSlider({
	Name = "JumpPower",
	Range = {1, 350},
	Increment = 1,
	CurrentValue = 50,
	Flag = "JP",
	Callback = function(v)
		_G.MiyuSettings.JumpPower = v
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.JumpPower = v end
	end
})

--// ===== MOVEMENT =====
MainTab:CreateSection("Movement")

-- Fly
local flying = false
local bv, bg

MainTab:CreateToggle({
	Name = "Fly",
	Flag = "Fly",
	CurrentValue = false,
	Callback = function(v)
		flying = v
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		if v then
			bv = Instance.new("BodyVelocity", hrp)
			bv.MaxForce = Vector3.new(1e5,1e5,1e5)

			bg = Instance.new("BodyGyro", hrp)
			bg.MaxTorque = Vector3.new(1e5,1e5,1e5)

			RunService:BindToRenderStep("Fly", 0, function()
				local cam = workspace.CurrentCamera
				bg.CFrame = cam.CFrame
				local dir = Vector3.zero

				if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
				if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

				bv.Velocity = dir * 60
			end)
		else
			RunService:UnbindFromRenderStep("Fly")
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
		end
	end
})

-- Noclip
local noclip = false
MainTab:CreateToggle({
	Name = "Noclip",
	Flag = "Noclip",
	CurrentValue = false,
	Callback = function(v)
		noclip = v
	end
})

RunService.Stepped:Connect(function()
	if noclip then
		local char = LocalPlayer.Character
		if char then
			for _,p in pairs(char:GetDescendants()) do
				if p:IsA("BasePart") then
					p.CanCollide = false
				end
			end
		end
	end
end)

--// ===== TELEPORT =====
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TargetPlayerName = nil
local TPTab = Window:CreateTab("📍 Teleports")
local function GetPlayerList()
	local list = {}
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			table.insert(list, plr.Name)
		end
	end
	return list
end
TPTab:CreateSection("Teleport Player")
local PlayerDropdown = TPTab:CreateDropdown({
	Name = "Select Player",
	Options = GetPlayerList(),
	CurrentOption = {},
	MultipleOptions = false,
	Flag = "SelectPlayer",
	Callback = function(Option)
		TargetPlayerName = Option[1]
	end,
})
TPTab:CreateButton({
	Name = "Refresh Player List",
	Callback = function()
		PlayerDropdown:Refresh(GetPlayerList())
	end
})
TPTab:CreateButton({
	Name = "Teleport To Selected Player",
	Callback = function()
		if not TargetPlayerName then
			Rayfield:Notify({
				Title = "Teleport",
				Content = "Chưa chọn người chơi!",
				Duration = 3
			})
			return
		end

		local target = Players:FindFirstChild(TargetPlayerName)
		if not target or not target.Character then return end

		local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local myHRP = myChar:WaitForChild("HumanoidRootPart")
		local tHRP = target.Character:WaitForChild("HumanoidRootPart")

		myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 3)
	end
})


--// ===== Visual =====
local esp = Window:CreateTab("👁 Visual")
--// ===== ESP PLAYER ===== 
local ESPEnabled = false
local ESPFolder = Instance.new("Folder", game.CoreGui)
ESPFolder.Name = "MiyuESP"
-- Tạo ESP cho 1 player
local function createESP(plr)
	if plr == LocalPlayer then return end

	local function applyESP(char)
		if not ESPEnabled then return end
		if not char:FindFirstChild("HumanoidRootPart") then return end

		-- Highlight
		local highlight = Instance.new("Highlight")
		highlight.Name = "MiyuHighlight"
		highlight.FillColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Adornee = char
		highlight.Parent = ESPFolder

		-- Billboard UI
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "MiyuBillboard"
		billboard.Adornee = char:WaitForChild("Head")
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Parent = ESPFolder

		local text = Instance.new("TextLabel", billboard)
		text.Size = UDim2.new(1, 0, 1, 0)
		text.BackgroundTransparency = 1
		text.TextStrokeTransparency = 0
		text.TextColor3 = Color3.fromRGB(255, 255, 255)
		text.TextScaled = true
		text.Font = Enum.Font.GothamBold
		text.Text = plr.Name .. " | ID: " .. plr.UserId
	end

	if plr.Character then
		applyESP(plr.Character)
	end

	plr.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		applyESP(char)
	end)
end

-- Xóa toàn bộ ESP
local function clearESP()
	if ESPFolder then
		ESPFolder:ClearAllChildren()
	end
end

-- Toggle ESP
esp:CreateSection("☢ESP")
esp:CreateToggle({
	Name = "Player ESP",
	Flag = "PlayerESP",
	CurrentValue = false,
	Callback = function(Value)
		ESPEnabled = Value
		clearESP()

		if Value then
			for _,plr in pairs(Players:GetPlayers()) do
				createESP(plr)
			end
		end
	end
})

-- Player join
Players.PlayerAdded:Connect(function(plr)
	if ESPEnabled then
		createESP(plr)
	end
end)
--// ===== ESP NPC =====
local NPCESPEnabled = false
local NPCFolder = Instance.new("Folder", game.CoreGui)
NPCFolder.Name = "MiyuNPCESP"

-- Kiểm tra có phải NPC không
local function isNPC(model)
	if not model:IsA("Model") then return false end
	if model:FindFirstChildOfClass("Humanoid") then
		-- Nếu không phải player
		if not Players:GetPlayerFromCharacter(model) then
			return true
		end
	end
	return false
end

-- Tạo ESP cho NPC
local function createNPCESP(npc)
	if npc:FindFirstChild("MiyuNPC_HL") then return end

	local hrp = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
	local head = npc:FindFirstChild("Head")
	if not hrp or not head then return end

	-- Highlight
	local hl = Instance.new("Highlight")
	hl.Name = "MiyuNPC_HL"
	hl.FillColor = Color3.fromRGB(255, 85, 0)
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.FillTransparency = 0.4
	hl.OutlineTransparency = 0
	hl.Adornee = npc
	hl.Parent = NPCFolder

	-- Billboard
	local bb = Instance.new("BillboardGui")
	bb.Name = "MiyuNPC_BB"
	bb.Adornee = head
	bb.Size = UDim2.new(0, 200, 0, 40)
	bb.StudsOffset = Vector3.new(0, 2.5, 0)
	bb.AlwaysOnTop = true
	bb.Parent = NPCFolder

	local txt = Instance.new("TextLabel", bb)
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundTransparency = 1
	txt.TextStrokeTransparency = 0
	txt.TextScaled = true
	txt.Font = Enum.Font.GothamBold
	txt.TextColor3 = Color3.fromRGB(255, 170, 0)
	txt.Text = npc.Name
end

-- Clear NPC ESP
local function clearNPCESP()
	NPCFolder:ClearAllChildren()
end

-- Toggle UI
esp:CreateToggle({
	Name = "NPC ESP",
	Flag = "NPCESP",
	CurrentValue = false,
	Callback = function(Value)
		NPCESPEnabled = Value
		clearNPCESP()

		if Value then
			for _,obj in pairs(workspace:GetChildren()) do
				if isNPC(obj) then
					createNPCESP(obj)
				end
			end
		end
	end
})

-- Theo dõi NPC spawn
workspace.ChildAdded:Connect(function(obj)
	if NPCESPEnabled and isNPC(obj) then
		task.wait(0.5)
		createNPCESP(obj)
	end
end)


--// ===== EXECUTE SCRIPT TAB =====
local ExecTab = Window:CreateTab("⚡ Execute", nil)
ExecTab:CreateSection("Execute Script")

local ScriptText = ""

-- Ô nhập script
ExecTab:CreateInput({
	Name = "Script Box",
	PlaceholderText = "Paste your Lua script here...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		ScriptText = Text
	end,
})

-- Nút Execute
ExecTab:CreateButton({
	Name = "▶ Execute Script",
	Callback = function()
		if ScriptText ~= "" then
			local success, err = pcall(function()
				loadstring(ScriptText)()
			end)

			if success then
				Rayfield:Notify({
					Title = "Execute Success",
					Content = "Script executed successfully ✅",
					Duration = 4
				})
			else
				Rayfield:Notify({
					Title = "Execute Failed",
					Content = tostring(err),
					Duration = 6
				})
			end
		else
			Rayfield:Notify({
				Title = "No Script",
				Content = "Please paste a script first!",
				Duration = 3
			})
		end
	end,
})

-- Nút Clear
ExecTab:CreateButton({
	Name = "🗑 Clear Script Box",
	Callback = function()
		ScriptText = ""
		Rayfield:Notify({
			Title = "Cleared",
			Content = "Script box cleared",
			Duration = 2
		})
	end,
})
--// ===== Anti =====
local anti = Window:CreateTab("🧠 Anti")

--// ===== Anti Reset / Anti Stun / Anti Sit =====
local AntiEnabled = true
anti:CreateSection("Anti Movement")
anti:CreateToggle({
	Name = "Anti Reset / Anti Stun / Anti Sit",
	CurrentValue = true,
	Flag = "AntiReset",
	Callback = function(Value)
		AntiEnabled = Value
	end
})

LocalPlayer.CharacterAdded:Connect(function(char)
	local hum = char:WaitForChild("Humanoid")
	task.wait(0.3)
	if AntiEnabled then
		hum.WalkSpeed = _G.MiyuSettings.WalkSpeed
		hum.JumpPower = _G.MiyuSettings.JumpPower
		hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	end
end)

-- Giữ tốc độ / jump liên tục
RunService.Heartbeat:Connect(function()
	if AntiEnabled then
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = _G.MiyuSettings.WalkSpeed
				hum.JumpPower = _G.MiyuSettings.JumpPower
			end
		end
	end
end)


--// ===== MISC =====
local misc = Window:CreateTab("🎲 Misc")
--// ===== AUTO LEAVE BLACKLIST =====
local Blacklist = {}
local AutoLeave = false

-- Hàm parse text -> blacklist table
local function updateBlacklist(text)
	Blacklist = {}
	for name in string.gmatch(text, "[^,%s]+") do
		Blacklist[name:lower()] = true
	end
end

-- Check player
local function checkPlayer(plr)
	if AutoLeave and Blacklist[plr.Name:lower()] then
		LocalPlayer:Kick("🚫 Auto Leave: Detected blacklisted player: "..plr.Name)
	end
end

-- UI Section
misc:CreateSection("🚫 Auto Leave (Blacklist)")

-- Toggle Auto Leave
misc:CreateToggle({
	Name = "Auto Leave When Player Found",
	Flag = "AutoLeave",
	CurrentValue = false,
	Callback = function(Value)
		AutoLeave = Value
		if Value then
			-- Check all current players
			for _,plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer then
					checkPlayer(plr)
				end
			end
		end
	end
})

-- Input Blacklist
misc:CreateInput({
	Name = "Blacklist Player Names",
	PlaceholderText = "vd: Hacker123, ToxicGuy, ProABC",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		updateBlacklist(Text)
	end
})

-- Player join listener
Players.PlayerAdded:Connect(function(plr)
	if plr ~= LocalPlayer then
		checkPlayer(plr)
	end
end)

local SettingsTab = Window:CreateTab("⚙️ Settings")
SettingsTab:CreateSection("🕹 Config")
-- Save Config
SettingsTab:CreateButton({
	Name = "Save Config",
	Callback = function()
		Rayfield:SaveConfiguration()
		Rayfield:Notify({Title="Settings", Content="Config Saved!", Duration=3})
	end
})

-- Load Config
SettingsTab:CreateButton({
	Name = "Load Config",
	Callback = function()
		Rayfield:LoadConfiguration()
		Rayfield:Notify({Title="Settings", Content="Config Loaded!", Duration=3})
	end
})

-- Reset Config
SettingsTab:CreateButton({
	Name = "Reset Config",
	Callback = function()
		Rayfield:ResetConfiguration()
		Rayfield:Notify({Title="Settings", Content="Config Reset!", Duration=3})
	end
})
