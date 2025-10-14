import os
import sys
import json
import requests
from zipfile import ZipFile

API_KEY = os.getenv("CURSEFORGE_API_KEY")
if not API_KEY:
    raise Exception("No se encontró CURSEFORGE_API_KEY en los secrets")

# Carpeta del addon
addon_dir = sys.argv[1]

# Leer curseforge.json
json_path = os.path.join(addon_dir, "curseforge.json")
if not os.path.exists(json_path):
    raise Exception(f"No se encontró curseforge.json en {addon_dir}")

with open(json_path) as f:
    data = json.load(f)

project_id = data["curse-project-id"]
release_type = data["release-type"]
game_versions = data.get("gameVersions", ["12.0.0"])

# Crear zip del addon
zip_name = f"{addon_dir}.zip"
with ZipFile(zip_name, 'w') as zipf:
    for root, _, files in os.walk(addon_dir):
        for file in files:
            zipf.write(os.path.join(root, file),
                       os.path.relpath(os.path.join(root, file), addon_dir))

# Subida a CurseForge
url = f"https://wow.curseforge.com/api/projects/{project_id}/upload-file"
headers = {"x-api-token": API_KEY}
metadata = {
    "changelog": "Automated upload via GitHub Actions",
    "displayName": os.path.basename(addon_dir),
    "gameVersions": game_versions,
    "releaseType": release_type
}

with open(zip_name, "rb") as f:
    files = {"file": f}
    resp = requests.post(url, headers=headers, data={"metadata": json.dumps(metadata)}, files=files)

if resp.status_code == 200:
    print(f"✅ Uploaded {addon_dir} as {release_type}")
else:
    print(f"❌ Failed {addon_dir}: {resp.status_code} - {resp.text}")
