local Players = game:GetService("Players")
local player = Players.LocalPlayer
local tweenService = game:GetService("TweenService")

-- Adicione estas variáveis no início do script
local noclipConnection = nil
local isMoving = false
local lastCacheClean = tick()

-- Adicione esta função fadeOut logo após as variáveis iniciais
local function fadeOut(obj)
    -- Ignora UICorner e outros objetos que não suportam transparência
    if obj:IsA("UICorner") or obj:IsA("UIGradient") or obj:IsA("UIStroke") then 
        return nil
    end
    
    local properties = {}
    
    -- Propriedades específicas para cada tipo de objeto
    if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("ScrollingFrame") then
        properties.BackgroundTransparency = 1
    end
    
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        properties.TextTransparency = 1
    end
    
    if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
        properties.ImageTransparency = 1
    end
    
    -- Só cria o tween se houver propriedades para animar
    if next(properties) then
        return tweenService:Create(obj, TweenInfo.new(0.5), properties)
    end
    return nil
end

-- Interface principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FruitDetectorGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Painel principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.85, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Arredondamento e sombra
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- Título com ícone
local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, 0, 0, 40)
titleContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleContainer.BorderSizePixel = 0
titleContainer.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleContainer

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🍎 Detector de Frutas"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = titleContainer

-- Adicione após a criação do titleContainer
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Adicione os efeitos e função de fechamento
closeButton.MouseButton1Click:Connect(function()
    -- Limpa recursos primeiro
    if cleanupESPs then
        cleanupESPs()
    end
    
    if updateThread then
        pcall(function()
            coroutine.close(updateThread)
        end)
    end

    local tweens = {}
    for _, obj in ipairs(mainFrame:GetDescendants()) do
        local tween = fadeOut(obj)
        if tween then -- Só adiciona se o tween for válido
            table.insert(tweens, tween)
            tween:Play()
        end
    end
    
    -- Anima o frame principal por último
    local mainTween = tweenService:Create(mainFrame, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    })
    mainTween:Play()
    
    -- Remove após todas as animações
    task.delay(0.6, function()
        pcall(function()
            screenGui:Destroy()
        end)
    end)
end)

-- Lista de frutas
local fruitList = Instance.new("ScrollingFrame")
fruitList.Size = UDim2.new(1, -20, 1, -60)
fruitList.Position = UDim2.new(0, 10, 0, 50)
fruitList.BackgroundTransparency = 1
fruitList.BorderSizePixel = 0
fruitList.ScrollBarThickness = 4
fruitList.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = fruitList

-- Lista de acessórios para ignorar

-- Lista expandida de padrões para ignorar
local ignoredPatterns = {
    "Hat", "Hair", "_Accessory", "Fishman", "Pal", "Spawn", "ParticleDrop",
    "Dealer", "NPC", "Quest", "Dialog"
}

-- Cache otimizado com tempo de expiração
local itemCache = setmetatable({}, {
    __index = function(t, k)
        return {result = false, timestamp = 0}
    end
})

-- Set para rastrear frutas já encontradas
local foundFruits = {}

-- Função otimizada para verificar se é uma fruta
local function isBloxFruit(item)
    local cache = itemCache[item]
    local currentTime = tick()
    
    -- Verifica cache válido (30 segundos)
    if currentTime - cache.timestamp < 30 then
        return cache.result
    end
    
    -- Verifica nome do item
    local itemName = item.Name
    
    -- Verifica padrões ignorados (otimizado)
    for _, pattern in ipairs(ignoredPatterns) do
        if string.find(itemName:lower(), pattern:lower()) then
            itemCache[item] = {result = false, timestamp = currentTime}
            return false
        end
    end
    
    -- Verifica se é uma fruta válida
    local isFruit = string.find(itemName, "Fruit") and 
                   not string.find(itemName, "FruitSpawn") and
                   not string.find(itemName, "Dealer")
    
    itemCache[item] = {result = isFruit, timestamp = currentTime}
    return isFruit
end

-- Função otimizada para obter posição
local function getObjectPosition(item)
    if not item:IsDescendantOf(game) then return nil end
    
    if item:IsA("Model") then
        local primary = item.PrimaryPart
        if primary then return primary.Position end
        
        local part = item:FindFirstChildWhichIsA("BasePart")
        return part and part.Position
    end
    
    return item:IsA("BasePart") and item.Position
end

-- Adicione estas funções de movimento
local function setNoclip(enabled)
    if enabled then
        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
            
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end

local function smoothMove(targetPosition)
    if isMoving then return end
    isMoving = true
    setNoclip(true)
    
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local startPos = humanoidRootPart.Position
    local distance = (targetPosition - startPos).Magnitude
    local moveDuration = distance / 50 -- Velocidade mais lenta (50 studs por segundo)
    
    -- Define a orientação para olhar para o destino
    local lookVector = (targetPosition - startPos).Unit
    humanoidRootPart.CFrame = CFrame.new(startPos) * CFrame.lookAt(Vector3.new(0,0,0), lookVector)
    
    -- Movimento suave
    local tween = tweenService:Create(humanoidRootPart, 
        TweenInfo.new(moveDuration, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(targetPosition + Vector3.new(0, 3, 0))}
    )
    
    -- Efeito de rastro
    local trail = Instance.new("Trail")
    trail.Color = ColorSequence.new(Color3.fromRGB(255, 170, 0))
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Lifetime = 1.5
    trail.Parent = humanoidRootPart
    
    -- Inicia o movimento
    tween:Play()
    tween.Completed:Wait()
    
    -- Limpa os efeitos
    trail:Destroy()
    setNoclip(false)
    isMoving = false
