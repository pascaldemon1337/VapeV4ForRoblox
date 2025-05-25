local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local OWNER_ID = 4211452992 -- Replace with your real UserId

-- Create floating tag
local function createTag(text, color, player)
	local head = player.Character and player.Character:FindFirstChild("Head")
	if not head or head:FindFirstChild("VapeTag") then return end

	local tag = Instance.new("BillboardGui")
	tag.Name = "VapeTag"
	tag.Size = UDim2.new(0, 100, 0, 20)
	tag.StudsOffset = Vector3.new(0, 3, 0)
	tag.AlwaysOnTop = true
	tag.Adornee = head
	tag.ResetOnSpawn = false
	tag.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = tag
end

-- Tag players when VapeUser is true
local function tagPlayer(player)
	task.spawn(function()
		local char = player.Character or player.CharacterAdded:Wait()
		local head = char:WaitForChild("Head", 5)
		if head and not head:FindFirstChild("VapeTag") and player:GetAttribute("VapeUser") then
			if player.UserId == OWNER_ID then
				createTag("VAPE PRIVATE", Color3.fromRGB(128, 0, 255), player)
			else
				createTag("VAPE USER", Color3.fromRGB(255, 255, 0), player)
			end
		end
	end)
end

-- Setup player listeners
local function onPlayerAdded(player)
	player:GetAttributeChangedSignal("VapeUser"):Connect(function()
		if player:GetAttribute("VapeUser") then
			tagPlayer(player)
		end
	end)
	player.CharacterAdded:Connect(function()
		if player:GetAttribute("VapeUser") then
			tagPlayer(player)
		end
	end)
	if player.Character and player:GetAttribute("VapeUser") then
		tagPlayer(player)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle incoming chat messages
TextChatService.OnIncomingMessage = function(message)
	local props = Instance.new("TextChatMessageProperties")
	local source = message.TextSource
	if not source then return nil end

	local speaker = Players:GetPlayerByUserId(source.UserId)
	if not speaker then return nil end

	-- 💬 Detect whisper: "detect me"
	if message.Text:lower() == "detect me" and message.Metadata == "TextChatMessageMetadata.Private" then
		speaker:SetAttribute("VapeUser", true)
	end

	if speaker.UserId == OWNER_ID then
		props.PrefixText = "[VAPE PRIVATE] " .. message.PrefixText
		props.PrefixTextColor3 = Color3.fromRGB(128, 0, 255)
		return props
	elseif speaker:GetAttribute("VapeUser") then
		props.PrefixText = "[VAPE USER] " .. message.PrefixText
		props.PrefixTextColor3 = Color3.fromRGB(255, 255, 0)
		return props
	end

	return nil
end

local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil and res ~= ''
end

local delfile = delfile or function(file)
	writefile(file, '')
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/Noveign/VapeV4ForRoblox/' .. readfile('newvape/profiles/commit.txt') .. '/' .. select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('%.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
	if not isfolder(folder) then makefolder(folder) end
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/Noveign/VapeV4ForRoblox')
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
		wipeFolder('newvape')
		wipeFolder('newvape/games')
		wipeFolder('newvape/guis')
		wipeFolder('newvape/libraries')
	end
	writefile('newvape/profiles/commit.txt', commit)
end

return loadstring(downloadFile('newvape/main.lua'))()
