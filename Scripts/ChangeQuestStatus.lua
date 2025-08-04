function Dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. Dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local blueprint_name = "BP_QuestSystem_C"
STATUS = { "NOT_STARTED", "STARTED", "COMPLETED", "CANCELED", "FAILED" }

function PrintCurrentQuestStatus()
    local quest_system = FindFirstOf(blueprint_name) ---@cast quest_system UBP_QuestSystem_C

    if not quest_system or not quest_system:IsValid() then
        print("Quest system not found")
        return
    end

    local quest_data = quest_system.QuestStatuses

    quest_data:ForEach(function (key, value)
        local quest_name = key:get():ToString()
        local quest_data = value:get() ---@type FS_QuestStatusData

        local quest_status = quest_data.QuestStatus_2_4D165F3F428FABC6B00F2BA89749B803
        local objectives = quest_data.ObjectivesStatus_8_EA1232C14DA1F6DDA84EBA9185000F56

        print("Quest: " .. quest_name .. " is " .. STATUS[quest_status] .. " " .. (quest_status))

        objectives:ForEach(function (key, value)
            local objective_name = key:get():ToString()
            local objective_status = value:get() ---@type E_QuestStatus

            print("\t\t Objective name: " .. objective_name .. " is " .. STATUS[objective_status] .. " " .. (objective_status))
        end)
    end)
end


RegisterKeyBind(MODS.ChangeQuestStatus.PressedKey, MODS.ChangeQuestStatus.Modifier_keys, function()
    ExecuteInGameThread(function()
        PrintCurrentQuestStatus()
    end)
end)


RegisterHook("/Game/Gameplay/Quests/System/BP_QuestSystem.BP_QuestSystem_C:UpdateActivitySubTaskStatus", function (self, objective_name, status)
    local quest_system = self:get() ---@type UBP_QuestSystem_C
    local objective_name_param = objective_name:get():ToString()
    local status_param = status:get()
    local found = false


    local quest_data = quest_system.QuestStatuses

    quest_data:ForEach(function (key, value)
        if found then return end
        local quest_name = key:get():ToString()
        local quest_data = value:get() ---@type FS_QuestStatusData

        local objectives = quest_data.ObjectivesStatus_8_EA1232C14DA1F6DDA84EBA9185000F56

        objectives:ForEach(function (key, _)
            if found then return end
            local objective_name = key:get():ToString()
            if objective_name_param == objective_name then
                print("Update objective: " .. objective_name .. " from quest: (" .. quest_name 
                ..  ") to " .. STATUS[status_param] .. " (" .. (status_param) .. ")")
                found = true
            end
        end)
    end)
end)

RegisterHook("/Game/Gameplay/Quests/System/BP_QuestSystem.BP_QuestSystem_C:UpdateActivityStatus", function (self, quest_name, status)
    local quest_system = self:get() ---@type UBP_QuestSystem_C
    local quest_name_param = quest_name:get() ---@type FName
    local status_param = status:get()


    local quest_data = quest_system.QuestStatuses
    local quest_data = quest_data:Find(quest_name_param):get() ---@type FS_QuestStatusData | nil

    if quest_data ~= nil then
        print("Update quest: " .. quest_name_param:ToString()
        .. ") to " .. STATUS[status_param] .. " (" .. (status_param) .. ")")
    else
        print("Quest not found when hooked function (" .. quest_name_param:ToString() .. ")")
    end
end)