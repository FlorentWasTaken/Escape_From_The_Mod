# Escape From The Mod

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#-project-description">Project description</a>
      <ul>
        <li><a href="#-built-with">Built with</a></li>
      </ul>
    </li>
    <li><a href="#-how-to-build">How to build</a></li>
    <li><a href="#-how-to-contribute">How to contribute</a></li>
  </ol>
</details>

# 📰 Project description

This repository is still a work in progress. The goal is to create an 'Escape From Tarkov'-like game mode in Garry's Mod.
I'm working on this project in my free time, which I don't have much of.

- **Escape From Tarkov** is a hardcore survival first-person shooter that I really enjoy.
- **Garry's Mod** is a sandbox game where you can code your own scripts.

## 📚 Built with

- ![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
- ![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

# ⚙️ How to configure

If you want to configure the gamemode, please refer to the `shared.lua` file, which is located in `gamemodes/escape_from_the_mod/gamemode`.
I will create a better configuration system soon

# 🔨 How to build

**Follow these steps if you don't have a gmod server :**

- Download steamCMD from this page : https://developer.valvesoftware.com/wiki/SteamCMD
- Put steamCMD into a folder (our server will be here)
- Run steamCMD, it will download files
- Run these commands : `login anonymous` and `app_update 4020 validate`
- Create a **start.bat** file (Windows) in your folder at `steamapps/common/GarrysModDS`

Put this into your **start.bat** file :

```
@echo off
cls
echo Protecting srcds from crashes...
echo If you want to close srcds and this script, close the srcds window and type Y depending on your language followed by Enter.
title srcds.com Watchdog
:srcds
echo (%time%) srcds started.
start /wait srcds.exe -console -game garrysmod +map gm_flatgrass +maxplayers 8 +gamemode escape_from_the_mod +host_workshop_collection "3062861647" +r_hunkalloclightmaps 0
echo (%time%) WARNING: srcds closed or crashed, restarting.
goto srcds
```

You can configure this file as you wish.

**Follow these steps if you have a gmod server :**

- Download or clone the repository in the **GarrysModDS** folder
- Extract every files from the folder named **Escape_From_The_Mod** into **GarrysModDS**
- Set the gamemode to **escape_from_the_mod** in your **start.bat** file (see previous steps)

# 📡 How to contribute

I you want to contribute to the project, please open an issue, I'll be happy to discuss with you !
