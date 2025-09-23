-- Lista ścieżek i mapowanie zamiany
local swapMap = {
    C = "B",  -- C -> B
    B = "C",  -- B -> C
    D = "B"   -- D -> B
}

-- Funkcja: sprawdza, czy nazwa ścieżki zaczyna się od litery
local function startsWithLetter(name, letter)
    return string.sub(name, 1, 1) == letter
end

-- Funkcja: znajdź pierwszą odmutowaną ścieżkę z podanych liter
local function findUnmutedTrackLetter(letters)
    for i = 0, reaper.CountTracks(0)-1 do
        local track = reaper.GetTrack(0, i)
        local _, name = reaper.GetTrackName(track, "")
        local muteState = reaper.GetMediaTrackInfo_Value(track, "B_MUTE")
        if muteState == 0 then -- 0 = odmutowana
            for _, letter in ipairs(letters) do
                if startsWithLetter(name, letter) then
                    return letter, track
                end
            end
        end
    end
    return nil, nil
end

-- Funkcja: znajdź ścieżkę po pierwszej literze nazwy
local function findTrackByLetter(letter)
    for i = 0, reaper.CountTracks(0)-1 do
        local track = reaper.GetTrack(0, i)
        local _, name = reaper.GetTrackName(track, "")
        if startsWithLetter(name, letter) then
            return track
        end
    end
    return nil
end

-- Główna logika
reaper.Undo_BeginBlock()

local lettersToCheck = {"B", "C", "D"}
local foundLetter, foundTrack = findUnmutedTrackLetter(lettersToCheck)

if foundLetter and swapMap[foundLetter] then
    -- Mutuj aktualną
    reaper.SetMediaTrackInfo_Value(foundTrack, "B_MUTE", 1)
    -- Odmutuj docelową
    local targetTrack = findTrackByLetter(swapMap[foundLetter])
    if targetTrack then
        reaper.SetMediaTrackInfo_Value(targetTrack, "B_MUTE", 0)
    end
end

reaper.Undo_EndBlock("Przełączanie B/C/D", -1)
