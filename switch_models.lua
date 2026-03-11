local prefixes = { "1","2","3","4","A","B","C","D" }

function TrackMatches(name)
  local first = name:sub(1,1)
  for i=1,#prefixes do
    if first == prefixes[i] then return true end
  end
  return false
end

reaper.Undo_BeginBlock()

local track_count = reaper.CountTracks(0)

for t = 0, track_count-1 do

  local track = reaper.GetTrack(0,t)
  local _, track_name = reaper.GetTrackName(track,"")

  if TrackMatches(track_name) then

    local fx_count = reaper.TrackFX_GetCount(track)

    local main_fx = -1
    local mainp_fx = -1

    for fx = 0, fx_count-1 do
      local _, fx_name = reaper.TrackFX_GetFXName(track,fx,"")

      if fx_name:find("MAIN") then
        mainp_fx = fx
      elseif fx_name:find("SECONDARY") then
        main_fx = fx
      end
    end

    if main_fx ~= -1 and mainp_fx ~= -1 then
      reaper.TrackFX_SetNamedConfigParm(track, main_fx, "renamed_name", "MAIN")
      reaper.TrackFX_SetNamedConfigParm(track, mainp_fx, "renamed_name", "SECONDARY")
    end

  end

end

reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()

reaper.Undo_EndBlock("Swap MAIN / SECONDARY", -1)
