-- Konfiguracja
local track_name = "POST"
local fx_name_match = "DELAY"
local preset_list = { "Delay 1", "Delay 2", "Delay 3" }

-- Znajduje ścieżkę po nazwie
function FindTrackByName(name)
  for i = 0, reaper.CountTracks(0) - 1 do
    local tr = reaper.GetTrack(0, i)
    local retval, curr_name = reaper.GetTrackName(tr, "")
    if retval and curr_name == name then
      return tr
    end
  end
  return nil
end

-- Znajduje indeks FX zawierającego nazwę
function FindFXIndex(track, fx_name_part)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    if retval and fx_name:match(fx_name_part) then
      return i
    end
  end
  return -1
end

-- Znajduje indeks następnego presetu
function GetNextPresetIndex(current, presets)
  for i = 1, #presets do
    if presets[i] == current then
      return (i % #presets) + 1  -- cyklicznie
    end
  end
  return 1  -- jeśli obecny nieznany, wracamy do pierwszego
end

-- Główne wykonanie
reaper.Undo_BeginBlock()

local track = FindTrackByName(track_name)
if not track then return end

local fx_index = FindFXIndex(track, fx_name_match)
if fx_index == -1 then return end

-- Pobierz nazwę aktualnego presetu
local retval, current_preset = reaper.TrackFX_GetPreset(track, fx_index)
if not retval then return end

-- Ustal kolejny preset
local next_index = GetNextPresetIndex(current_preset, preset_list)
local next_preset = preset_list[next_index]

-- Ustaw preset
reaper.TrackFX_SetPreset(track, fx_index, next_preset)

reaper.Undo_EndBlock("Cykliczne przełączenie presetu FX", -1)
