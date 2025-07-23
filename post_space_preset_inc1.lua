-- Konfiguracja
local track_name = "POST"

-- Lista efektów i ich presetów
local fx_definitions = {
  {
    name_match = "DELAY",
    presets = { "Basic", "Sweet Lead", "Full Ambient" }
  },
  {
    name_match = "REVERB",
    presets = { "Basic", "Sweet Lead", "Full Ambient" }
  }
}

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

-- Przetwarzamy każdy FX z konfiguracji
for _, fx in ipairs(fx_definitions) do
  local fx_index = FindFXIndex(track, fx.name_match)
  if fx_index ~= -1 then
    local retval, current_preset = reaper.TrackFX_GetPreset(track, fx_index)
    if retval then
      local next_index = GetNextPresetIndex(current_preset, fx.presets)
      local next_preset = fx.presets[next_index]
      reaper.TrackFX_SetPreset(track, fx_index, next_preset)
    else
      -- Jeśli preset nieczytelny, ustaw pierwszy
      reaper.TrackFX_SetPreset(track, fx_index, fx.presets[1])
    end
  end
end

reaper.Undo_EndBlock("Cykliczne przełączenie presetów DELAY + REVERB", -1)
