local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")

local LOCAL_PLAYER = Players.LocalPlayer
if LOCAL_PLAYER.UserId ~= 4417052147 then return end -- Only run for owner

local function applyVapeUserTag(player)
	local function render()
		local head = player.Character and player.Character:FindFirstChild("Head")
		if not head or head:FindFirstChild("VapeUserTag") then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "VapeUserTag"
		billboard.Size = UDim2.fromOffset(100, 20)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = head
		billboard.Parent = head

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = "VAPE USER"
		label.TextColor3 = Color3.fromRGB(255, 200, 0) -- Yellow
		label.TextStrokeTransparency = 0.3
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Parent = billboard
	end

	if player.Character then
		render()
	else
		player.CharacterAdded:Once(function()
			task.wait(0.5)
			render()
		end)
	end
end

TextChatService.IncomingMessageReceived:Connect(function(message)
	if message.Text == "detect me" and message.TextChannelType == Enum.TextChannelType.Private then
		local senderName = message.TextSource
		local sender = Players:FindFirstChild(senderName)

		if sender and sender ~= LOCAL_PLAYER then
			applyVapeUserTag(sender)
		end
	end
end)

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
		if not suc or res == '404: Not Found' then error(res) end
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
