local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer
local OWNER_ID = 4211452992

-- Shared user list (cross-client)
shared.VapeUserIds = shared.VapeUserIds or {}
if not table.find(shared.VapeUserIds, LocalPlayer.UserId) then
    table.insert(shared.VapeUserIds, LocalPlayer.UserId)
end

-- Function to add floating tag
local function createTag(player, label, color)
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

    local labelObj = Instance.new("TextLabel")
    labelObj.Size = UDim2.new(1, 0, 1, 0)
    labelObj.BackgroundTransparency = 1
    labelObj.Text = label
    labelObj.TextColor3 = color
    labelObj.TextStrokeTransparency = 0
    labelObj.Font = Enum.Font.GothamBold
    labelObj.TextScaled = true
    labelObj.Parent = tag
end

local function tryTagPlayer(player)
    if table.find(shared.VapeUserIds, player.UserId) then
        if player.UserId == OWNER_ID then
            createTag(player, "VAPE PRIVATE", Color3.fromRGB(128, 0, 255))
        else
            createTag(player, "VAPE USER", Color3.fromRGB(255, 255, 0))
        end
    end
end

local function handlePlayer(player)
    player.CharacterAdded:Connect(function()
        tryTagPlayer(player)
    end)
    if player.Character then
        tryTagPlayer(player)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    handlePlayer(p)
end
Players.PlayerAdded:Connect(handlePlayer)

local function broadcastPresence()
    local msg = ":VAPE:" .. tostring(LocalPlayer.UserId)
    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents", 10)
    local chatEvent = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
        chatEvent.SayMessageRequest:FireServer(msg, "All")
    end
end

broadcastPresence()

TextChatService.OnIncomingMessage = function(message)
    local text = message.Text
    local matched = string.match(text, ":VAPE:(%d+)")
    if matched then
        local userId = tonumber(matched)
        if userId and not table.find(shared.VapeUserIds, userId) then
            table.insert(shared.VapeUserIds, userId)
            local player = Players:GetPlayerByUserId(userId)
            if player then
                tryTagPlayer(player)
            end
        end
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
