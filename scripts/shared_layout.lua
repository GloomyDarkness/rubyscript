local LAYOUT = {
    CLOSE_BUTTON = {
        size = UDim2.new(0, 30, 0, 30),
        position = UDim2.new(1, -40, 0, 10),
        safeArea = UDim2.new(1, -80, 1, 0) -- Área segura para conteúdo
    },
    PADDING = {
        top = 10,
        right = 80, -- Espaço extra para o botão fechar
        bottom = 10,
        left = 10
    }
}

return LAYOUT
