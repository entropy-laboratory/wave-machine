-- ReaScript: Toggle FX "OCTAVER" on track 'ENTROPY MACHINE'
-- Author: Raven Trophy
-- Description: Toggles an FX called "OCTAVER" on a specific track

local TARGET_FX_NAME = "OCTAVER"  -- <- dokładna nazwa FX (case sensitive!)

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

-- Przeglądamy wszystkie FX na torze i szukamy tego o nazwie "OCTAVER"
local fx_count = reaper.TrackFX_GetCount(track)
for i = 0, fx_count - 1 do
    local _, fx_name = reaper.TrackFX_GetFXName(track, i, "")
    
    -- Szukamy dokładnego dopasowania nazwy FX
    if fx_name:match("^" .. TARGET_FX_NAME .. "$") then
        local enabled = reaper.TrackFX_GetEnabled(track, i)
        reaper.TrackFX_SetEnabled(track, i, not enabled)  -- toggle: jeśli włączony → wyłącz, jeśli wyłączony → włącz
        break
    end
end
