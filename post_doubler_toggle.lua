-- ReaScript: Toggle FX "DOUBLER" on track 'POST'
-- Author: Raven Trophy
-- Description: Toggles an FX called "DOUBLER" on a specific track

local TARGET_FX_NAME = "DOUBLER"  -- <- dokładna nazwa FX (case sensitive!)

-- Szukamy tracka o nazwie 'POST'
local track = nil
local track_count = reaper.CountTracks(0)
for i = 0, track_count - 1 do
    local t = reaper.GetTrack(0, i)
    local _, name = reaper.GetSetMediaTrackInfo_String(t, "P_NAME", "", false)
    if name == "POST" then
        track = t
        break
    end
end

if not track then
    reaper.ShowMessageBox("Nie znaleziono tracka o nazwie 'POST'", "Błąd", 0)
    return
end

-- Przeglądamy wszystkie FX na torze i szukamy tego o nazwie "DOUBLER"
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
