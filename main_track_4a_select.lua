-- == 4 :  PURESYNTH 1 // 2 == --

-- Skrypt: Aktywuj tylko SYNTH z presetem "PURESYNTH 1"

-- Prefixy do wyciszenia
local mute_prefixes = {
    ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true,
    ["A"] = true, ["B"] = true, ["C"] = true, ["D"] = true
}

-- Nazwa preset na SYNTH
local synth_preset_name = "PURESYNTH 1"

-- FX-y do pozostawienia aktywne na ścieżce SYNTH (tylko ten!)
local only_this_fx_active_on_synth = "SYNTH"

-- === FUNKCJE ===

function FindFXByName(track, name_part)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    if retval and fx_name:match(name_part) then
      return i
    end
  end
  return -1
end

function DisableAllFX(track)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    reaper.TrackFX_SetEnabled(track, i, false)
  end
end

-- === START ===
reaper.Undo_BeginBlock()

local track_count = reaper.CountTracks(0)

for i = 0, track_count - 1 do
  local track = reaper.GetTrack(0, i)
  local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
  local prefix = name:match("^(%w+)") or name

  if mute_prefixes[prefix] then
    -- Wycisz i wyłącz FX-y
    reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1)
    DisableAllFX(track)

  elseif name == "SYNTH" then
    -- Aktywuj SYNTH
    reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)

    for fx_index = 0, reaper.TrackFX_GetCount(track) - 1 do
      local _, fx_name = reaper.TrackFX_GetFXName(track, fx_index, "")
      local base_name = fx_name:match("([^%/]+)$") or fx_name
      local is_target_fx = base_name:match(only_this_fx_active_on_synth)

      -- Włącz tylko SYNTH FX
      reaper.TrackFX_SetEnabled(track, fx_index, is_target_fx and true or false)

      -- Jeśli SYNTH FX - ustaw preset
      if is_target_fx then
        reaper.TrackFX_SetPreset(track, fx_index, synth_preset_name)
        -- reaper.TrackFX_Show(track, fx_index, 3) -- opcjonalne pokazanie okna
      end
    end
  end
end

reaper.Undo_EndBlock("Activate SYNTH with preset 'PURESYNTH 1'", -1)