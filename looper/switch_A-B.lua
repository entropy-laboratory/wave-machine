-- Toggle record arm między trackami A i B

local PREFIX_A = "A"
local PREFIX_B = "B"

reaper.Undo_BeginBlock()

local track_count = reaper.CountTracks(0)
local active_prefix = nil

-- sprawdź który prefix jest obecnie armed
for i = 0, track_count - 1 do
  local track = reaper.GetTrack(0, i)
  local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
  local prefix = name:match("^(%S+)")

  if prefix == PREFIX_A or prefix == PREFIX_B then
    local armed = reaper.GetMediaTrackInfo_Value(track, "I_RECARM")
    if armed == 1 then
      active_prefix = prefix
      break
    end
  end
end

-- wybierz target (default = A jeśli nic nie armed)
local target_prefix
if active_prefix == PREFIX_A then
  target_prefix = PREFIX_B
else
  target_prefix = PREFIX_A
end

-- przełącz record arm
for i = 0, track_count - 1 do
  local track = reaper.GetTrack(0, i)
  local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
  local prefix = name:match("^(%S+)")

  if prefix == PREFIX_A or prefix == PREFIX_B then
    local arm = (prefix == target_prefix) and 1 or 0
    reaper.SetMediaTrackInfo_Value(track, "I_RECARM", arm)
  end
end

reaper.Undo_EndBlock("Toggle Record Arm A/B", -1)
reaper.UpdateArrange()
