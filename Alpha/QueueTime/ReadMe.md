# ⏱️ Queue Time Tracker [BETA]

Addon para WoW Retail que muestra tu tiempo en cola.

---

## ¿Qué hace?

Ventana movible que muestra:
- Tiempo que llevas en cola
- Tiempo promedio estimado (cuando disponible)

Compatible con:
- Dungeon Finder / LFR
- Battlegrounds
- LFG List (Mythic+, raids custom)

---

## Uso

- **Arrastra con click izquierdo** para mover
- Muestra `Not in queue` cuando no estás en cola

---



## 📝 Notas de desarrollo

### APIs usadas:
- `GetLFGQueueStats(LE_LFG_CATEGORY_LFD)` - Dungeon Finder/LFR
- `C_LFGList.GetActiveEntryInfo()` - LFG List (Mythic+)
- Eventos: `LFG_QUEUE_STATUS_UPDATE`, `LFG_LIST_ACTIVE_ENTRY_UPDATE`

### Limitaciones actuales:
- No hay API directa para obtener tiempo de entrada en LFG List
- `avgWait` de `GetLFGQueueStats()` puede devolver `nil`
- El throttle está hardcodeado a 1 segundo

---

## Licencia

MIT - Úsalo/modifícalo libremente