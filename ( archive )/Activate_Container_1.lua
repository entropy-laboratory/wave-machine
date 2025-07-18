-- ReaScript: Activate container "TARGET_NAME" on track 'ENTROPY MACHINE', bypass others
-- Author: Raven Trophy
-- Description: Enables one container and disables the rest on a specific track

local TARGET_NAME = "1" -- <- <- <- ZMIEŃ NA: "1", "2", ..., "D" dla konkretnego przycisku

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

-- Lista akceptowanych nazw FX (kontenerów)
local valid_containers = {
    ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true,
    ["A"] = true, ["B"] = true, ["C"] = true, ["D"] = true
}

-- Przeglądamy wszystkie FX na torze
local fx_count = reaper.TrackFX_GetCount(track)
for i = 0, fx_count - 1 do
    local _, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    -- Zakładamy, że nazwa FX to np. "A", "1", itd.
    fx_name = fx_name:match("^(%w+)$")  -- tylko czysta nazwa bez dodatkowych znaków
    if fx_name and valid_containers[fx_name] then
        local enable = (fx_name == TARGET_NAME)
        reaper.TrackFX_SetEnabled(track, i, enable)
    end
end

