# MiningClient-lib

The Lib for our bigger Mining Project

This is the script can be run without a Server if the miningClientSmall-Script is installed.

## This script is WIP

thus far, only stripmines with a Scanner Attached and only really works with the miningClientSmall-Script.

```lua
--- Runs though all points in the ScanDataTable.
--- on each point, it uses the Scanner and Mines all Ores it finds
--- in the end, it returns to the Startingposition
---@param points ScanDataTable
function miningLib:main(points)



--- Checks if the Scanner is attached. Get all the scanned
--- WIP: Not finished: if no scanner is Attached -> stripmines
function miningLib:mineArea()



--- turtle goes to the provided point
---@param point ScanData
function miningLib:goToPoint(point)
```
