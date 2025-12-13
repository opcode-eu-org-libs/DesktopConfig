# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

bl_info = {
    "name": "Load startup settings into current scene",
    "blender": (2, 80, 0),
    "category": "File",
}

import bpy

class LoadStartupSettings(bpy.types.Operator):
    bl_idname = "file.loaddefaultsettings"
    bl_label = "Load startup settings into current scene"

    def execute(self, context):
        filepath = bpy.utils.resource_path('USER') + '/config/startup.blend'
        
        # prepare to import
        
        for tmp in bpy.data.screens:
            tmp.name = 'to_remove.old'
        
        for tmp in bpy.data.workspaces:
            tmp.name = 'to_remove.old'
            if tmp != bpy.context.workspace:
                bpy.data.batch_remove(ids=(tmp,))
            else:
                tmp.name = 'to_remove'
        
        # import
        
        with bpy.data.libraries.load(filepath) as (data_from, data_to):
            data_to.workspaces = data_from.workspaces
            data_to.scenes = [data_from.scenes[0]]
        
        # copy scene stuff (units, tools settings)
        
        for prop in data_to.scenes[0].unit_settings.bl_rna.properties:
            try:
                setattr(
                    bpy.context.scene.unit_settings, prop.identifier,
                    getattr(data_to.scenes[0].unit_settings, prop.identifier)
                )
            except:
                print("can't import:", prop.identifier)
        
        for prop in data_to.scenes[0].tool_settings.bl_rna.properties:
            try:
                setattr(
                    bpy.context.scene.tool_settings, prop.identifier,
                    getattr(data_to.scenes[0].tool_settings, prop.identifier)
                )
            except:
                print("can't import:", prop.identifier)
        
        # clear after import
        
        bpy.data.batch_remove(ids=(data_to.scenes[0],))
        # bpy.ops.workspace.delete()  # blender 3.4 crash on this .. so remove workspace (and cleanup) manually
        # bpy.ops.outliner.orphans_purge(do_recursive=True)
        
        return {'FINISHED'}


def menu_func(self, context):
    self.layout.operator(LoadStartupSettings.bl_idname)

def register():
    bpy.utils.register_class(LoadStartupSettings)
    bpy.types.TOPBAR_MT_file_defaults.append(menu_func)

def unregister():
    bpy.utils.unregister_class(LoadStartupSettings)
