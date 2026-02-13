-- Nazwa ścieżki
local track_name = "SYNTH"

-- Znajdź ścieżkę po nazwie
function FindTrackByName(name)
  for i = 0, reaper.CountTracks(0) - 1 do
    local tr = reaper.GetTrack(0, i)
    local retval, curr_name = reaper.GetTrackName(tr, "")
    if retval and curr_name == name then
      return tr, i
    end
  end
  return nil, -1
end

----------------------------------------

reaper.Undo_BeginBlock()

local track, track_index = FindTrackByName(track_name)
if not track then return end

-- Sprawdź który FX jest aktualnie aktywny (focused)
local retval, tracknum, itemnum, fxnum = reaper.GetFocusedFX()

-- retval:
-- 1 = track FX
-- 2 = item FX
-- 0 = brak focusa

if retval ~= 1 then return end

-- upewnij się, że focus jest na właściwej ścieżce
if tracknum - 1 ~= track_index then return end

-- przełącz na następny preset
reaper.TrackFX_NavigatePresets(track, fxnum, 1)

reaper.Undo_EndBlock("Next preset na aktywnym VST (SYNTH)", -1)
