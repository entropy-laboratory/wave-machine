-- ReaScript: Load Archetype Plini preset from FXChain file
-- Wymaga zapisania FXChain wcześniej!

local TARGET_TRACK_NAME = "ENTROPY MACHINE"
local FXCHAIN_PATH = reaper.GetResourcePath() .. "/FXChains/Plini_OldFashioned.RfxChain"

-- Znajdujemy track
local track = nil
local track_count = reaper.CountTracks(0)
for i = 0, track_count - 1 do
    local t = reaper.GetTrack(0, i)
    local _, name = reaper.GetSetMediaTrackInfo_String(t, "P_NAME", "", false)
    if name == TARGET_TRACK_NAME then
        track = t
        break
    end
end

if not track then
    reaper.ShowMessageBox("Track '" .. TARGET_TRACK_NAME .. "' not found", "Error", 0)
    return
end

-- Usuwamy istniejący FX slot (opcjonalnie)
-- reaper.TrackFX_Delete(track, 0)  -- <- jeśli chcesz czyścić FX slot

-- Wczytujemy preset jako FXChain
reaper.Main_openProject(FXCHAIN_PATH)  -- To nie działa! NIE UŻYWAJ!
reaper.TrackFX_AddByName(track, FXCHAIN_PATH, false, -1000)

