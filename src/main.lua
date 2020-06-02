-- Return the complement t1 - t2
-- WARNING: This is destructive for t1
local function tableDifference(t1, t2)
    local hasValue = {};

    for _,v in pairs(t2) do
        hasValue[v] = true;
    end

    for k,v in pairs(t1) do 
        if hasValue[v] ~= nil then
            table.remove(t1, k);
        end
    end
end

-- The "with" argument decides whether we return players with or without consumables
local function GetRaidersConsumables(msg, editbox, with)
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

        local playerName = UnitName(unitID);
        if hasConsumable then
            table.insert(playersWithConsumables, playerName);
        end

        table.insert(players, playerName);
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
    table.sort(playersOutput)

    local playersConsumablesStr = ""
    for i, playerName in pairs(playersOutput) do
        playersConsumablesStr = playersConsumablesStr .. playerName;

        if table.getn(playersOutput) ~= i then
            playersConsumablesStr = playersConsumablesStr .. ", ";
        end
    end

    print("Players " .. operand .. " consumables: " .. playersConsumablesStr);
end

local function SlashCmdHandler(msg, editbox)
    if msg == "none" or msg == "no" then
        GetRaidersConsumables(msg, editbox, false);
    else
        GetRaidersConsumables(msg, editbox, true);
    end
end

SLASH_CONSUMABLES1 = "/consumables";
SlashCmdList["CONSUMABLES"] = SlashCmdHandler;