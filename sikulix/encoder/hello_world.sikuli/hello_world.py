#popup("Hello World!")
myssh = App("pytty")
if not myssh.isRunning():
    newssh = App.open("putty.exe")
    if not myssh.isRunning():
        popup("Can't start putty")
    else:
        popup("putty started successfully.")
