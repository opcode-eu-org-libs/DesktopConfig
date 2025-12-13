#!/usr/bin/python3

# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

# simple script to open gltf files with blender

import sys, os

if sys.argv[0] == "blender":
	import bpy
	
	if sys.argv[-2] != "--":
		print("Usage: GLTF_FILE_PATH")
		exit(0)
	
	bpy.ops.import_scene.gltf( filepath = sys.argv[-1] )

else:
	os.system("blender -P " + sys.argv[0] + " -- " + sys.argv[1])
