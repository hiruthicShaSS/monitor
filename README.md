# Monitor

Looks for specified running applications and stores the usage of app over time. 
Python script [main.py](/main.py) will start recording.


## System Info
- Windows
- Python3 on Anaconda

### Install dependencies:
```bash
pip install -r requirements.txt
```

### Command line arguments:
- For not uploading data to Google drive (Mobile app cannot be used).
    ```bash
    python main.py -no-up
    ```
- Just visualize existing data
    ```bash
    python main.py -vis
    ```

### Configuration:
- monitorApps: *Process names of each application to monitor*
- appNames: *Application name of each processes*
- appColors: *Color for each application name(for plotting)*
- appIcons: *Link of icon's of each application(for mobiles)*
- refreshTime: *Interval to scan for application*
- uploadPerEpoch: *Number of times data to gather before uploading to Google Drive*
<br>

## Mobile app (Android)
- Upload the data once to the Google Drive.
- Get the sharing link and [convert](https://sites.google.com/site/gdocs2direct/home) it to direct download link.
- Replace the link on the final variable '*URL*' in [main.dart](/monitor/lib/main.dart) in line [41](https://github.com/hiruthic2002/monitor/blob/6b6b2ff51d88fea1c0bf35caab936cfc3b839f44/monitor/lib/main.dart#L41)
- Change the look of the app if you want
- Compile:
    ```bash
    flutter build apk --split-debug-info --obfuscate --release
    ```
    or
    ```bash
    flutter build apk --release
    ```

*Don't mind the commit history, had some issues working with version control*
