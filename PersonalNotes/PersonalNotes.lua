-- Inicializar el addon cuando se carga
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, addon)
    if addon == "PersonalNotes" then
        -- Inicializar PersonalNotesDB si no existe
        if type(PersonalNotesDB) ~= "table" then
            PersonalNotesDB = {}  -- Inicializar como una tabla vacía si no se ha inicializado
        end
    end
end)

-- Crear el marco principal para la ventana de notas
local notesFrame = CreateFrame("Frame", "NotesFrame", UIParent, "BasicFrameTemplateWithInset")
notesFrame:SetSize(400, 350)
notesFrame:SetPoint("CENTER")
notesFrame:SetMovable(true)
notesFrame:EnableMouse(true)
notesFrame:RegisterForDrag("LeftButton")
notesFrame:SetScript("OnDragStart", notesFrame.StartMoving)
notesFrame:SetScript("OnDragStop", notesFrame.StopMovingOrSizing)
notesFrame:Hide()

-- Título para la ventana de notas
local title = notesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", notesFrame, "TOP", 0, -10)
title:SetText("Personal Notes")

-- Etiqueta de nombre de la nota
local nameLabel = notesFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
nameLabel:SetPoint("TOPLEFT", notesFrame, "TOPLEFT", 10, -40)
nameLabel:SetText("Note Name:")

local nameInput = CreateFrame("EditBox", nil, notesFrame, "InputBoxTemplate")
nameInput:SetSize(350, 25)
nameInput:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -5)
nameInput:SetAutoFocus(false)
nameInput:SetText("")
nameInput:SetScript("OnTextChanged", function(self)
    -- Guardar el nombre de la nota
    self.noteName = self:GetText()
end)

-- Crear el cuadro de texto para editar el contenido de la nota
local editBox = CreateFrame("EditBox", nil, notesFrame, "InputBoxTemplate")
editBox:SetMultiLine(true)
editBox:SetSize(350, 200)  -- Hacer más grande el cuadro de texto
editBox:SetPoint("TOP", nameInput, "BOTTOM", 0, -10)
editBox:SetAutoFocus(false)
editBox:SetText("")
editBox:SetScript("OnTextChanged", function(self)
    -- Almacenar el índice de la nota al editar una existente
    self.noteIndex = self.noteIndex or nil
end)

-- Crear un marco para mostrar la lista de notas
local noteList = CreateFrame("Frame", nil, notesFrame)
noteList:SetSize(350, 130)
noteList:SetPoint("TOP", editBox, "BOTTOM", 0, -10)

-- Función para actualizar la lista de notas
local function updateNoteList()
    -- Asegurarse de que PersonalNotesDB sea una tabla antes de usarla
    if type(PersonalNotesDB) ~= "table" then
        PersonalNotesDB = {}  -- Inicializar como una tabla vacía si no se ha inicializado
    end

    -- Limpiar la lista de notas existente
    for _, button in pairs(noteList.buttons or {}) do
        button:Hide()
    end

    noteList.buttons = noteList.buttons or {}

    -- Agregar botones para cada nota guardada
    for i, noteData in ipairs(PersonalNotesDB) do
        local noteButton = CreateFrame("Button", nil, noteList, "UIPanelButtonTemplate")
        noteButton:SetSize(250, 25)
        noteButton:SetPoint("TOP", noteList, "TOP", 0, -30 * (i - 1))
        noteButton:SetText(noteData.name)
        noteButton:SetScript("OnClick", function()
            -- Cargar la nota seleccionada en el cuadro de texto y campo de nombre
            editBox:SetText(noteData.text)
            nameInput:SetText(noteData.name)
            editBox.noteIndex = i
        end)

        -- Botón para eliminar la nota
        local deleteButton = CreateFrame("Button", nil, noteButton, "UIPanelButtonTemplate")
        deleteButton:SetSize(50, 25)
        deleteButton:SetPoint("RIGHT", noteButton, "RIGHT", -5, 0)
        deleteButton:SetText("Delete")
        deleteButton:SetScript("OnClick", function()
            -- Eliminar la nota seleccionada
            table.remove(PersonalNotesDB, i)
            updateNoteList()  -- Actualizar la lista de notas después de la eliminación
        end)

        -- Agregar el botón de la nota a la lista
        table.insert(noteList.buttons, noteButton)
    end
end

-- Crear un botón para guardar una nueva nota
local saveButton = CreateFrame("Button", nil, notesFrame, "UIPanelButtonTemplate")
saveButton:SetSize(80, 25)
saveButton:SetPoint("BOTTOMLEFT", notesFrame, "BOTTOMLEFT", 10, 10)
saveButton:SetText("Save")
saveButton:SetScript("OnClick", function()
    local noteName = nameInput:GetText()
    local noteText = editBox:GetText()

    if noteName ~= "" and noteText ~= "" then
        -- Asegurarse de que PersonalNotesDB sea una tabla antes de insertar una nueva nota
        if type(PersonalNotesDB) ~= "table" then
            PersonalNotesDB = {}  -- Inicializar como una tabla vacía si no se ha inicializado
        end

        if editBox.noteIndex then
            -- Si se está editando una nota existente, actualizarla
            PersonalNotesDB[editBox.noteIndex] = {name = noteName, text = noteText}
        else
            -- Si no, agregar una nueva nota
            table.insert(PersonalNotesDB, {name = noteName, text = noteText})
        end

        -- Limpiar los campos de entrada y actualizar la lista
        editBox:SetText("")
        nameInput:SetText("")
        editBox.noteIndex = nil
        updateNoteList()
    end
end)

-- Crear un botón para cerrar la ventana
local closeButton = CreateFrame("Button", nil, notesFrame, "UIPanelButtonTemplate")
closeButton:SetSize(80, 25)
closeButton:SetPoint("BOTTOMRIGHT", notesFrame, "BOTTOMRIGHT", -10, 10)
closeButton:SetText("Close")
closeButton:SetScript("OnClick", function()
    notesFrame:Hide()
end)

-- Comandos para abrir/cerrar el addon en español e inglés
SLASH_PERSONALNOTES1 = "/notas"
SLASH_PERSONALNOTES2 = "/notes"
SlashCmdList["PERSONALNOTES"] = function()
    if notesFrame:IsShown() then
        notesFrame:Hide()  -- Ocultar la ventana si ya está abierta
    else
        notesFrame:Show()  -- Mostrar la ventana si está cerrada
        updateNoteList()   -- Actualizar la lista de notas al abrir la ventana
    end
end
