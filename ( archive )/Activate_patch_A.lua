-- ReaScript: Activate container with dynamic names like "(A) Something"
-- Author: Raven Trophy
-- Description: Enables one container and disables the rest on a specific track, based on formatted names like (1), (A), etc.

local TARGET_NAME = "A"  -- <- <- <- ZMIEŃ NA: "1", "2", ..., "D"

-- Lista dozwolonych identyfikatorów
local valid_containers = {
    ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true,
    ["A"] = true, ["B"] = true, ["C"] = true, ["D"] = true
}

-- === [1] ENTROPY MACHINE – kontenery ===
local entropy_track = nil
local track_count = reaper.CountTracks(0)
for i = 0, track_count - 1 do
    local t = reaper.GetTrack(0, i)
    local _, name = reaper.GetSetMediaTrackInfo_String(t, "P_NAME", "", false)
    if name == "ENTROPY MACHINE" then
        entropy_track = t
        break
    end
end

if not entropy_track then
    reaper.ShowMessageBox("Nie znaleziono tracka 'ENTROPY MACHINE'", "Błąd", 0)
    return
end

-- Aktywuj tylko FX z pasującym prefixem (np. (4))
local fx_count = reaper.TrackFX_GetCount(entropy_track)
for i = 0, fx_count - 1 do
    local _, fx_name = reaper.TrackFX_GetFXName(entropy_track, i, "")
    local container_id = fx_name:match("^%((%w)%)")
    if container_id and valid_containers[container_id] then
        local enable = (container_id == TARGET_NAME)
        reaper.TrackFX_SetEnabled(entropy_track, i, enable)
    end
end

-- === [2] SYNTH – zarządzanie Serum ===
local synth_track = nil
for i = 0, track_count - 1 do
    local t = reaper.GetTrack(0, i)
    local _, name = reaper.GetSetMediaTrackInfo_String(t, "P_NAME", "", false)
    if name == "SYNTH" then
        synth_track = t
        break
    end
end

if not synth_track then
    reaper.ShowMessageBox("Nie znaleziono tracka 'SYNTH'", "Błąd", 0)
    return
end

-- Włącz Serum tylko jeśli preset == "4", inaczej wyłącz
local serum_fx_count = reaper.TrackFX_GetCount(synth_track)
for i = 0, serum_fx_count - 1 do
    local _, fx_name = reaper.TrackFX_GetFXName(synth_track, i, "")
    if fx_name:find("SYNTH") then
        local enable_serum = (TARGET_NAME == "4")
        reaper.TrackFX_SetEnabled(synth_track, i, enable_serum)
    end
end

