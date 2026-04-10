"""Generate 24×24 placeholder icons and .lrs files for all MD3 components."""
import struct
import zlib
import os

COMPONENTS = [
    'frmaterialbutton',
    'frmaterialbuttonicon',
    'frmaterialsplitbutton',
    'frmaterialfab',
    'frmaterialextendedfab',
    'frmaterialfabmenu',
    'frmaterialswitch',
    'frmaterialcheckbox',
    'frmaterialradiobutton',
    'frmaterialchip',
    'frmaterialsegmentedbutton',
    'frmaterialslider',
    'frmateriallinearprogress',
    'frmaterialcircularprogress',
    'frmaterialloadingindicator',
    'frmaterialdivider',
    'frmaterialgroupbox',
    'frmaterialdialog',
    'frmaterialsnackbar',
    'frmaterialtooltip',
    'frmateriallistview',
    'frmaterialmenu',
    'frmaterialtabs',
    'frmaterialappbar',
    'frmaterialtoolbar',
    'frmaterialnavbar',
    'frmaterialnavdrawer',
    'frmaterialnavrail',
    'frmaterialtimepicker',
    'frmaterialbottomsheet',
    'frmaterialsidesheet',
]

# MD3 Primary color #6750A4
PR, PG, PB = 0x67, 0x50, 0xA4

def make_png_24(pixels):
    """Create a minimal 24x24 RGBA PNG from pixel data."""
    w, h = 24, 24
    def chunk(ctype, data):
        c = ctype + data
        return struct.pack('>I', len(data)) + c + struct.pack('>I', zlib.crc32(c) & 0xffffffff)
    
    raw = b''
    for y in range(h):
        raw += b'\x00'  # filter none
        for x in range(w):
            raw += bytes(pixels[y][x])
    
    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)
    compressed = zlib.compress(raw)
    return sig + chunk(b'IHDR', ihdr) + chunk(b'IDAT', compressed) + chunk(b'IEND', b'')

def blank():
    return [[(0,0,0,0) for _ in range(24)] for _ in range(24)]

def set_pixel(img, x, y, r, g, b, a=255):
    if 0 <= x < 24 and 0 <= y < 24:
        img[y][x] = (r, g, b, a)

def fill_rect(img, x1, y1, x2, y2, r, g, b, a=255):
    for y in range(y1, y2+1):
        for x in range(x1, x2+1):
            set_pixel(img, x, y, r, g, b, a)

def draw_rect(img, x1, y1, x2, y2, r, g, b, a=255):
    for x in range(x1, x2+1):
        set_pixel(img, x, y1, r, g, b, a)
        set_pixel(img, x, y2, r, g, b, a)
    for y in range(y1, y2+1):
        set_pixel(img, x1, y, r, g, b, a)
        set_pixel(img, x2, y, r, g, b, a)

def draw_rounded_rect(img, x1, y1, x2, y2, r, g, b, a=255):
    draw_rect(img, x1+1, y1, x2-1, y2, r, g, b, a)
    for y in range(y1+1, y2):
        set_pixel(img, x1, y, r, g, b, a)
        set_pixel(img, x2, y, r, g, b, a)

def fill_circle(img, cx, cy, rad, r, g, b, a=255):
    for y in range(cy-rad, cy+rad+1):
        for x in range(cx-rad, cx+rad+1):
            if (x-cx)**2 + (y-cy)**2 <= rad**2:
                set_pixel(img, x, y, r, g, b, a)

def draw_circle(img, cx, cy, rad, r, g, b, a=255):
    for y in range(cy-rad, cy+rad+1):
        for x in range(cx-rad, cx+rad+1):
            d = (x-cx)**2 + (y-cy)**2
            if rad**2 - rad <= d <= rad**2 + rad:
                set_pixel(img, x, y, r, g, b, a)

def hline(img, x1, x2, y, r, g, b, a=255):
    for x in range(x1, x2+1):
        set_pixel(img, x, y, r, g, b, a)

def vline(img, x, y1, y2, r, g, b, a=255):
    for y in range(y1, y2+1):
        set_pixel(img, x, y, r, g, b, a)

