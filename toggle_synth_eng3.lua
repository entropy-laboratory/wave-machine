reaper.Undo_BeginBlock()

-- znajdź ścieżkę SYNTH
function FindTrackByName(name)
  for i = 0, reaper.CountTracks(0)-1 do
    local tr = reaper.GetTrack(0,i)
    local retval, track_name = reaper.GetTrackName(tr,"")
    if retval and track_name == name then
      return tr
    end
  end
  return nil
end

local track = FindTrackByName("SYNTH")

if track then

  -- indeksy FX w REAPER zaczynają się od 0
  local fx2 = 1
  local fx3 = 2
  local fx4 = 3

  if reaper.TrackFX_GetCount(track) >= 4 then
    reaper.TrackFX_SetNamedConfigParm(track, fx2, "renamed_name", "OFF")
    reaper.TrackFX_SetNamedConfigParm(track, fx3, "renamed_name", "OFF")
    reaper.TrackFX_SetNamedConfigParm(track, fx4, "renamed_name", "SYNTH")
  end

end

reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()

reaper.Undo_EndBlock("Set SYNTH FX names", -1)