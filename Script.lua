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
	LoadingTitle = "Miyu Hub ✅",
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
local MainTab = Window:CreateTab("Main")

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
local TPTab = Window:CreateTab("📍 Teleports")

TPTab:CreateButton({
	Name = "Up 50 Studs",
	Callback = function()
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		hrp.CFrame = hrp.CFrame * CFrame.new(0,50,0)
	end
})
--// ===== Visual =====
local esp = Window:CreateTab("Visual")
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
esp:CreateToggle({
	Name = "Player ESP (Highlight + Name)",
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

--// ===== MISC =====
Window:CreateTab("🎲Misc")
