local Players = game:GetService("Players")
local player = Players.LocalPlayer
local tweenService = game:GetService("TweenService")

-- Adicione no início do arquivo
local LAYOUT = require(script.Parent.shared_layout)

-- Interface principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ItemDetectorGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Painel principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(0.85, 0, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Arredondamento
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Text = "Detector de Itens"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

-- Adicione após a criação do titleLabel
local closeButton = Instance.new("TextButton")
closeButton.Size = LAYOUT.CLOSE_BUTTON.size
closeButton.Position = LAYOUT.CLOSE_BUTTON.position
closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Adicione esta função fadeOut logo após as variáveis iniciais e remova qualquer outra implementação
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

-- Substitua a função closeButton.MouseButton1Click:Connect existente por esta única versão
closeButton.MouseButton1Click:Connect(function()
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

-- Adiciona campo de entrada e botão delete após o título
local deleteContainer = Instance.new("Frame")
deleteContainer.Size = UDim2.new(LAYOUT.CLOSE_BUTTON.safeArea.X.Scale, -20, 0, 30)
deleteContainer.Position = UDim2.new(0, 10, 0, 35)
deleteContainer.BackgroundTransparency = 1
deleteContainer.Parent = mainFrame

local deleteInput = Instance.new("TextBox")
deleteInput.Size = UDim2.new(0.7, 0, 1, 0)
deleteInput.Position = UDim2.new(0, 0, 0, 0)
deleteInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
deleteInput.TextColor3 = Color3.new(1, 1, 1)
deleteInput.PlaceholderText = "Nome do objeto para deletar..."
deleteInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
deleteInput.Text = ""
deleteInput.Font = Enum.Font.Gotham
deleteInput.TextSize = 14
deleteInput.Parent = deleteContainer

local deleteButton = Instance.new("TextButton")
deleteButton.Size = UDim2.new(0.25, 0, 1, 0)
deleteButton.Position = UDim2.new(0.75, 5, 0, 0)
deleteButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
deleteButton.TextColor3 = Color3.new(1, 1, 1)
deleteButton.Text = "Deletar"
deleteButton.Font = Enum.Font.GothamBold
deleteButton.TextSize = 14
deleteButton.Parent = deleteContainer

-- Adiciona cantos arredondados
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 5)
inputCorner.Parent = deleteInput

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 5)
buttonCorner.Parent = deleteButton

-- Lista de itens (movido para antes do ajuste de tamanho)
local itemList = Instance.new("ScrollingFrame")
itemList.Size = UDim2.new(LAYOUT.CLOSE_BUTTON.safeArea.X.Scale, -20, 1, -80) -- Tamanho já ajustado para acomodar o campo de delete
itemList.Position = UDim2.new(0, 10, 0, 75) -- Posição já ajustada
itemList.BackgroundTransparency = 1
itemList.BorderSizePixel = 0
itemList.ScrollBarThickness = 4
itemList.Parent = mainFrame

-- Layout da lista
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = itemList

