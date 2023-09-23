installer_path = "/tmp/VisualStudioSetup.exe"

from xvfbwrapper import Xvfb
import subprocess, os, threading, time, json, sys
if not "PATH" in os.environ:
    os.environ["PATH"] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

vdisplay = Xvfb()
vdisplay.start()

def proc():
    os.environ["LD_LIBRARY_PATH"] = "/browser/palemoon"
    os.system("/bin/sh -c '/browser/palemoon/palemoon --profile /browser_profile/MSVS https://visualstudio.microsoft.com/downloads/'")
threading.Thread(target=proc).start()
print("Thread start")

def get_all_windows():
    xdo_windows_cmd = subprocess.Popen(["xdotool", "search", "--name", ".*"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    xdo_window_ids, error = xdo_windows_cmd.communicate()
    print(xdo_window_ids)
    window_ids = xdo_window_ids.decode().split("\n")
    if len(error) > 0:
        raise Exception(error)
    if len(window_ids) == 0:
        raise Exception("No windows spawned")
    return window_ids

def get_window_name(window_id):
    xdo_window_name_cmd = subprocess.Popen(["xdotool", "getwindowname", window_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    xdo_window_name, error = xdo_window_name_cmd.communicate()
    if len(error) > 0:
        return None
#        raise Exception(error)
    return xdo_window_name.decode().strip()

def activate_window(window_id):
    subprocess.Popen(["xdotool", "activate", window_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def tab_key(window_id):
    subprocess.Popen(["xdotool", "keydown", "--window", window_id, "Tab"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    time.sleep(1)
    subprocess.Popen(["xdotool", "keyup", "--window", window_id, "Tab"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
def enter_key(window_id):
    subprocess.Popen(["xdotool", "keydown", "--window", window_id, "Return"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    time.sleep(1)
    subprocess.Popen(["xdotool", "keyup", "--window", window_id, "Return"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def close_window(window_id):
    a = subprocess.Popen(["xdotool", "windowclose", window_id], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    print(a.communicate())

attempts = 0
shown_download = False
while attempts != 30:
    if shown_download:
        break_all = False
        while True:
            print("Searching for installer")
            if os.path.exists(installer_path):
                print("Installer found!")
                break_all = True
                break
            time.sleep(5)
        if break_all:
            break
    print("Waiting for browser - attempt %d" % attempts)
    time.sleep(attempts)
    for window_id in get_all_windows():
        window_id = window_id.strip()
        if window_id.isdigit():
     #       print("Window found - " + window_id)
            window_name = get_window_name(window_id)
            if not window_name == None: #window_name != "":
                print("ID=%d, Name=%s" % (int(window_id), window_name))
            else:
                continue
            if "Opening VisualStudioSetup.exe" == window_name:
                print(json.dumps(window_name))
                print("Activating")
                time.sleep(2)
                activate_window(window_id)
                tab_key(window_id)
                enter_key(window_id)
                print("Keys pressed")
                shown_download = True
                break
            elif "Safe Mode" in window_name or "Default" in window_name:
                print("Closing " + window_name)
                close_window(window_id)
                break
            else:
                pass

    attempts = attempts + 1

vdisplay.stop()
