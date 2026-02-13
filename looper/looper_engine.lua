-- SIMPLE LIVE LOOPER ENGINE

local track = reaper.GetSelectedTrack(0, 0)
if not track then return end

local function record()
  reaper.Main_OnCommand(1013, 0)
end

local function stop()
  reaper.Main_OnCommand(1016, 0)
end

local function undo()
  reaper.Main_OnCommand(40029, 0)
end

local function clear()
  local itemCount = reaper.CountTrackMediaItems(track)
  for i = itemCount-1, 0, -1 do
    local item = reaper.GetTrackMediaItem(track, i)
    reaper.DeleteTrackMediaItem(track, item)
  end
  reaper.UpdateArrange()
end

local function playpause()
  reaper.Main_OnCommand(40044, 0)
end

local function restart()
  reaper.SetEditCurPos(0, true, false)
end

-- PARAMETER DISPATCH
local _, _, sectionID, cmdID = reaper.get_action_context()
local action = reaper.GetExtState("LOOPER", "ACTION")

if action == "REC" then record() end
if action == "STOP" then stop() end
if action == "UNDO" then undo() end
if action == "CLEAR" then clear() end
if action == "PLAY" then playpause() end
if action == "RESTART" then restart() end

reaper.SetExtState("LOOPER", "ACTION", "", false)
