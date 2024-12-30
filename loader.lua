local Players = game:GetService("Players")
local player = Players.LocalPlayer
local tweenService = game:GetService("TweenService")

-- Configurações de tema
local THEME = {
    primary = Color3.fromRGB(216, 25, 64),    -- #d81940
    secondary = Color3.fromRGB(30, 30, 35),   -- Fundo escuro
    accent = Color3.fromRGB(240, 240, 240),   -- Texto claro
    background = Color3.fromRGB(20, 20, 25),  -- Fundo mais escuro
    success = Color3.fromRGB(50, 255, 50),
    warning = Color3.fromRGB(255, 255, 50),
    error = Color3.fromRGB(255, 50, 50)
}

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
screenGui.Name = "RubyScriptHub"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Container Principal
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 800, 0, 500)
mainContainer.Position = UDim2.new(0.5, -400, 0.5, -250)
mainContainer.BackgroundColor3 = THEME.background
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 200, 1, 0)
sidebar.BackgroundColor3 = THEME.secondary
sidebar.BorderSizePixel = 0
sidebar.Parent = mainContainer

-- Logo Container
local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(1, 0, 0, 100)
logoContainer.BackgroundColor3 = THEME.primary
logoContainer.BorderSizePixel = 0
logoContainer.Parent = sidebar

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
contentContainer.Size = UDim2.new(1, -40, 1, -40)
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
local function createScriptButton(name, scriptUrl)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = name
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.Parent = scriptList
    
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

-- Criar botões para cada script
for _, scriptInfo in ipairs(scripts) do
    createScriptButton(scriptInfo.name, scriptInfo.url)
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
