local Players = game:GetService("Players")
local player = Players.LocalPlayer
local tweenService = game:GetService("TweenService")

-- Adicione no início do arquivo
local LAYOUT = require(script.Parent.shared_layout)

-- Tema atualizado com cores mais profissionais
local THEME = {
    primary = Color3.fromRGB(79, 70, 229),    -- Indigo profissional
    secondary = Color3.fromRGB(17, 24, 39),   -- Slate escuro
    accent = Color3.fromRGB(243, 244, 246),   -- Texto claro
    background = Color3.fromRGB(11, 15, 25),  -- Fundo escuro elegante
    cardBg = Color3.fromRGB(22, 27, 34),      -- Card background github-style
    success = Color3.fromRGB(34, 197, 94),    -- Verde elegante
    warning = Color3.fromRGB(234, 179, 8),    -- Amarelo suave
    error = Color3.fromRGB(239, 68, 68),      -- Vermelho moderno
    hover = Color3.fromRGB(55, 48, 163),      -- Hover indigo escuro
    border = Color3.fromRGB(30, 41, 59),      -- Bordas sutis
}

-- Scripts atualizados em inglês
local scripts = {
    {
        name = "Fruit Finder",
        description = "Automatically locate and teleport to fruits",
        url = "https://raw.githubusercontent.com/GloomyDarkness/rubyscript/main/scripts/bloxFruitDetector.lua"
    },
    {
        name = "Advanced Teleport",
        description = "Smooth teleportation with noclip feature",
        url = "https://raw.githubusercontent.com/GloomyDarkness/rubyscript/main/scripts/teleport.lua"
    },
    {
        name = "Item Radar",
        description = "Track and locate valuable items",
        url = "https://raw.githubusercontent.com/GloomyDarkness/rubyscript/main/scripts/itemDetector.lua"
    },
    {
        name = "Bandit Hunter",
        description = "Automated bandit farming system",
        url = "https://raw.githubusercontent.com/GloomyDarkness/rubyscript/main/scripts/banditFarm.lua"
    }
}

-- Interface do Loader
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RubyScriptHub"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Container Principal
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 900, 0, 550)
mainContainer.Position = UDim2.new(0.5, -450, 0.5, -275)
mainContainer.BackgroundColor3 = THEME.background
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainContainer

-- Adicione após a criação do mainContainer
local closeButton = Instance.new("TextButton")
closeButton.Size = LAYOUT.CLOSE_BUTTON.size
closeButton.Position = LAYOUT.CLOSE_BUTTON.position
closeButton.BackgroundColor3 = THEME.error
closeButton.Text = "×"
closeButton.TextColor3 = THEME.accent
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 20
closeButton.Parent = mainContainer

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Adicione a função fadeOut
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

-- Adicione a função de fechamento
closeButton.MouseButton1Click:Connect(function()
    local tweens = {}
    for _, obj in ipairs(mainContainer:GetDescendants()) do
        local tween = fadeOut(obj)
        if tween then
            table.insert(tweens, tween)
            tween:Play()
        end
    end
    
    -- Anima o container principal por último
    tweenService:Create(mainContainer, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    }):Play()
    
    -- Remove após todas as animações
    task.delay(0.6, function()
        pcall(function()
            screenGui:Destroy()
        end)
    end)
end)

-- Sombra melhorada
local function addEnhancedShadow(frame)
    local shadow = Instance.new("ImageLabel")
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://7919581359"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Parent = frame
    
    -- Adiciona um brilho sutil nas bordas
    local glow = Instance.new("ImageLabel")
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://7919581359"
    glow.ImageColor3 = THEME.primary
    glow.ImageTransparency = 0.9
    glow.Position = UDim2.new(0, -15, 0, -15)
    glow.Size = UDim2.new(1, 30, 1, 30)
    glow.ZIndex = frame.ZIndex - 1
    glow.Parent = frame
end

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 200, 1, 0)
sidebar.BackgroundColor3 = THEME.secondary
sidebar.BorderSizePixel = 0
sidebar.Parent = mainContainer

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 12)
sidebarCorner.Parent = sidebar

-- Logo Container
local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(1, 0, 0, 100)
logoContainer.BackgroundColor3 = THEME.primary
logoContainer.BorderSizePixel = 0
logoContainer.Parent = sidebar

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 12)
logoCorner.Parent = logoContainer

