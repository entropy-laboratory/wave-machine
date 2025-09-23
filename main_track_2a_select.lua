-- Skonfiguruj prefix, który aktywujesz (np. "1", "2", "A", itd.)
local TARGET_NAME = "2"

-- Dozwolone prefixy lub nazwane ścieżki (mutowane jeśli nieaktywny)
local valid_prefixes = {
    ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true,
    ["A"] = true, ["B"] = true, ["C"] = true, ["D"] = true,
    ["SYNTH"] = true
}

-- FX-y do aktywacji na głównej ścieżce (prefix "1")
local allowed_fx_names = {
    ["MAIN"] = true,
    ["OCT"] = true,
    ["CHORUS"] = true
}

-- Preset do załadowania dla FX "MAIN"
local main_preset_name = "PRIMARY"

-- FX-y do wyłączenia na ścieżce SYNTH??
local fx_to_disable_on_synth = {
    ["SYNTH"] = true,
    ["VOCO"] = true
}

-- === FUNKCJE ===

-- Znajdź FX po nazwie częściowej
function FindFXByName(track, name_part)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    if retval and fx_name:match(name_part) then
      return i
    end
  end
  return -1
end

-- Włącz tylko FX-y z listy
function EnableOnlyAllowedFX(track, allowed_fx_table)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    local base_name = fx_name:match("([^%/]+)$") or fx_name
    local should_enable = allowed_fx_table[base_name] or false
    reaper.TrackFX_SetEnabled(track, i, should_enable)
  end
end

-- Wyciszenie i wyłączenie wszystkich FX-ów
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
    if is_target then
      -- Aktywujemy wybrany target
      reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)
      EnableOnlyAllowedFX(track, allowed_fx_names)

      local fx_index = FindFXByName(track, "MAIN")
      if fx_index ~= -1 then
        reaper.TrackFX_SetPreset(track, fx_index, main_preset_name)
        -- reaper.TrackFX_Show(track, fx_index, 3)
      end

      elseif is_synth then
        -- SYNTH: aktywacja, odmute, aktywacja FX i preset
        reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)

        for i_fx = 0, reaper.TrackFX_GetCount(track) - 1 do
          local retval, fx_name = reaper.TrackFX_GetFXName(track, i_fx, "")
          local base_name = fx_name:match("([^%/]+)$") or fx_name
          if fx_to_disable_on_synth[base_name] then
            reaper.TrackFX_SetEnabled(track, i_fx, false)
          end
        end

        -- Znajdź FX "SYNTH" i ustaw preset "RHYTM SYNTH"
        local synth_fx_index = FindFXByName(track, "SYNTH")
        if synth_fx_index ~= -1 then
          reaper.TrackFX_SetEnabled(track, synth_fx_index, true)
          reaper.TrackFX_SetPreset(track, synth_fx_index, "RHYTM SYNTH")
        end


    else
      -- Pozostałe: mute + wyłączenie FX-ów
      DisableAllFX(track)
    end
  end
end

reaper.Undo_EndBlock("Activate " .. TARGET_NAME .. ", disable SYNTH + others", -1)
