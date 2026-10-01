import bpy
import os
from bpy.app.handlers import persistent

@persistent
def remove_datablock_previews(dummy):
    filepath = os.path.normpath(bpy.data.filepath)
    assets_dir = os.path.normpath('/srv/Projects/BlenderAssets')
    if not filepath.startswith(assets_dir):
        print("clear data block preview")
        bpy.ops.wm.previews_clear()
    else:
        print("inside assets lib - keep data block preview")

def register():
    if remove_datablock_previews not in bpy.app.handlers.save_pre:
        bpy.app.handlers.save_pre.append(remove_datablock_previews)

if __name__ == "__main__":
    register()
