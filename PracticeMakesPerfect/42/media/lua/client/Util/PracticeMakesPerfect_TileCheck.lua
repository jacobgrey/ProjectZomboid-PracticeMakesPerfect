require "Definitions/PracticeMakesPerfect_Log"

PMP = PMP or {}
PMP.TileCheck = PMP.TileCheck or {}

-- All methods below grepped in vanilla:
--   isFreeOrMidair(bool)  - ISBuildIsoEntity.lua, ISBuildingObject.lua
--   isSolid() / isSolidTrans() - ISCampingMenu.lua, ISPlace3DItemCursor.lua
--   HasStairs() - ISWoodenFloor.lua
--   getMovingObjects() - ISVehicleTrailerUtils.lua, campingCampfire.lua
local function squareIsClearFloor(sq)
    if not sq then return false end
    if not sq:isFreeOrMidair(true) then return false end
    if sq:HasStairs() then return false end
    if sq:isSolid() or sq:isSolidTrans() then return false end
    local moving = sq:getMovingObjects()
    if moving and moving:size() > 0 then return false end
    return true
end

function PMP.TileCheck.threeByThreeClear(player)
    local cell = getCell()
    if not cell then return false end
    local px, py, pz = player:getX(), player:getY(), player:getZ()
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                local sq = cell:getGridSquare(math.floor(px) + dx, math.floor(py) + dy, math.floor(pz))
                if not squareIsClearFloor(sq) then
                    return false, dx, dy
                end
            end
        end
    end
    return true
end
