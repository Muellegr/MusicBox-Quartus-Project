**How to Generate 16-bit Unsigned Audio Files in Audacity:**

1. Open up Audacity and the .wav file that you wish to get data from

2. Go to the top navbar and select File>Export Audio (CTRL+SHIFT+E)

3. In the 'Save as type' field select 'Other uncompressed file'

4. In the 'Header' field select 'RAW (header-less)'

5. In the 'Encoding' field select 'Signed 16-bit PCM'

6. Run this .raw file though the 'raw2hex.py' script

7. Run the generated .hex files with the music encoded though the 'MusicBoxROM.py' to get the final Memory Initialization File (.mif)
