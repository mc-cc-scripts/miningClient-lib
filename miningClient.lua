---@class miningLib
-- Settings:
-- - MiningSettings
miningLib = {}

---@class scm
local scm = require("./scm")
---@class Scanner
local scanner = scm:load("scanner")
---@class turtleController
local tC = scm:load("turtleController")
---@class SettingManager
local sM = scm:load("settingsManager")
---@class HelperFunctions
local helper = scm:load("helperFunctions")

-- DEFINITIONS
---@class MiningSettings
---@field miningDepth number
---@field miningHight number
---@field miningDiameter number
---@field scanRadius number
local miningSettings = {}

local postionmappingTable = {
    ["X"] = 0,
    ["Z"] = 1,
    ["-X"] = 2,
    ["-Z"] = 3,
}

miningLib.scanStartFacingTo = nil
miningLib.hasChuncky = false

-- ToDo: Add Points.
-- TODO: Save original Point to rdeturn to

-- Doing: Mining the Points

---corrects the Points relative to the direction the turtle is facing
---@param data ScanDataTable
---@return ScanDataTable
local function modifyForFacingPosition(data)
    assert(miningLib.scanStartFacingTo ~= nil, "Missing facing direction, cannot convert data")
    return scanner.correctToFacing(data, postionmappingTable[miningLib.scanStartFacingTo])
end

---uses the Data from the Scanner to mine all blocks provided in the Parameter
---@param data ScanDataTable
local function mineWithScannData(data)
    data = scanner.sortFilteredScan(data)
    data = modifyForFacingPosition(data)
    if data == nil then
        return
    end
    local path = scanner.createPath(data)
    if #path < 2 then
        return
    end
    for _, pathToPoint in ipairs(path) do
        tC:compactMove(pathToPoint)
    end
end


--- turtle goes to the provided point
---@param point ScanData
function miningLib:goToPoint(point)
    local singlePoint = {}
    table.insert(singlePoint, point)
    local path = scanner.createPath(singlePoint)
    path = path[1]
    tC:compactMove(path)
end

--- Checks if the Scanner is attached. Get all the scanned
---  WIP: Not finished: if no scanner is Attached -> stripmines
function miningLib:mineArea()
    ---@type ScanDataTable | nil
    local ores
    if self.hasChuncky then
        local slot = tC:findItemInInventory("advancedperipherals:geo_scanner")
        assert(slot ~= nil, "No Scanner found")
        turtle.select(slot)
        turtle.equipRight()
    end
    ores = scanner.find(miningSettings.scanRadius)
    if self.hasChuncky then
        local slot = tC:findItemInInventory("minecraft:diamond_pickaxe")
        assert(slot ~= nil, "pickaxe not found")
        turtle.select(slot)
        turtle.equipRight()
    end
    if ores ~= nil then
        mineWithScannData(ores)
        return
    end
    error("No Scanner -> not implemented")
end

--- Runs though all points in the ScanDataTable.
--- on each point, it uses the Scanner and Mines all Ores it finds
--- in the end, it returns to the Startingposition
---@param points ScanDataTable
function miningLib:main(points)
    assert(nil ~= tC:findItemInInventory("advancedperipherals:geo_scanner"), "No Scanner found")
    local slot = tC:findItemInInventory("advancedperipherals:chunk_controller")
    if slot then
        turtle.select(slot)
        turtle.equipLeft()
        miningLib.hasChuncky = true
    else
        local slot = tC:findItemInInventory("advancedperipherals:geo_scanner")
        assert(slot ~= nil, "No Scanner found")
        turtle.select(slot)
        turtle.equipLeft()
    end
    slot = tC:findItemInInventory("minecraft:diamond_pickaxe")
    assert(slot ~= nil, "pickaxe not found")
    turtle.select(slot)
    turtle.equipRight()
    local movedfromStart = { x = 0, y = 0, z = 0 }
    tC.canBreakBlocks = true
    miningSettings = { miningDepth = -50, miningHight = 3, miningDiameter = 9, scanRadius = 4 };
    miningSettings = sM.setget('MiningSettings', nil, miningSettings);
    
    for _, w in ipairs(points) do
        movedfromStart.x = movedfromStart.x + w.x
        movedfromStart.y = movedfromStart.y + w.y
        movedfromStart.z = movedfromStart.z + w.z
        self:goToPoint(w)
        self:mineArea()
    end
    
    local path = scanner.createPath({ movedfromStart })
    if #path > 2 then
        tC:compactMove(path[2])
        tC:compactMove(path[3])
    end
end

return miningLib