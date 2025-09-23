import rtmidi
import os
import sys

# Ścieżka do folderu z plikami .bat
base_path = r"C:\AUDIO\!   E N T R O P Y   E N G I N E\_Runnables"

# Mapowanie komunikatów PC na pliki .bat
pc_to_bat = {
    1: "ENTROPY ENGINE --- MAIN.bat",
    2: "ENTROPY ENGINE --- FUSION.bat",
    3: "ENTROPY ENGINE --- PROG.bat"
}

def open_batch_file(filename):
    full_path = os.path.join(base_path, filename)
    if os.path.exists(full_path):
        print(f"Uruchamiam: {full_path}")
        os.startfile(full_path)
    else:
        print(f"Nie znaleziono pliku: {full_path}")
    sys.exit(0)  # Zakończ działanie skryptu

def midi_callback(event, data=None):
    message, _ = event
    # Sprawdzamy, czy to komunikat Program Change (status 0xC0)
    if len(message) >= 2 and message[0] & 0xF0 == 0xC0:
        pc_value = message[1]
        print(f"Odebrano PC: {pc_value}")
        if pc_value in pc_to_bat:
            open_batch_file(pc_to_bat[pc_value])
        else:
            print("Brak przypisania do tego PC.")
            sys.exit(0)

# Inicjalizacja MIDI
midi_in = rtmidi.MidiIn()
ports = midi_in.get_ports()

if not ports:
    print("Brak dostępnych wejść MIDI!")
    sys.exit(1)

# Otwieramy pierwszy dostępny port
midi_in.open_port(0)
midi_in.set_callback(midi_callback)

print("Czekam na komunikat PC (01–03)...")

# Czekamy maksymalnie 60 sekund, żeby nie wisiało w nieskończoność
import time
start_time = time.time()
while time.time() - start_time < 60:
    time.sleep(0.1)

print("Nie odebrano komunikatu — zamykam.")
midi_in.close_port()
