SLASH_CONSUMABLES1 = "/consumables";

local function GetRaidersWithoutConsumables(msg, editbox)
    local playersWithoutConsumables = {};
    local unitBase = IsInRaid() and "raid" or "party";

    for i = 1, GetNumGroupMembers() do
        local unitID = unitBase..i;

        local class = select(2, UnitClass(unitID));

        -- When landing on the player, we can get nil
        if class == nil then
            unitID = "player";
            class = select(2, UnitClass(unitID));
        end

        local hasConsumable = false;

        for i=1, 40 do
            local buffID = select(10, UnitBuff(unitID, i));

            if buffID == nil then
                break;
            end

            for _, rewardBuffID in pairs(CONSUMABLES_BY_CLASSES[class]) do
                if buffID == rewardBuffID then
                    hasConsumable = true;
                end
            end

            if hasConsumable then
                break;
            end
        end

        if not hasConsumable then
            local playerName = UnitName(unitID);
            table.insert(playersWithoutConsumables, playerName);
        end

    end

    local playersWithoutConsumablesStr = ""
    for i, playerName in pairs(playersWithoutConsumables) do
        playersWithoutConsumablesStr = playersWithoutConsumablesStr .. playerName;

        if table.getn(playersWithoutConsumables) ~= i then
            playersWithoutConsumablesStr = playersWithoutConsumablesStr .. ", ";
        end
    end

    print("Players without consumables: " .. playersWithoutConsumablesStr);
end

SlashCmdList["CONSUMABLES"] = GetRaidersWithoutConsumables;