-- Logo Text
local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "Ruby\nScript Hub"
logoText.TextColor3 = THEME.accent
logoText.Font = Enum.Font.GothamBold
logoText.TextSize = 24
logoText.Parent = logoContainer

-- Navigation Buttons Container
local navContainer = Instance.new("Frame")
navContainer.Size = UDim2.new(1, 0, 1, -100)
navContainer.Position = UDim2.new(0, 0, 0, 100)
navContainer.BackgroundTransparency = 1
navContainer.Parent = sidebar

-- Navigation Buttons
local navButtons = {
    {name = "Scripts", icon = "🎮"},
    {name = "Settings", icon = "⚙️"},
    {name = "About", icon = "ℹ️"}
}

-- Content Area
local contentArea = Instance.new("Frame")
local contentContainer = Instance.new("Frame")
local scriptsPage = Instance.new("Frame")
local settingsPage = Instance.new("Frame")
local aboutPage = Instance.new("Frame")

-- Função para criar botões de navegação
local function createNavButton(info, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 50)
    button.Position = UDim2.new(0, 0, 0, (index-1) * 60)
    button.BackgroundTransparency = 1
    button.Text = info.icon .. " " .. info.name
    button.TextColor3 = THEME.accent
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 16
    button.Parent = navContainer
    
    -- Indicador de seleção
    local selector = Instance.new("Frame")
    selector.Size = UDim2.new(0, 4, 1, -20)
    selector.Position = UDim2.new(0, 0, 0, 10)
    selector.BackgroundColor3 = THEME.primary
    selector.BackgroundTransparency = 1
    selector.Parent = button
    
    -- Efeitos hover
    button.MouseEnter:Connect(function()
        tweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundColor3 = THEME.primary,
            BackgroundTransparency = 0.9
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        if button.Selected then return end
        tweenService:Create(button, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        }):Play()
    end)
    
    return button, selector
end

-- Adiciona área de conteúdo
contentArea.Size = UDim2.new(1, -200, 1, 0)
contentArea.Position = UDim2.new(0, 200, 0, 0)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainContainer

-- Adiciona os containers de conteúdo
contentContainer.Size = LAYOUT.CLOSE_BUTTON.safeArea
contentContainer.Position = UDim2.new(0, 20, 0, 20)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = contentArea

-- Cria as páginas
local pages = {
    Scripts = scriptsPage,
    Settings = settingsPage,
    About = aboutPage
}

-- Configura cada página
for name, page in pairs(pages) do
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = name == "Scripts"
    page.Parent = contentContainer
end

-- Função para trocar páginas
local function switchPage(pageName)
    for name, page in pairs(pages) do
        page.Visible = name == pageName
    end
end