-- Função para criar entrada de item
local function createItemEntry(itemName, position)
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, 0, 0, 30)
    entry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 5)
    entryCorner.Parent = entry
    
    local itemLabel = Instance.new("TextLabel")
    itemLabel.Size = UDim2.new(0.7, 0, 1, 0)
    itemLabel.Position = UDim2.new(0, 10, 0, 0)
    itemLabel.BackgroundTransparency = 1
    itemLabel.TextColor3 = Color3.new(1, 1, 1)
    itemLabel.Text = itemName
    itemLabel.TextXAlignment = Enum.TextXAlignment.Left
    itemLabel.Font = Enum.Font.Gotham
    itemLabel.TextSize = 14
    itemLabel.Parent = entry
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(0.3, -10, 1, 0)
    distanceLabel.Position = UDim2.new(0.7, 0, 0, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.Text = math.floor((position - player.Character.HumanoidRootPart.Position).Magnitude) .. "m"
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 14
    distanceLabel.Parent = entry
    
    return entry
end

-- Função para verificar se um objeto está relacionado ao jogador
local function isPlayerRelated(object)
    local playerName = player.Name
    
    -- Verifica se o objeto pertence ao jogador
    if object:IsDescendantOf(player.Character) then
        return true
    end
    
    -- Verifica se o nome contém o nick do jogador
    if object.Name:find(playerName) then
        return true
    end
    
    -- Verifica se está em pastas comuns de jogador
    if object:IsDescendantOf(workspace:FindFirstChild(playerName)) then
        return true
    end
    
    return false
end

-- Função atualizada para verificar se um objeto é uma Tool
local function isLikelyItem(object)
    -- Ignora objetos relacionados ao jogador
    if isPlayerRelated(object) then
        return false
    end
    
    -- Verifica se é uma Tool
    if object:IsA("Tool") then
        return true
    end
    
    -- Procura por Tools dentro de modelos
    if object:IsA("Model") then
        local toolInModel = object:FindFirstChildWhichIsA("Tool", true)
        if toolInModel then
            return true
        end
    end
    
    return false
end

-- Função modificada para atualizar lista de itens
local function updateItemList()
    -- Limpa lista atual
    for _, child in ipairs(itemList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Procura por itens no workspace
    local items = {}
    
    -- Função recursiva para procurar em todas as pastas
    local function searchInFolder(folder)
        for _, item in ipairs(folder:GetChildren()) do
            -- Ignora pastas relacionadas ao jogador
            if not isPlayerRelated(item) then
                -- Verifica se é uma Tool
                if isLikelyItem(item) then
                    local pos
                    if item:IsA("Tool") then
                        pos = item:IsA("Model") and item:GetModelCFrame().Position or 
                              (item.Handle and item.Handle.Position or item.Position)
                    else
                        pos = item:IsA("Model") and 
                            (item.PrimaryPart and item.PrimaryPart.Position or item:GetModelCFrame().Position) or 
                            item.Position
                    end
                    
                    -- Adiciona informações da Tool
                    table.insert(items, {
                        name = item.Name,
                        position = pos,
                        class = item.ClassName,
                        path = item:GetFullName(),
                        isTool = item:IsA("Tool")
                    })
                end
                
                -- Procura recursivamente em pastas
                if item:IsA("Folder") or item:IsA("Model") then
                    searchInFolder(item)
                end
            end
        end
    end

    -- Inicia busca no workspace
    searchInFolder(workspace)
    
    -- Ordena itens por distância
    table.sort(items, function(a, b)
        local distA = (a.position - player.Character.HumanoidRootPart.Position).Magnitude
        local distB = (b.position - player.Character.HumanoidRootPart.Position).Magnitude
        return distA < distB
    end)
    
    -- Cria entradas para cada item com mais detalhes
    for _, item in ipairs(items) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, 0, 0, 40)
        entry.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        
        local entryCorner = Instance.new("UICorner")
        entryCorner.CornerRadius = UDim.new(0, 5)
        entryCorner.Parent = entry
        
        -- Nome e classe do item
        local itemInfo = Instance.new("TextLabel")
        itemInfo.Size = UDim2.new(0.7, 0, 0.5, 0)
        itemInfo.Position = UDim2.new(0, 10, 0, 0)
        itemInfo.BackgroundTransparency = 1
        itemInfo.TextColor3 = Color3.new(1, 1, 1)
        itemInfo.Text = item.name .. " [" .. item.class .. "]"
        itemInfo.TextXAlignment = Enum.TextXAlignment.Left
        itemInfo.Font = Enum.Font.Gotham
        itemInfo.TextSize = 14
        itemInfo.Parent = entry
        
        -- Caminho do item
        local pathLabel = Instance.new("TextLabel")
        pathLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
        pathLabel.Position = UDim2.new(0, 10, 0.5, 0)
        pathLabel.BackgroundTransparency = 1
        pathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        pathLabel.Text = item.path
        pathLabel.TextXAlignment = Enum.TextXAlignment.Left
        pathLabel.Font = Enum.Font.Gotham
        pathLabel.TextSize = 12
        pathLabel.Parent = entry
        
        -- Distância
        local dist = (item.position - player.Character.HumanoidRootPart.Position).Magnitude
        local distanceLabel = Instance.new("TextLabel")
        distanceLabel.Size = UDim2.new(0.3, -10, 1, 0)
        distanceLabel.Position = UDim2.new(0.7, 0, 0, 0)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.new(1, 1, 1)
        distanceLabel.Text = math.floor(dist) .. "m"
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextSize = 14
        distanceLabel.Parent = entry
        
        entry.Parent = itemList
    end
end

-- Função para deletar objeto
local function deleteObject()
    local objectName = deleteInput.Text
    if objectName == "" then return end
    
    -- Procura o objeto no workspace
    local found = false
    for _, item in ipairs(workspace:GetChildren()) do
        if item.Name == objectName then
            item:Destroy()
            found = true
            deleteInput.Text = ""
            -- Feedback visual
            deleteButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
            deleteButton.Text = "Deletado!"
            wait(1)
            deleteButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
            deleteButton.Text = "Deletar"
            break
        end
    end
    
    if not found then
        -- Feedback visual de erro
        deleteButton.BackgroundColor3 = Color3.fromRGB(255, 150, 150)
        deleteButton.Text = "Não encontrado"
        wait(1)
        deleteButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        deleteButton.Text = "Deletar"
    end
end

-- Conecta o botão à função de deletar
deleteButton.MouseButton1Click:Connect(deleteObject)

-- Permite deletar pressionando Enter
deleteInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        deleteObject()
    end
end)

-- Atualiza a lista a cada segundo
game:GetService("RunService").Heartbeat:Connect(function()
    updateItemList()
    wait(1) -- Atualiza a cada segundo
end)

-- Função para tornar a interface arrastável
local isDragging = false
local dragStart = nil
local startPos = nil

titleLabel.InputBegan:Connect(function(input)
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
