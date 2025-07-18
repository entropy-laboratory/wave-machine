-- ReaScript: Activate container with dynamic names like "(A) Something"
-- Author: Raven Trophy
-- Description: Enables one container and disables the rest on a specific track, based on formatted names like (1), (A), etc.

local TARGET_NAME = "3"  -- <- <- <- ZMIEŃ NA: "1", "2", ..., "D"

-- Lista dozwolonych identyfikatorów
local valid_containers = {
    ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true,
    ["A"] = true, ["B"] = true, ["C"] = true, ["D"] = true
}

-- Szukamy tracka o nazwie 'ENTROPY MACHINE'
local track = nil
local track_count = reaper.CountTracks(0)
for i = 0, track_count - 1 do
    local t = reaper.GetTrack(0, i)
    local _, name = reaper.GetSetMediaTrackInfo_String(t, "P_NAME", "", false)
    if name == "ENTROPY MACHINE" then
        track = t
        break
    end
end

if not track then
    reaper.ShowMessageBox("Nie znaleziono tracka o nazwie 'ENTROPY MACHINE'", "Błąd", 0)
    return
end

-- Przeglądamy wszystkie FX na torze
local fx_count = reaper.TrackFX_GetCount(track)
for i = 0, fx_count - 1 do
    local _, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    
    -- Szukamy wzorca typu: (A), (1), itd. na początku nazwy FX
    local container_id = fx_name:match("^%((%w)%)")
    
    if container_id and valid_containers[container_id] then
        local enable = (container_id == TARGET_NAME)
        reaper.TrackFX_SetEnabled(track, i, enable)
    end
end
