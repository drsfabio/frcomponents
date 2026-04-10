import os
import sys

def png_to_lrs(png_path, resource_name, lrs_path):
    with open(png_path, 'rb') as f:
        data = f.read()
    
    parts = []
    line = ''
    in_str = False
    for i, b in enumerate(data):
        if 32 <= b < 127 and b != ord("'") and b != ord('#'):
            if not in_str:
                line += "'"
                in_str = True
            line += chr(b)
        else:
            if in_str:
                line += "'"
                in_str = False
            line += '#' + str(b)
        if len(line) > 60:
            if in_str:
                line += "'"
                in_str = False
            parts.append(line)
            line = ''
    if in_str:
        line += "'"
    if line:
        parts.append(line)
    
    with open(lrs_path, 'w') as f:
        f.write("LazarusResources.Add('%s','PNG',[\n" % resource_name)
        for idx, p in enumerate(parts):
            prefix = '  ' if idx == 0 else '  +'
            f.write("%s%s\n" % (prefix, p))
        f.write(']);\n')

for name in ['frmaterialmemoedit', 'frmaterialspinedit', 'frmaterialsearchedit']:
    png_to_lrs(name + '.png', name, name + '_icon.lrs')
    print('Generated %s_icon.lrs' % name)
