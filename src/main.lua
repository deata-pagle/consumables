SLASH_CONSUMABLES1 = "/consumables";

local function GetRaidersWithConsumables(msg, editbox)
    local playersWithConsumables = {};
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

        if hasConsumable then
            local playerName = UnitName(unitID);
            table.insert(playersWithConsumables, playerName);
        end

    end

    local playersWithConsumablesStr = ""
    for i, playerName in pairs(playersWithConsumables) do
        playersWithConsumablesStr = playersWithConsumablesStr .. playerName;

        if table.getn(playersWithConsumables) ~= i then
            playersWithConsumablesStr = playersWithConsumablesStr .. ", ";
        end
    end

    print("Players with consumables: " .. playersWithConsumablesStr);
end

SlashCmdList["CONSUMABLES"] = GetRaidersWithConsumables;