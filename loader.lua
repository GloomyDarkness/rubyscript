local Players = game:GetService("Players")
local player = Players.LocalPlayer
local tweenService = game:GetService("TweenService")

-- URLs dos scripts atualizados
local scripts = {
    {
        name = "🍎 Detector de Frutas",
        url = "https://raw.githubusercontent.com/GloomyDarkness/rubyscript/main/scripts/bloxFruitDetector.lua"
    },
    {
        name = "🌟 Teleporte",
        url = "https://raw.githubusercontent.com/GloomyDarkness/rubyscript/main/scripts/teleport.lua"
    },
    {
        name = "🔍 Detector de Itens",
        url = "https://raw.githubusercontent.com/GloomyDarkness/rubyscript/main/scripts/itemDetector.lua"
    },
    {
        name = "⚔️ Farm de Bandits",
        url = "https://raw.githubusercontent.com/GloomyDarkness/rubyscript/main/scripts/banditFarm.lua"
    }
}

-- Interface do Loader
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScriptLoader"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Painel Principal
local mainPanel = Instance.new("Frame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(0, 250, 0, 350)
mainPanel.Position = UDim2.new(0.5, -125, 0.5, -150)
mainPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainPanel.BorderSizePixel = 0
mainPanel.Parent = screenGui

-- Arredondamento
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainPanel

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "🎮 Script Loader"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainPanel

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Adicione depois da criação do título
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = mainPanel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Efeitos do botão de fechar
closeButton.MouseEnter:Connect(function()
    tweenService:Create(closeButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(255, 90, 90)
    }):Play()
end)

closeButton.MouseLeave:Connect(function()
    tweenService:Create(closeButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    }):Play()
end)

-- Função para fechar com animação
closeButton.MouseButton1Click:Connect(function()
    -- Animação de fade out
    tweenService:Create(mainPanel, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    }):Play()
    
    -- Anima todos os elementos filhos
    for _, child in ipairs(mainPanel:GetDescendants()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("Frame") then
            tweenService:Create(child, TweenInfo.new(0.5), {
                BackgroundTransparency = 1,
                TextTransparency = 1
            }):Play()
        end
    end
    
    -- Remove a GUI após a animação
    wait(0.5)
    screenGui:Destroy()
end)

-- Container de Botões
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(1, -20, 1, -60)
buttonContainer.Position = UDim2.new(0, 10, 0, 50)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = mainPanel

-- Layout dos botões
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = buttonContainer

-- Função para criar botões
local function createScriptButton(name, scriptUrl)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = buttonContainer
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Status do script
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 10, 0, 10)
    status.Position = UDim2.new(0.05, 0, 0.5, -5)
    status.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    status.Text = ""
    status.Parent = button
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(1, 0)
    statusCorner.Parent = status
    
    -- Estado do script
    local isLoaded = false
    
    -- Efeitos do botão
    button.MouseEnter:Connect(function()
        tweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        tweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)
    
    -- Modifica o evento de clique para carregar do GitHub
    button.MouseButton1Click:Connect(function()
        if not isLoaded then
            status.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
            
            local success, result = pcall(function()
                loadstring(game:HttpGet(scriptUrl))()
            end)
            
            if success then
                status.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                isLoaded = true
            else
                status.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                warn("Erro ao carregar script:", result)
            end
        else
            status.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        end
    end)
end

-- Criar botões para cada script
for _, scriptInfo in ipairs(scripts) do
    createScriptButton(scriptInfo.name, scriptInfo.url)
end

-- Tornar o painel arrastável
local isDragging = false
local dragStart = nil
local startPos = nil

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = mainPanel.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainPanel.Position = UDim2.new(
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