end

-- Modifique a função de teleporte para usar o movimento suave
local function teleportToFruit(position)
    local character = player.Character
    if not character then return end
    
    -- Efeito visual no destino
    local effectEnd = Instance.new("Part")
    effectEnd.Anchored = true
    effectEnd.CanCollide = false
    effectEnd.Size = Vector3.new(0, 0, 0)
    effectEnd.Position = position
    effectEnd.Shape = Enum.PartType.Ball
    effectEnd.Material = Enum.Material.Neon
    effectEnd.BrickColor = BrickColor.new("Deep orange")
    effectEnd.Transparency = 1
    effectEnd.Parent = workspace
    
    -- Anima o efeito
    tweenService:Create(effectEnd, 
        TweenInfo.new(0.5), 
        {Size = Vector3.new(5, 5, 5), Transparency = 0.3}
    ):Play()
    game:GetService("Debris"):AddItem(effectEnd, 0.5)
    
    -- Usa movimento suave
    smoothMove(position)
end

-- Função para criar entrada de fruta na lista
local function createFruitEntry(fruitData)
    local entry = Instance.new("TextButton") -- Mudado para TextButton
    entry.Size = UDim2.new(1, 0, 0, 50)
    entry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    entry.Text = "" -- Remove texto do botão
    entry.AutoButtonColor = false -- Remove efeito padrão de botão
    
    -- Efeito hover
    entry.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(entry,
            TweenInfo.new(0.3),
            {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}
        ):Play()
    end)
    
    entry.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(entry,
            TweenInfo.new(0.3),
            {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}
        ):Play()
    end)
    
    -- Adiciona função de teleporte ao clicar
    entry.MouseButton1Click:Connect(function()
        teleportToFruit(fruitData.position)
    end)
    
    -- Nome da fruta
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.7, -10, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Text = fruitData.name
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = entry
    
    -- Distância
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(0.3, -10, 0.5, 0)
    distanceLabel.Position = UDim2.new(0.7, 0, 0, 5)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.Text = math.floor(fruitData.distance) .. "m"
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 14
    distanceLabel.Parent = entry
    
    -- Localização
    local locationLabel = Instance.new("TextLabel")
    locationLabel.Size = UDim2.new(1, -20, 0.5, -5)
    locationLabel.Position = UDim2.new(0, 10, 0.5, 0)
    locationLabel.BackgroundTransparency = 1
    locationLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    locationLabel.Text = string.format("🌍 %.1f, %.1f, %.1f", 
        fruitData.position.X, 
        fruitData.position.Y, 
        fruitData.position.Z)
    locationLabel.TextXAlignment = Enum.TextXAlignment.Left
    locationLabel.Font = Enum.Font.Gotham
    locationLabel.TextSize = 12
    locationLabel.Parent = entry
    
    return entry
end

-- Variável para controle de notificações
local lastNotification = 0
local lastFruitName = ""

