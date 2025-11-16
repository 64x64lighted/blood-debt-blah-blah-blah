local weaponMarkers = {
    Killer = {
        "Sawn-off","K1911","RR-LightCompactPistolS","JS2-Derringy","SKORPION","JS-22","Kamatov","Mares Leg",
        "ZZ-90","Rosen-Obrez","JS1-CYCLOPS","THUMPA","LUT-E 'KRUS'","Memories","Hammer n Bullet","JS-44",
        "HWISSH-KP9","Mandols-5","RDG-2B","Testament","Jolibri","JAVELIN-OBREZS","GZhG-7.62","AGM22",
        "RR-Mark2","Dual LCPs","Wild Mandols-5","AK47 Case Hardened 1000000","Kensington","ZOZ-106",
        "Heardballa","Whizz","Rosen Nagan","WISP","WISP Pearl","M-1020","Dual SKORPS","Micro KZI",
        "SilverSteel K1911","KamatovDRUM","RR-LightCompactPistol","NGO","RR-LCP","KamatovS","JS1-Competitor"
    },

    Sheriff = {
        "RR-Snubby","GG-17","IZVEKH-412","Beagle","ZKZ-Obrez","J9-M","Buxxberg-COMPACT","JS-5A-Obrez",
        "Dual Elites","DRICO","HW-M5K","Comically Large Spoon","GG-1720","Mini-Ranch-Rifle","Dual GG-17s"
    },

    Juggernaut = {
        "VK's ANKM","RY's GG-17","AT's KAR15","TG's JAVELIN-ZVD", "VA's ANKM", "RVK","Mason's K1911"
    }
}

local roleColors = {
    Killer = Color3.fromRGB(255,0,0),
    Sheriff = Color3.fromRGB(255,255,0),
    Juggernaut = Color3.fromRGB(125,200,255)
}

local function getGunCategory(gunName)
    for category, list in pairs(weaponMarkers) do
        for _, weapon in ipairs(list) do
            if weapon == gunName then
                return category
            end
        end
    end
    return nil
end

local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")

local boxesData = {}

local function createboxes(player)
    if boxesData[player] then return end
    local box = Drawing.new("Square")
    box.Filled = false
    box.Thickness = 1
    box.Color = Color3.fromRGB(255,255,255)
    box.Visible = false

    local text = Drawing.new("Text")
    text.Color = Color3.fromRGB(255,255,255)
    text.Center = true
    text.Outline = true
    text.Visible = false

    boxesData[player] = {box = box, text = text, lastGun = nil}
end

local function removeboxes(player)
    local d = boxesData[player]
    if d then
        d.box:Remove()
        d.text:Remove()
        boxesData[player] = nil
    end
end

local function hideboxes(player)
    local d = boxesData[player]
    if d then
        d.box.Visible = false
        d.text.Visible = false
    end
end

runService.PreRender:Connect(function()
    local list = players:GetChildren()

    for _, player in pairs(list) do
        if player == localPlayer then
            hideboxes(player)
            continue
        end

        if not boxesData[player] then
            createboxes(player)
        end

        local data = boxesData[player]
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not (char and root and hum) or hum.Health <= 0 then
            hideboxes(player)
            continue
        end

        local foundGun, currentGun = false, nil
        for _, container in pairs({player:FindFirstChild("Backpack"), char}) do
            if container then
                for _, tool in pairs(container:GetChildren()) do
                    if tool:IsA("Tool") then
                        local gunCheck = tool:FindFirstChild("GUNCHECK")
                        if gunCheck and gunCheck:IsA("Script") then
                            foundGun = true
                            currentGun = tool.Name
                            break
                        end
                    end
                end
            end
            if foundGun then break end
        end

        if foundGun then
            data.lastGun = currentGun

            local category = getGunCategory(currentGun)
            local color = roleColors[category] or Color3.fromRGB(255,255,255)

            local top = root.Position + Vector3.new(0, root.Size.Y * 1.15, 0)
            local bottom = root.Position - Vector3.new(0, root.Size.Y, 0)
            local tpos, ont = WorldToScreen(top)
            local bpos, onb = WorldToScreen(bottom)

            if not (ont and onb) then
                hideboxes(player)
                continue
            end

            local height = math.abs(tpos.Y - bpos.Y)
            local width = height / 1.5
            local x = tpos.X - width / 2
            local y = tpos.Y

            data.box.Color = color
            data.box.Size = Vector2.new(width,height)
            data.box.Position = Vector2.new(x,y)
            data.box.Visible = true

            data.text.Text = player.Name.." | "..currentGun..(category and (" ["..category.."]") or "")
            data.text.Position = Vector2.new(tpos.X, bpos.Y + 15)
            data.text.Visible = true
        else
            data.lastGun = nil
            hideboxes(player)
        end
    end

    local playerSet = {}
    for _, p in pairs(list) do
        playerSet[p] = true
    end
    for p in pairs(boxesData) do
        if not playerSet[p] then
            removeboxes(p)
        end
    end
end)