def make_icon(name):
    img = blank()
    if name == 'frmaterialbutton':
        fill_rect(img, 2, 7, 21, 16, PR, PG, PB)
        for x in range(8, 16):
            set_pixel(img, x, 11, 255, 255, 255)
            set_pixel(img, x, 12, 255, 255, 255)
    elif name == 'frmaterialbuttonicon':
        fill_circle(img, 12, 12, 8, PR, PG, PB)
        hline(img, 9, 15, 12, 255, 255, 255)
        vline(img, 12, 9, 15, 255, 255, 255)
    elif name == 'frmaterialsplitbutton':
        fill_rect(img, 2, 7, 17, 16, PR, PG, PB)
        fill_rect(img, 18, 7, 21, 16, PR-0x20, PG-0x20, PB)
        vline(img, 17, 7, 16, 255, 255, 255)
    elif name == 'frmaterialfab':
        fill_circle(img, 12, 12, 9, PR, PG, PB)
        hline(img, 8, 16, 12, 255, 255, 255)
        vline(img, 12, 8, 16, 255, 255, 255)
    elif name == 'frmaterialextendedfab':
        fill_rect(img, 2, 6, 21, 17, PR, PG, PB)
        hline(img, 5, 8, 12, 255, 255, 255)
        vline(img, 7, 10, 14, 255, 255, 255)
    elif name == 'frmaterialfabmenu':
        fill_circle(img, 12, 17, 5, PR, PG, PB)
        fill_circle(img, 8, 9, 3, PR, PG, PB, 180)
        fill_circle(img, 16, 9, 3, PR, PG, PB, 180)
        fill_circle(img, 12, 3, 3, PR, PG, PB, 180)
    elif name == 'frmaterialswitch':
        fill_rect(img, 3, 8, 20, 15, PR, PG, PB, 100)
        fill_circle(img, 17, 12, 5, PR, PG, PB)
    elif name == 'frmaterialcheckbox':
        fill_rect(img, 5, 5, 18, 18, PR, PG, PB)
        # checkmark
        for i in range(4):
            set_pixel(img, 8+i, 12+i, 255, 255, 255)
        for i in range(6):
            set_pixel(img, 12+i, 15-i, 255, 255, 255)
    elif name == 'frmaterialradiobutton':
        draw_circle(img, 12, 12, 8, PR, PG, PB)
        fill_circle(img, 12, 12, 4, PR, PG, PB)
    elif name == 'frmaterialchip':
        draw_rounded_rect(img, 3, 7, 20, 16, PR, PG, PB)
        for x in range(7, 17):
            set_pixel(img, x, 11, PR, PG, PB)
            set_pixel(img, x, 12, PR, PG, PB)
    elif name == 'frmaterialsegmentedbutton':
        draw_rect(img, 2, 7, 10, 16, PR, PG, PB)
        fill_rect(img, 10, 7, 14, 16, PR, PG, PB)
        draw_rect(img, 14, 7, 21, 16, PR, PG, PB)
    elif name == 'frmaterialslider':
        hline(img, 3, 20, 12, PR, PG, PB, 100)
        hline(img, 3, 12, 12, PR, PG, PB)
        fill_circle(img, 12, 12, 4, PR, PG, PB)
    elif name == 'frmateriallinearprogress':
        fill_rect(img, 3, 10, 20, 13, PR, PG, PB, 80)
        fill_rect(img, 3, 10, 14, 13, PR, PG, PB)
    elif name == 'frmaterialcircularprogress':
        draw_circle(img, 12, 12, 8, PR, PG, PB, 80)
        # quarter arc
        for a in range(0, 7):
            set_pixel(img, 12+a, 4, PR, PG, PB)
        for a in range(0, 7):
            set_pixel(img, 20, 5+a, PR, PG, PB)
    elif name == 'frmaterialloadingindicator':
        fill_circle(img, 6, 12, 3, PR, PG, PB)
        fill_circle(img, 12, 12, 3, PR, PG, PB, 160)
        fill_circle(img, 18, 12, 3, PR, PG, PB, 80)
    elif name == 'frmaterialdivider':
        hline(img, 3, 20, 12, PR, PG, PB)
    elif name == 'frmaterialgroupbox':
        draw_rounded_rect(img, 3, 5, 20, 20, PR, PG, PB)
        fill_rect(img, 5, 4, 12, 6, 0, 0, 0, 0)  # clear for label
        hline(img, 6, 11, 5, PR, PG, PB)
    elif name == 'frmaterialdialog':
        fill_rect(img, 4, 4, 19, 19, PR, PG, PB, 40)
        draw_rounded_rect(img, 4, 4, 19, 19, PR, PG, PB)
        hline(img, 7, 16, 8, PR, PG, PB)
        hline(img, 7, 16, 12, PR, PG, PB, 100)
        fill_rect(img, 12, 16, 17, 18, PR, PG, PB)
    elif name == 'frmaterialsnackbar':
        fill_rect(img, 2, 15, 21, 21, 0x30, 0x30, 0x30)
        for x in range(5, 16):
            set_pixel(img, x, 18, 255, 255, 255)
    elif name == 'frmaterialtooltip':
        fill_rect(img, 4, 8, 19, 15, 0x30, 0x30, 0x30)
        for x in range(7, 17):
            set_pixel(img, x, 11, 255, 255, 255)
            set_pixel(img, x, 12, 255, 255, 255)
    elif name == 'frmateriallistview':
        for row in range(3):
            y = 4 + row * 7
            fill_circle(img, 6, y+2, 2, PR, PG, PB)
            hline(img, 10, 20, y+1, PR, PG, PB)
            hline(img, 10, 17, y+3, PR, PG, PB, 100)
    elif name == 'frmaterialmenu':
        fill_rect(img, 5, 3, 19, 20, PR, PG, PB, 40)
        draw_rounded_rect(img, 5, 3, 19, 20, PR, PG, PB)
        hline(img, 8, 17, 7, PR, PG, PB)
        hline(img, 8, 17, 11, PR, PG, PB)
        hline(img, 8, 17, 15, PR, PG, PB)
    elif name == 'frmaterialtabs':
        hline(img, 2, 21, 17, PR, PG, PB, 80)
        # 3 tabs
        for t in range(3):
            x = 3 + t * 7
            hline(img, x, x+5, 12, PR, PG, PB, 120)
        # active indicator
        fill_rect(img, 3, 16, 8, 17, PR, PG, PB)
    elif name == 'frmaterialappbar':
        fill_rect(img, 2, 2, 21, 12, PR, PG, PB, 30)
        hline(img, 2, 21, 2, PR, PG, PB)
        hline(img, 2, 21, 12, PR, PG, PB)
        # hamburger
        hline(img, 4, 8, 5, PR, PG, PB)
        hline(img, 4, 8, 7, PR, PG, PB)
        hline(img, 4, 8, 9, PR, PG, PB)
        # title
        hline(img, 10, 18, 7, PR, PG, PB)
    elif name == 'frmaterialtoolbar':
        fill_rect(img, 2, 8, 21, 16, PR, PG, PB, 30)
        for i in range(4):
            x = 4 + i * 5
            fill_rect(img, x, 10, x+2, 14, PR, PG, PB)
    elif name == 'frmaterialnavbar':
        fill_rect(img, 2, 16, 21, 22, PR, PG, PB, 30)
        hline(img, 2, 21, 16, PR, PG, PB, 80)
        for i in range(3):
            x = 5 + i * 6
            fill_circle(img, x, 19, 2, PR, PG, PB)
    elif name == 'frmaterialnavdrawer':
        fill_rect(img, 2, 2, 14, 21, PR, PG, PB, 30)
        vline(img, 14, 2, 21, PR, PG, PB)
        for i in range(3):
            y = 5 + i * 5
            hline(img, 4, 12, y, PR, PG, PB)
    elif name == 'frmaterialnavrail':
        fill_rect(img, 2, 2, 8, 21, PR, PG, PB, 30)
        vline(img, 8, 2, 21, PR, PG, PB)
        for i in range(3):
            y = 5 + i * 6
            fill_circle(img, 5, y, 2, PR, PG, PB)
    elif name == 'frmaterialtimepicker':
        # clock face
        draw_circle(img, 12, 12, 9, PR, PG, PB)
        fill_circle(img, 12, 12, 1, PR, PG, PB)
        # hands
        vline(img, 12, 5, 12, PR, PG, PB)
        hline(img, 12, 17, 12, PR, PG, PB)
    elif name == 'frmaterialbottomsheet':
        draw_rounded_rect(img, 3, 10, 20, 22, PR, PG, PB)
        fill_rect(img, 4, 11, 19, 21, PR, PG, PB, 30)
        # drag handle
        hline(img, 9, 14, 12, PR, PG, PB)
    elif name == 'frmaterialsidesheet':
        draw_rounded_rect(img, 12, 2, 21, 21, PR, PG, PB)
        fill_rect(img, 13, 3, 20, 20, PR, PG, PB, 30)
    else:
        fill_rect(img, 4, 4, 19, 19, PR, PG, PB)
    return img

def png_to_lrs(png_data, resource_name):
    parts = []
    line = ''
    in_str = False
    for b in png_data:
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
    
    result = "LazarusResources.Add('%s','PNG',[\n" % resource_name
    for idx, p in enumerate(parts):
        prefix = '  ' if idx == 0 else '  +'
        result += "%s%s\n" % (prefix, p)
    result += ']);\n'
    return result

os.chdir(os.path.dirname(os.path.abspath(__file__)))

for name in COMPONENTS:
    img = make_icon(name)
    png_data = make_png_24(img)
    
    # Write PNG
    with open(name + '.png', 'wb') as f:
        f.write(png_data)
    
    # Write LRS
    lrs = png_to_lrs(png_data, name)
    with open(name + '_icon.lrs', 'w') as f:
        f.write(lrs)
    
    print('Generated %s (.png + .lrs)' % name)

print('\nDone! Generated %d icons.' % len(COMPONENTS))
