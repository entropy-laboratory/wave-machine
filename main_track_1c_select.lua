-- Skonfiguruj prefix, który aktywujesz (np. "1", "A", "B", itd.)
local TARGET_NAME = "1"

-- Dozwolone prefixy/ścieżki, które będą mute-owane lub aktywowane
local valid_prefixes = {
    ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true,
    ["A"] = true, ["B"] = true, ["C"] = true, ["D"] = true,
    ["SYNTH"] = true
}

-- FX-y do aktywacji na głównej ścieżce (np. "1")
local allowed_fx_names = {
    ["MAIN"] = true,
    ["ADDITIONAL"] = true,
    ["VOID"] = true
}

-- Preset do załadowania w FX "MAIN"
local main_preset_name = "ACOUSTIC"

-- SYNTH – wtyczki i presety
local synth_fx_presets = {
    ["SYNTH"] = "SYNTH PRESET",
    ["VOCO"] = "CLEAN"
}

-- === FUNKCJE ===

-- Znajdź FX po nazwie
function FindFXByName(track, name_part)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    if retval and fx_name:match(name_part) then
      return i
    end
  end
  return -1
end

-- Włącz tylko FX-y z listy allowed_fx_names
function EnableOnlyAllowedFX(track, allowed_fx_table)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    local base_name = fx_name:match("([^%/]+)$") or fx_name
    local should_enable = allowed_fx_table[base_name] or false
    reaper.TrackFX_SetEnabled(track, i, should_enable)
  end
end

-- Wycisz i wyłącz FX
function DisableAllFX(track)
  reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    reaper.TrackFX_SetEnabled(track, i, false)
  end
end

-- START
reaper.Undo_BeginBlock()

local track_count = reaper.CountTracks(0)

for i = 0, track_count - 1 do
  local track = reaper.GetTrack(0, i)
  local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
  local prefix = name:match("^(%w+)") or name

  local is_valid = valid_prefixes[prefix]
  local is_target = (prefix == TARGET_NAME)
  local is_synth = (name == "SYNTH")

  if is_valid then

    -- Track o prefixie TARGET_NAME (np. "1")
    if is_target then
      reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)
      EnableOnlyAllowedFX(track, allowed_fx_names)

      local fx_index = FindFXByName(track, "MAIN")
      if fx_index ~= -1 then
        reaper.TrackFX_SetPreset(track, fx_index, main_preset_name)
        -- reaper.TrackFX_Show(track, fx_index, 3)
      end

    -- SYNTH: tylko aktywny jeśli TARGET_NAME == "1"
    elseif is_synth then
      local activate_synth = (TARGET_NAME == "1")  -- Zmień logikę tu, jeśli SYNTH ma działać też przy innych targetach

      reaper.SetMediaTrackInfo_Value(track, "B_MUTE", activate_synth and 0 or 1)

      for i_fx = 0, reaper.TrackFX_GetCount(track) - 1 do
        local retval, fx_name = reaper.TrackFX_GetFXName(track, i_fx, "")
        local base_name = fx_name:match("([^%/]+)$") or fx_name
        local should_enable = activate_synth and synth_fx_presets[base_name] ~= nil

        reaper.TrackFX_SetEnabled(track, i_fx, should_enable)

        if should_enable then
          reaper.TrackFX_SetPreset(track, i_fx, synth_fx_presets[base_name])
        end
      end

    -- Pozostałe ścieżki – wycisz i wyłącz FX-y
    else
      DisableAllFX(track)
    end
  end
end

reaper.Undo_EndBlock("Smart activate " .. TARGET_NAME .. " + SYNTH logic", -1)
