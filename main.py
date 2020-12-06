import subprocess
import re
import time
import datetime
import pickle
import matplotlib.pyplot as plt
import json
import atexit
import win32api
import argparse
import requests

parser = argparse.ArgumentParser("Some usefull flags")
parser.add_argument("-vis", "--visualize", help="Just visualize", action="store_true")
parser.add_argument("-no-up", "--no-upload", help="Dont upload the data to server", action="store_true")

args = parser.parse_args()

appsToMonitor = None
appNames = None
appColors = None
appIcons = None
timeout = 0
monitor = {}

def plot():
    # Get app name for the corresponding process
    labels = [appNames[key] for key in appNames.keys() if key in monitor.keys()]
    sizes = [size["timeSpentOnWork"]
            for key, size in monitor.items() if key != "lastUpdated"]  # Get all the apps working time
    # Colors denoting each application
    colors = [color for app, color in appColors.items() if app in labels]
    explode = [0.05] * len(labels)

    fig1, ax1 = plt.subplots()

    ax1.pie(sizes, colors=colors, labels=labels,
            autopct="%1.1f%%", startangle=90, explode=explode)

    # draw circle
    centre_circle = plt.Circle((0, 0), 0.70, fc='white')
    fig = plt.gcf()
    fig.gca().add_artist(centre_circle)
    # Equal aspect ratio ensures that pie is drawn as a circle
    ax1.axis('equal')
    plt.tight_layout()
    plt.legend([f"{label}: {size} min's" for label, size in zip(labels, sizes)])
    plt.show()


if args.visualize == True:
    with open("config.json", "r") as file:  # Read the settings from config.json
        jsonImported = json.loads(file.read())
        appsToMonitor = jsonImported["monitorApps"]
        appNames = jsonImported["appNames"]
        appColors = jsonImported["appColors"]
        appIcons = jsonImported["appIcons"]

    with open("tracking.pickle", "rb") as file:
        monitor = pickle.load(file)
        plot()
        
def exit_handler(sig=None):
    print("Writing to file...", end=" ")
    with open("tracking.json", "w+") as file:
        for key in monitor.keys():
            if key == "lastUpdated":
                continue
            monitor[key]["appName"] = appNames[key]
            monitor[key]["appIcon"] = appIcons[appNames[key]]
        json.dump(monitor, file)
    print("Done")
    
    if not args.no_upload or not args.visualize:
        print("Uploading file...", end=" ")
        file = {'file': open("tracking.json", 'rb')}
        data = requests.post("https://toxic-cat.herokuapp.com/upload?pass=sha", files=file)
        if data.status_code == 200:
            print("Done.")
        else:
            print(f"Error: {data.status_code} - {data.reason}")
    return

atexit.register(exit_handler)
win32api.SetConsoleCtrlHandler(exit_handler)

with open("config.json", "r") as file:  # Read the settings from config.json
    jsonImported = json.loads(file.read())
    appsToMonitor = jsonImported["monitorApps"]
    appNames = jsonImported["appNames"]
    appColors = jsonImported["appColors"]
    appIcons = jsonImported["appIcons"]
    timeout = jsonImported["refreshTime"]

with open("tracking.json", "r") as file:
    try: monitor = json.load(file)
    except: pass

monitored = 0
try:
    while True:
        runningApps = re.findall(r"\w{1,}.exe", subprocess.check_output(
            "tasklist").decode())  # Get output for tasklist from cmd
        
        start = time.time()
        for app in runningApps:
            for key, value in appsToMonitor.items():
                if app in value:
                    # print(app, [creationTime.strip(".") for creationTime in re.findall(r"\d{1,}\.", subprocess.check_output(f"wmic process where Name='{app}' get CreationDate").decode())])

                    try:  # Somtimes it causes an error
                        date = str(min([int(creationTime.strip(".")) for creationTime in re.findall(r"\d{1,}\.", subprocess.check_output(
                        f"wmic process where Name='{app}' get CreationDate").decode())]))  # Get only the max time creation among all child processes
                    except ValueError:
                        continue
                    year = int(date[0:4])
                    month = int(date[4:6])
                    day = int(date[7:8])

                    creationTime = datetime.datetime.strptime(
                        f"{date[0:4]}/{date[4:6]}/{date[7:8]} {date[8:10]}-{date[10:12]}-{date[12:-1]}", "%Y/%m/%d %H-%M-%S").strftime("%d-%m-%Y %H:%M:%S")  # Generate clean date and time
                    monitor[app] = {
                        "creationTime": creationTime,
                        # Calculate total time spent and use divmod on timedelta object with 60 to get (min's, sec's)[0] -> Take only the minutes
                        "timeSpentOnWork": divmod((datetime.datetime.now() - datetime.datetime.strptime(creationTime, "%d-%m-%Y %H:%M:%S")).total_seconds(), 60)[0],
                        "category": key
                    }

        monitored += 1
        print(f"[{monitored:<3}] Processes calculated: {time.time() - start}")
        with open("tracking.json", "r") as file:
            try:  # If there is no process before adding the value raises error
                tracking = json.load(file)
                for key, value in tracking.items():
                    if monitor.get(key) == None:
                        monitor[key] = value
                    else:
                        monitor[key] += value
            except:
                pass

        with open("tracking.json", "w+") as file:
            for key in monitor.keys():
                if key == "lastUpdated":
                    continue
                monitor[key]["appName"] = appNames[key]
                monitor[key]["appIcon"] = appIcons[appNames[key]]
                
            monitor["lastUpdated"] = datetime.datetime.now().strftime("%d-%m-%Y %H:%M:%S")
            json.dump(monitor, file)

        time.sleep(timeout)
except KeyboardInterrupt:
    plot()

# print(monitor)
