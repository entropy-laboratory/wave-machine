-- Konfiguracja
local track_name = "POST"
local fx_configs = {
  { name_part = "DELAY", presets = { "DELAY 1", "DELAY 2", "DELAY 3" } },
  { name_part = "REVERB", presets = { "REVERB 1", "REVERB 2", "REVERB 3" } }
}

-- Funkcja do -- Debugowania
function DebugPrint(msg)
  reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

-- Normalizacja tekstu
function Normalize(str)
  return str:lower():match("^%s*(.-)%s*$")
end

-- Znajduje ścieżkę po nazwie
function FindTrackByName(name)
  -- DebugPrint("Szukam ścieżki: " .. name)
  for i = 0, reaper.CountTracks(0) - 1 do
    local tr = reaper.GetTrack(0, i)
    local retval, curr_name = reaper.GetTrackName(tr, "")
    -- DebugPrint("Sprawdzam ścieżkę " .. (i+1) .. ": '" .. curr_name .. "'")
    if retval and curr_name == name then
      -- DebugPrint("Znaleziono ścieżkę: " .. name)
      return tr
    end
  end
  -- DebugPrint("NIE znaleziono ścieżki: " .. name)
  return nil
end

-- Znajduje indeks FX
function FindFXIndex(track, fx_name_part)
  -- DebugPrint("Szukam FX na ścieżce '" .. fx_name_part .. "'")
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    -- DebugPrint("FX " .. i .. ": '" .. fx_name .. "'")
    if retval and fx_name:match(fx_name_part) then
      -- DebugPrint("Znaleziono FX: " .. fx_name .. " na indeksie " .. i)
      return i
    end
  end
  -- DebugPrint("NIE znaleziono FX: " .. fx_name_part)
  return -1
end

-- Znajduje indeks następnego presetu dla danej listy
function GetNextPresetIndex(current, presets)
  local norm_current = Normalize(current)
  -- DebugPrint("Aktualny preset: '" .. current .. "' (norm: '" .. norm_current .. "')")
  -- DebugPrint("Lista presetów:")
  for i, p in ipairs(presets) do
    -- DebugPrint("  " .. i .. ": '" .. p .. "' (norm: '" .. Normalize(p) .. "')")
  end

  for i = 1, #presets do
    if Normalize(presets[i]) == norm_current then
      local next_i = (i % #presets) + 1
      -- DebugPrint("Znaleziono pasujący preset na " .. i .. ", następny: " .. next_i .. " '" .. presets[next_i] .. "'")
      return next_i
    end
  end

  -- DebugPrint("Preset nie znaleziony w liście, fallback do 1")
  return 1
end

-----------------------------------------------------

reaper.Undo_BeginBlock()

local track = FindTrackByName(track_name)
if not track then 
  -- DebugPrint("BŁĄD: Brak ścieżki, koniec skryptu")
  reaper.Undo_EndBlock()
  return 
end

-- Znajdź indeksy wszystkich FX
local fx_indices = {}
for i, config in ipairs(fx_configs) do
  local fx_index = FindFXIndex(track, config.name_part)
  fx_indices[i] = fx_index
end

-- Pobierz aktualne presety i oblicz następne
local next_presets = {}
for i, config in ipairs(fx_configs) do
  local fx_index = fx_indices[i]
  if fx_index ~= -1 then
    local retval, current_preset = reaper.TrackFX_GetPreset(track, fx_index)
    -- DebugPrint("FX " .. config.name_part .. " (indeks " .. fx_index .. "): GetPreset retval=" .. tostring(retval) .. ", preset='" .. tostring(current_preset) .. "'")
    
    local next_index = GetNextPresetIndex(current_preset or "", config.presets)
    next_presets[i] = config.presets[next_index]
    -- DebugPrint("Następny preset dla " .. config.name_part .. ": '" .. next_presets[i] .. "'")
  else
    next_presets[i] = nil
  end
end

-- Ustaw następne presety
local set_count = 0
for i, config in ipairs(fx_configs) do
  local fx_index = fx_indices[i]
  local next_preset = next_presets[i]
  if fx_index ~= -1 and next_preset then
    local set_retval = reaper.TrackFX_SetPreset(track, fx_index, next_preset)
    -- DebugPrint("Ustawiono '" .. next_preset .. "' na FX " .. config.name_part .. ", retval: " .. tostring(set_retval))
    set_count = set_count + 1
  end
end

-- DebugPrint("Ustawiono presety na " .. set_count .. " FX")

reaper.Undo_EndBlock("Zsynchronizowane przełączenie presetów FX", -1)
-- DebugPrint("--- Koniec skryptu ---")
