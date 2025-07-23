-- ReaScript: Set "CAB SIM" envelopes to 0 on tracks starting with A or D
-- Author: Raven Trophy

local TARGET_VALUE = 0.0  -- ustaw na 1.0 jeśli chcesz włączyć, 0.0 = wyłączyć
local ALLOWED_PREFIXES = { A = true, D = true, B = true, C = true }

local track_count = reaper.CountTracks(0)
reaper.Undo_BeginBlock()

for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    local prefix = track_name:sub(1,1)

    if ALLOWED_PREFIXES[prefix] then
        local env_count = reaper.CountTrackEnvelopes(track)

        for j = 0, env_count - 1 do
            local envelope = reaper.GetTrackEnvelope(track, j)
            local _, env_name = reaper.GetEnvelopeName(envelope, "")

            if env_name:lower():find("active cab") then
                local time = reaper.GetCursorPosition()  -- lub 0.0 jeśli chcesz od początku
                reaper.InsertEnvelopePoint(envelope, time, TARGET_VALUE, 0, 0, false, true)
                reaper.Envelope_SortPoints(envelope)
            end
        end
    end
end

reaper.Undo_EndBlock("Set 'Active Cab' envelopes to " .. TARGET_VALUE, -1)