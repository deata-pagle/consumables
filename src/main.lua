-- Return the complement t1 - t2
-- WARNING: This is destructive for t1
local function tableDifference(t1, t2)
    local hasValue = {};

    for k,v in pairs(t1) do
        if t2[k] ~= nil then
            t1[k] = nil;
        end
    end
end

-- The "with" argument decides whether we return players with or without consumables
local function GetRaidersConsumables(msg, editbox, with, verbose)
    local players = {};
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

        -- Add player name to list
        local playerName = UnitName(unitID);
        players[playerName] = {};

        for i=1, 40 do
            local buffID = select(10, UnitBuff(unitID, i));

            if buffID == nil then
                break;
            end

            for _, consumable in pairs(CONSUMABLES_BY_CLASSES[class]) do
                consumableBuffID = consumable["buffID"];
                consumableItemID = consumable["itemID"];

                if buffID == consumableBuffID then
                    if playersWithConsumables[playerName] == nil then
                        playersWithConsumables[playerName] = {consumableItemID};
                    else
                        table.insert(playersWithConsumables[playerName], consumableItemID);
                    end
                end
            end
        end
    end

    -- Chooses the proper wording for each use-case
    local operand = "with";
    if not with then
        operand = operand .. "out";
    end

    -- If "with" is false, reverse the result set
    local playersOutput = playersWithConsumables;
    if not with then
        tableDifference(players, playersWithConsumables);
        playersOutput = players;
    end

    -- Sort the output for Zeebub
    local sortedKeys = {};
    for key in pairs(playersOutput) do
        table.insert(sortedKeys, key);
    end
    table.sort(sortedKeys);

    local playersConsumablesStr = "";

    -- Print full consumables details
    if verbose then
        print("Player consumable details:");

        for _, playerName in pairs(sortedKeys) do
            local consumables = playersOutput[playerName];

            for i, itemID in pairs(consumables) do
                local itemLink = select(2, GetItemInfo(itemID));
                local itemIcon = select(10, GetItemInfo(itemID));
                playersConsumablesStr = playersConsumablesStr .. "|T" .. itemIcon .. ":0|t" .. itemLink;

                if table.getn(consumables) ~= i then
                    playersConsumablesStr = playersConsumablesStr .. ", ";
                end
            end

            print("|cff00FF00" .. playerName .. "|r: " .. playersConsumablesStr);
        end
    -- Print names only
    else
        playersConsumablesStr = "Players " .. operand .. " consumables: ";

        for i, playerName in pairs(sortedKeys) do
            playersConsumablesStr = playersConsumablesStr .. playerName;

            if table.getn(sortedKeys) ~= i then
                playersConsumablesStr = playersConsumablesStr .. ", ";
            end
        end

        print(playersConsumablesStr);
    end
end

local function SlashCmdHandler(msg, editbox)
    if msg == "none" or msg == "no" then
        GetRaidersConsumables(msg, editbox, false, false);
    elseif msg == "verbose" or msg == "v" then
        GetRaidersConsumables(msg, editbox, true, true);
    else
        GetRaidersConsumables(msg, editbox, true, false);
    end
end

SLASH_CONSUMABLES1 = "/consumables";
SlashCmdList["CONSUMABLES"] = SlashCmdHandler;