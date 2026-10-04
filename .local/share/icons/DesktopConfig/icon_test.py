#!/usr/bin/env python3

import sys
import gi
gi.require_version('Gtk', '3.0');
from gi.repository import Gtk;
icon_theme = Gtk.IconTheme.get_default(); 

for icon_name in sys.argv[1:]:
  icn = icon_theme.lookup_icon(icon_name, 48, 0)
  if icn:
    print(icn.get_filename())
  else:
    print('Icon Not Found')
