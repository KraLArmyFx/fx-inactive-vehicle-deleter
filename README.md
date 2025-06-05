# fx-inactive-vehicle-deleter

A lightweight and fully automatic FiveM script that deletes **unoccupied and inactive vehicles** to keep your server clean and optimized.

Developed by **KraLArmyFx**.

---

## 🚗 What It Does

This script scans all vehicles on the server and removes those that:

- Have **no driver**
- Are **not player-owned** (optional SQL check)
- Have **not moved** for a configurable period of time
- Are **not whitelisted** (e.g., police, ambulance, firetruck)

---

## ✅ Features

- ✅ Fully automatic cleanup (no manual command required)
- ✅ Works independently of framework (standalone)
- ✅ Supports player vehicle whitelist via SQL table
- ✅ Configurable idle timeout, scan interval, model exceptions
- ✅ Optimized and low resource usage

---

## ⚙️ Configuration

Edit everything via `config.lua`:

```lua
Config.UseSQLVehicleTable = true
Config.SQLVehicleTable = "player_vehicles"

Config.InactivityCheckInterval = 60000            -- How often to scan (ms)
Config.InactiveTimeBeforeDelete = 300000           -- Time before deletion (ms)

Config.DebugPrint = false                          -- Enable debug logs

Config.WhitelistModels = {
    [`police`] = true,
    [`ambulance`] = true,
    [`firetruk`] = true
}
