-- ReaScript: Toggle arm + FX for SYNTH track
-- Author: Raven Trophy (modded)
-- Description: Toggles FX and record-arm for a track containing "SYNTH" in its name

local TRACK_KEYWORD = "VOCO"

local track_count = reaper.CountTracks(0)
local track_found = false

reaper.Undo_BeginBlock()

for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    if name:upper():find(TRACK_KEYWORD:upper()) then
        track_found = true

        -- Sprawdź, czy track jest aktualnie armod
        local is_armed = reaper.GetMediaTrackInfo_Value(track, "I_RECARM") == 1
        local new_arm_state = is_armed and 0 or 1  -- Toggle

        -- Zmień record arm
        reaper.SetMediaTrackInfo_Value(track, "I_RECARM", new_arm_state)

        -- Włącz/wyłącz FX
        local fx_count = reaper.TrackFX_GetCount(track)
        for fx = 0, fx_count - 1 do
            reaper.TrackFX_SetEnabled(track, fx, new_arm_state == 1)
        end

        break  -- Zakładamy, że jest tylko jeden taki track
    end
end

if not track_found then
    reaper.ShowMessageBox("Nie znaleziono ścieżki zawierającej 'SYNTH'", "Błąd", 0)
end

reaper.Undo_EndBlock("Toggle arm + FX for SYNTH", -1)