-- Função otimizada para atualizar lista
local function updateFruitList()
    -- Limpa lista apenas se necessário
    if tick() - lastCacheClean > 30 then
        itemCache = setmetatable({}, {__index = function(t,k) return {result = false, timestamp = 0} end})
        lastCacheClean = tick()
        foundFruits = {}
    end
    
    -- Remove entradas antigas
    for _, child in ipairs(fruitList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local fruits = {}
    local playerPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not playerPos then return end
    playerPos = playerPos.Position
    
    -- Função otimizada de busca
    local function searchInFolder(folder)
        cleanupESPs() -- Limpa ESPs antigos
        
        for _, item in ipairs(folder:GetChildren()) do
            local itemId = tostring(item:GetFullName())
            
            -- Verifica se já encontramos esta fruta
            if not foundFruits[itemId] then
                if isBloxFruit(item) then
                    local position = getObjectPosition(item)
                    if position then
                        local distance = (position - playerPos).Magnitude
                        updateFruitESP(item, distance)
                        foundFruits[itemId] = true
                        table.insert(fruits, {
                            name = item.Name,
                            position = position,
                            distance = distance,
                            id = itemId
                        })
                    end
                end
            end
            
            -- Busca recursiva otimizada
            if #fruits < 10 and (item:IsA("Folder") or item:IsA("Model")) then
                searchInFolder(item)
            end
        end
    end
    
    searchInFolder(workspace)
    
    -- Processamento apenas se houver frutas novas
    if #fruits > 0 then
        -- Ordenação otimizada
        table.sort(fruits, function(a, b)
            return a.distance < b.distance
        end)
        
        -- Limita a 10 frutas e evita duplicatas
        local addedFruits = {}
        for i = 1, math.min(10, #fruits) do
            if not addedFruits[fruits[i].name] then
                local entry = createFruitEntry(fruits[i])
                entry.Parent = fruitList
                addedFruits[fruits[i].name] = true
            end
        end
        
        -- Notificação apenas para frutas novas
        local currentTime = tick()
        if fruits[1].name ~= lastFruitName and (currentTime - lastNotification) > 10 then
            lastNotification = currentTime
            lastFruitName = fruits[1].name
            
            game.StarterGui:SetCore("SendNotification", {
                Title = "Nova Fruta!",
                Text = fruits[1].name .. " (" .. math.floor(fruits[1].distance) .. "m)",
                Duration = 5
            })
        end
    end
end

-- Atualização otimizada usando coroutine
local lastUpdate = 0
local updateThread = nil

game:GetService("RunService").Heartbeat:Connect(function()
    local currentTime = tick()
    if currentTime - lastUpdate >= 5 and player.Character then
        lastUpdate = currentTime
        
        if updateThread and coroutine.status(updateThread) == "dead" then
            updateThread = nil
        end
        
        if not updateThread then
            updateThread = coroutine.create(function()
                updateFruitList()
            end)
            coroutine.resume(updateThread)
        end
    end
end)

-- Limpeza ao desconectar
player.CharacterRemoving:Connect(function()
    if updateConnection then
        updateConnection:Disconnect()
    end
    setNoclip(false)
end)

-- Tornar a interface arrastável
local isDragging = false
local dragStart = nil
local startPos = nil

titleContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Adicione estas variáveis no início do script
local ESP_Number = 0
local fruitESPs = {}

-- Função para criar ou atualizar ESP visual
local function updateFruitESP(fruit, distance)
    local handle = fruit:IsA("Model") and fruit.PrimaryPart or fruit
    if not handle then return end
    
    local espName = "FruitESP_" .. fruit:GetFullName()
    local existingESP = fruitESPs[espName]
    
    if not existingESP then
        local bill = Instance.new('BillboardGui')
        bill.Name = espName
        bill.ExtentsOffset = Vector3.new(0, 2, 0)
        bill.Size = UDim2.new(1, 200, 1, 30)
        bill.Adornee = handle
        bill.AlwaysOnTop = true
        
        local name = Instance.new('TextLabel')
        name.Font = Enum.Font.GothamSemibold
        name.TextSize = 14
        name.TextWrapped = true
        name.Size = UDim2.new(1, 0, 1, 0)
        name.TextYAlignment = 'Top'
        name.BackgroundTransparency = 1
        name.TextStrokeTransparency = 0.5
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.Parent = bill
        
        -- Adiciona linha de rastreamento
        local line = Instance.new('Beam')
        local a1 = Instance.new('Attachment')
        local a2 = Instance.new('Attachment')
        line.Attachment0 = a1
        line.Attachment1 = a2
        line.Width0 = 0.1
        line.Width1 = 0.1
        line.FaceCamera = true
        line.Color = ColorSequence.new(Color3.fromRGB(85, 170, 255))
        line.Parent = workspace
        a1.Parent = handle
        
        fruitESPs[espName] = {
            gui = bill,
            label = name,
            line = line,
            att1 = a1,
            att2 = a2
        }
        bill.Parent = handle
    end
    
    -- Atualiza informações do ESP
    local esp = fruitESPs[espName]
    esp.label.Text = string.format("%s\n%d metros", fruit.Name, math.floor(distance))
    
    -- Atualiza linha de rastreamento
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        esp.att2.Parent = player.Character.HumanoidRootPart
    end
end

-- Modifique a função cleanupESPs para proteger contra erros
local function cleanupESPs()
    for name, esp in pairs(fruitESPs) do
        pcall(function()
            if esp.gui and esp.gui.Parent then
                esp.gui:Destroy()
            end
            if esp.line and esp.line.Parent then
                esp.line:Destroy()
            end
            if esp.att1 and esp.att1.Parent then
                esp.att1:Destroy()
            end
            if esp.att2 and esp.att2.Parent then
                esp.att2:Destroy()
            end
        end)
        fruitESPs[name] = nil
    end
end

-- Adicione uma função de atualização contínua de ESP
game:GetService("RunService").RenderStepped:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, esp in pairs(fruitESPs) do
            if esp.gui.Adornee then
                local distance = (esp.gui.Adornee.Position - player.Character.HumanoidRootPart.Position).Magnitude
                esp.label.Text = string.format("%s\n%d metros", esp.gui.Adornee.Parent.Name, math.floor(distance))
            end
        end
    end
end)

-- Adicione no início do arquivo
local LAYOUT = require(script.Parent.shared_layout)

-- ...existing code...

-- Ajuste a lista de frutas para respeitar a área segura
fruitList.Size = UDim2.new(LAYOUT.CLOSE_BUTTON.safeArea.X.Scale, -20, 1, -60)

-- Ajuste o closeButton
closeButton.Size = LAYOUT.CLOSE_BUTTON.size
closeButton.Position = LAYOUT.CLOSE_BUTTON.position