-- Cria os botões de navegação e conecta eventos
for i, info in ipairs(navButtons) do
    local button, selector = createNavButton(info, i)
    button.MouseButton1Click:Connect(function()
        switchPage(info.name)
        
        -- Atualiza seleção visual
        for _, btn in ipairs(navContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.Selected = btn == button
                btn:FindFirstChild("Frame").BackgroundTransparency = btn == button and 0 or 1
            end
        end
    end)
end

-- Adiciona conteúdo à página Scripts
local scriptList = Instance.new("ScrollingFrame")
scriptList.Size = UDim2.new(1, 0, 1, 0)
scriptList.BackgroundTransparency = 1
scriptList.ScrollBarThickness = 4
scriptList.Parent = scriptsPage

-- Layout para os scripts
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = scriptList

-- Função melhorada para criar botões de script
local function createScriptButton(scriptInfo)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 90)
    card.BackgroundColor3 = THEME.cardBg
    card.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card

    -- Adiciona efeito de hover no card
    local hoverEffect = Instance.new("Frame")
    hoverEffect.Size = UDim2.new(1, 0, 1, 0)
    hoverEffect.BackgroundColor3 = THEME.primary
    hoverEffect.BackgroundTransparency = 1
    hoverEffect.ZIndex = 2
    hoverEffect.Parent = card

    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 10)
    hoverCorner.Parent = hoverEffect

    -- Info container com padding melhorado
    local infoContainer = Instance.new("Frame")
    infoContainer.Size = UDim2.new(1, -120, 1, -20)
    infoContainer.Position = UDim2.new(0, 20, 0, 10)
    infoContainer.BackgroundTransparency = 1
    infoContainer.Parent = card

    -- Nome do script com fonte atualizada
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 25)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = scriptInfo.name
    nameLabel.TextColor3 = THEME.accent
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 18
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = infoContainer

    -- Descrição com estilo melhorado
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 0, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = scriptInfo.description
    descLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 14
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = infoContainer

    -- Botão de execução modernizado
    local executeButton = Instance.new("TextButton")
    executeButton.Size = UDim2.new(0, 100, 0, 36)
    executeButton.Position = UDim2.new(1, -120, 0.5, -18)
    executeButton.BackgroundColor3 = THEME.primary
    executeButton.Text = "Execute"
    executeButton.TextColor3 = THEME.accent
    executeButton.Font = Enum.Font.GothamBold
    executeButton.TextSize = 14
    executeButton.AutoButtonColor = false
    executeButton.Parent = card

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = executeButton

    -- Estado do script
    local isLoaded = false
    
    -- Efeitos do botão
    executeButton.MouseEnter:Connect(function()
        tweenService:Create(executeButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(55, 48, 163)  -- Cor mais escura ao hover
        }):Play()
    end)
    
    executeButton.MouseLeave:Connect(function()
        tweenService:Create(executeButton, TweenInfo.new(0.3), {
            BackgroundColor3 = THEME.primary
        }):Play()
    end)
    
    executeButton.MouseButton1Click:Connect(function()
        if not isLoaded then
            executeButton.Text = "Loading..."
            
            local success, result = pcall(function()
                local scriptContent = game:HttpGet(scriptInfo.url)
                print("[Ruby Script Hub] Loading: " .. scriptInfo.name)
                print("[Ruby Script Hub] URL: " .. scriptInfo.url)
                loadstring(scriptContent)()
            end)
            
            if success then
                executeButton.Text = "Loaded"
                executeButton.BackgroundColor3 = THEME.success
                isLoaded = true
                print("[Ruby Script Hub] Successfully loaded: " .. scriptInfo.name)
            else
                executeButton.Text = "Error"
                executeButton.BackgroundColor3 = THEME.error
                warn("[Ruby Script Hub] Error loading script:", result)
                wait(2)
                executeButton.Text = "Retry"
                executeButton.BackgroundColor3 = THEME.primary
            end
        end
    end)

    -- Define o tamanho do ScrollingFrame baseado no conteúdo
    scriptList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)

    card.Parent = scriptList
    return card
end

-- Adiciona conteúdo à página Settings
local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 40)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "Settings"
settingsTitle.TextColor3 = THEME.accent
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 24
settingsTitle.Parent = settingsPage

-- Adiciona conteúdo à página About
local aboutTitle = Instance.new("TextLabel")
aboutTitle.Size = UDim2.new(1, 0, 0, 40)
aboutTitle.BackgroundTransparency = 1
aboutTitle.Text = "About Ruby Script Hub"
aboutTitle.TextColor3 = THEME.accent
aboutTitle.Font = Enum.Font.GothamBold
aboutTitle.TextSize = 24
aboutTitle.Parent = aboutPage

local aboutText = Instance.new("TextLabel")
aboutText.Size = UDim2.new(1, 0, 0, 100)
aboutText.Position = UDim2.new(0, 0, 0, 50)
aboutText.BackgroundTransparency = 1
aboutText.Text = "Version 1.0\nDeveloped by GloomyDarkness\n\nA professional script hub for Roblox"
aboutText.TextColor3 = THEME.accent
aboutText.Font = Enum.Font.Gotham
aboutText.TextSize = 16
aboutText.Parent = aboutPage

-- Modifique a seção de criação dos scripts
for _, scriptInfo in ipairs(scripts) do
    task.spawn(function()
        local success, result = pcall(function()
            createScriptButton(scriptInfo)
        end)
        if not success then
            warn("[Ruby Script Hub] Failed to create button for:", scriptInfo.name, result)
        end
    end)
end

-- Tornar o painel arrastável
local isDragging = false
local dragStart = nil
local startPos = nil

mainContainer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStart = input.Position
        startPos = mainContainer.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainContainer.Position = UDim2.new(
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
