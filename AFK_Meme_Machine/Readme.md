## 📑 Table of Contents
- [🌍 Supported Languages / Idiomas Soportados](#-supported-languages--idiomas-soportados)
- [✍️ English](#️-english)
  - [Description](#description)
  - [How to Add or Remove Messages](#how-to-add-or-remove-messages)
- [🇪🇸 Español](#-español)
  - [Descripción](#descripción)
  - [Cómo Añadir o Quitar Mensajes](#cómo-añadir-o-quitar-mensajes)

---

## 🌍 Supported Languages / Idiomas Soportados
- 🇺🇸 English (enUS)
- 🇲🇽 Español México (esMX)
- 🇪🇸 Español España (esES)
- 🇩🇪 Deutsch / Alemán (deDE)
- 🇫🇷 Français / Francés (frFR)
- 🇮🇹 Italiano (itIT)
- 🇧🇷 Português Brasil (ptBR)
- 🇷🇺 Русский / Ruso (ruRU)

---

## ✍️ English

**To install:**  
Go to [CurseForge](https://www.curseforge.com/wow/addons/afk-meme-machine) and download the addon.

### Description
The **AFK Fun addon** customizes your AFK status in WoW by showing fun, customizable messages with random emotes.

### How to Add or Remove Messages
1. Locate the file `AFKFunSimple_Locales.lua` in the addon folder.
2. Open it with a text editor (Notepad++, VS Code, etc.).
3. Messages are organized in language-specific tables, e.g.:
   - `AFKFunSimple_Locales["enUS"]` (English)
   - `AFKFunSimple_Locales["esMX"]` (Spanish Mexico)
   - `AFKFunSimple_Locales["esES"]` (Spanish Spain)
   - `AFKFunSimple_Locales["deDE"]` (German)
   - `AFKFunSimple_Locales["frFR"]` (French)
   - `AFKFunSimple_Locales["itIT"]` (Italian)
   - `AFKFunSimple_Locales["ptBR"]` (Portuguese Brazil)
   - `AFKFunSimple_Locales["ruRU"]` (Russian)

4. To **add messages**, insert new lines inside the desired language table:
   ```lua
   "%s your funny message here.",
   ```
5. To **remove messages**, delete or comment out the lines.

6. Save and reload WoW with `/reload` or restart the game.

💡 Want more fun now? Just edit the file and add as many lines as you want. Simple and fast!

---

## 🇪🇸 Español

**Para instalar:**  
Accede a [CurseForge](https://www.curseforge.com/wow/addons/afk-meme-machine) y descarga el addon.

### Descripción
El addon **AFK Fun** personaliza tu estado AFK en WoW mostrando mensajes divertidos y personalizables con emotes aleatorios.

### Cómo Añadir o Quitar Mensajes
1. Localiza el archivo `AFKFunSimple_Locales.lua` en la carpeta del addon.
2. Ábrelo con un editor de texto (Notepad++, VS Code, etc.).
3. Los mensajes están organizados en tablas separadas por idioma, por ejemplo:
   - `AFKFunSimple_Locales["enUS"]` (Inglés)
   - `AFKFunSimple_Locales["esMX"]` (Español México)
   - `AFKFunSimple_Locales["esES"]` (Español España)
   - `AFKFunSimple_Locales["deDE"]` (Alemán)
   - `AFKFunSimple_Locales["frFR"]` (Francés)
   - `AFKFunSimple_Locales["itIT"]` (Italiano)
   - `AFKFunSimple_Locales["ptBR"]` (Portugués Brasil)
   - `AFKFunSimple_Locales["ruRU"]` (Ruso)

4. Para **añadir mensajes**, inserta nuevas líneas dentro de la tabla del idioma:
   ```lua
   "%s tu mensaje divertido aquí.",
   ```
5. Para **eliminar mensajes**, borra o comenta las líneas que no quieras.

6. Guarda y recarga WoW con `/reload` o reinicia el juego.

💡 ¿Quieres añadir más frases ahora? Solo edita el archivo y pon todas las que quieras. ¡Así de sencillo!