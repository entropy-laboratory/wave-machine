switcher_track_Aa_select


-- === GENERAL CONFIGURATION ===
local TARGET_NAME = "A"

-- Allowed prefixes (to mute others)
local valid_prefixes = {
    ["A"] = true, ["B"] = true
}

-- FX-s to activate on main track
local allowed_fx_names = {
    ["MAIN"] = true,
    ["ADDITIONAL"] = true
  }

-- Preset to load for FX "MAIN"
local main_preset_name = "SUNRISE CLEAN"

-- === FUNCTIONS ===
-- Find FX by part of its name
function FindFXByName(track, name_part)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    if retval and fx_name:match(name_part) then
      return i
    end
  end
  return -1
end

-- Toggle only allowed FX
function EnableOnlyAllowedFX(track, allowed_fx_table)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    local retval, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    local base_name = fx_name:match("([^%/]+)$") or fx_name
    local should_enable = allowed_fx_table[base_name] or false
    reaper.TrackFX_SetEnabled(track, i, should_enable)
  end
end

-- Mute all or disable all FX
function DisableAllFX(track)
  reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1)
  for i = 0, reaper.TrackFX_GetCount(track) - 1 do
    reaper.TrackFX_SetEnabled(track, i, false)
  end
end

-- === MAIN SCRIPT ===
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
      -- Activate the target
      reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)
      EnableOnlyAllowedFX(track, allowed_fx_names)

      local fx_index = FindFXByName(track, "MAIN")
      if fx_index ~= -1 then
        reaper.TrackFX_SetPreset(track, fx_index, main_preset_name)
        -- reaper.TrackFX_Show(track, fx_index, 3)
      end


    else
      -- Mute and disable all FX for other tracks
      DisableAllFX(track)
    end
  end
end

reaper.Undo_EndBlock("Activate " .. TARGET_NAME .. ", disable SYNTH + others", -1)