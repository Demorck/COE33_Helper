MODS = {
    TPToChest = {
        activate = true,
        PressedKey = Key.F1,
        Modifier_keys = { ModifierKey.CONTROL },
    },
    ChangeQuestStatus = {
        activate = true,
        PressedKey = Key.F1,
        Modifier_keys = { ModifierKey.ALT },
    },
}


for key, value in pairs(MODS) do
    if value.activate then
        require(key)
    end
end