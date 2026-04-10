#!/usr/bin/env python3
"""Generate 24x24 component icons for the Material Design 3 Lazarus package.

Each icon is saved as PNG and converted to .lrs (Lazarus resource string) format.
Uses Material Design 3 primary color (#6750A4) as accent.
"""

import io
import os
import math
from PIL import Image, ImageDraw

SIZE = 24
# MD3 Primary purple
P = (103, 80, 164, 255)
# Surface / light gray
S = (230, 225, 240, 255)
# On Surface / dark
D = (28, 27, 31, 255)
# Outline
O = (121, 116, 126, 255)
# Transparent
T = (0, 0, 0, 0)
# White
W = (255, 255, 255, 255)


def new_img():
    return Image.new('RGBA', (SIZE, SIZE), T)


def draw_rounded_rect(draw, xy, radius, fill=None, outline=None, width=1):
    x0, y0, x1, y1 = xy
    if fill:
        draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)
    elif outline:
        draw.rounded_rectangle(xy, radius=radius, fill=None, outline=outline, width=width)


# --- Icon drawing functions ---

def icon_edit(draw):
    """Text field with underline and floating label"""
    draw_rounded_rect(draw, (2, 6, 21, 20), 3, outline=O, width=1)
    draw.line((6, 16, 17, 16), fill=P, width=1)
    draw.text((5, 2), "A", fill=P)
    draw.line((6, 10, 14, 10), fill=D, width=1)


def icon_button(draw):
    """Filled rounded button"""
    draw_rounded_rect(draw, (1, 6, 22, 18), 6, fill=P)
    draw.text((7, 7), "Btn", fill=W)


def icon_buttonicon(draw):
    """Circle button with icon"""
    draw.ellipse((4, 4, 19, 19), fill=P)
    draw.line((9, 11, 14, 11), fill=W, width=2)
    draw.line((11, 9, 11, 14), fill=W, width=2)


def icon_splitbutton(draw):
    """Button with dropdown divider"""
    draw_rounded_rect(draw, (1, 6, 22, 18), 5, fill=P)
    draw.line((17, 8, 17, 16), fill=W, width=1)
    # Arrow
    draw.polygon([(19, 10), (21, 13), (19, 13)], fill=W)


def icon_checkbox(draw):
    """Square with checkmark"""
    draw_rounded_rect(draw, (4, 4, 19, 19), 3, fill=P)
    draw.line((8, 12, 10, 15), fill=W, width=2)
    draw.line((10, 15, 16, 8), fill=W, width=2)


def icon_radiobutton(draw):
    """Circle with inner dot"""
    draw.ellipse((3, 3, 20, 20), outline=P, width=2)
    draw.ellipse((8, 8, 15, 15), fill=P)


def icon_switch(draw):
    """Toggle switch in ON state"""
    draw_rounded_rect(draw, (2, 7, 21, 17), 5, fill=P)
    draw.ellipse((13, 6, 22, 17), fill=W, outline=P, width=1)


def icon_slider(draw):
    """Horizontal slider with handle"""
    draw.line((3, 12, 20, 12), fill=O, width=2)
    draw.line((3, 12, 14, 12), fill=P, width=2)
    draw.ellipse((10, 7, 18, 17), fill=P)


def icon_appbar(draw):
    """Top app bar with title line"""
    draw_rounded_rect(draw, (1, 2, 22, 8), 2, fill=P)
    draw.line((4, 5, 12, 5), fill=W, width=1)
    draw_rounded_rect(draw, (1, 10, 22, 21), 2, outline=O, width=1)


def icon_toolbar(draw):
    """Bar with action icons"""
    draw_rounded_rect(draw, (1, 6, 22, 18), 3, fill=S)
    draw.ellipse((3, 9, 8, 14), fill=P)
    draw.ellipse((10, 9, 15, 14), fill=P)
    draw.ellipse((17, 9, 22, 14), fill=P)


def icon_dialog(draw):
    """Modal dialog card"""
    # Scrim
    draw_rounded_rect(draw, (0, 0, 23, 23), 0, fill=(0, 0, 0, 40))
    # Card
    draw_rounded_rect(draw, (3, 4, 20, 19), 4, fill=W, outline=O, width=1)
    draw.line((6, 8, 16, 8), fill=D, width=1)
    draw.line((6, 11, 14, 11), fill=O, width=1)
    draw_rounded_rect(draw, (12, 15, 18, 18), 2, fill=P)


def icon_snackbar(draw):
    """Bottom toast bar"""
    draw_rounded_rect(draw, (1, 14, 22, 22), 4, fill=D)
    draw.line((4, 18, 14, 18), fill=W, width=1)


def icon_chip(draw):
    """Pill-shaped chip"""
    draw_rounded_rect(draw, (2, 7, 21, 17), 5, outline=P, width=2)
    draw.text((7, 7), "Abc", fill=P)


def icon_segmentedbutton(draw):
    """Two connected segments"""
    draw_rounded_rect(draw, (1, 7, 11, 17), 3, fill=P)
    draw_rounded_rect(draw, (12, 7, 22, 17), 3, outline=P, width=1)


def icon_fab(draw):
    """Floating action button (circle with +)"""
    draw.ellipse((3, 3, 20, 20), fill=P)
    draw.line((8, 11, 15, 11), fill=W, width=2)
    draw.line((11, 8, 11, 15), fill=W, width=2)


def icon_extendedfab(draw):
    """Extended FAB (rounded rect with +)"""
    draw_rounded_rect(draw, (1, 6, 22, 18), 6, fill=P)
    draw.line((5, 12, 9, 12), fill=W, width=2)
    draw.line((7, 10, 7, 14), fill=W, width=2)


def icon_fabmenu(draw):
    """FAB with menu dots"""
    draw.ellipse((5, 5, 18, 18), fill=P)
    draw.line((9, 11, 14, 11), fill=W, width=2)
    draw.line((11, 9, 11, 14), fill=W, width=2)
    # Menu dots
    for y in [1, 4]:
        draw.rectangle((20, y, 22, y+1), fill=O)


def icon_divider(draw):
    """Simple horizontal divider line"""
    draw.line((2, 12, 21, 12), fill=O, width=1)


def icon_groupbox(draw):
    """Rounded container with title"""
    draw_rounded_rect(draw, (1, 5, 22, 21), 4, outline=O, width=1)
    draw.rectangle((4, 3, 14, 7), fill=W)
    draw.line((5, 5, 13, 5), fill=P, width=1)


def icon_menu(draw):
    """Three horizontal lines (hamburger)"""
    for y in [6, 11, 16]:
        draw.line((4, y, 19, y), fill=D, width=2)
    draw.ellipse((15, 5, 19, 9), fill=P)


def icon_navbar(draw):
    """Bottom navigation bar with dots"""
    draw_rounded_rect(draw, (1, 14, 22, 22), 2, fill=S)
    for x in [5, 11, 17]:
        draw.ellipse((x-1, 16, x+3, 20), fill=P)


def icon_navdrawer(draw):
    """Side navigation panel"""
    draw_rounded_rect(draw, (1, 1, 10, 22), 3, fill=S)
    draw.line((3, 5, 8, 5), fill=P, width=2)
    draw.line((3, 9, 8, 9), fill=O, width=1)
    draw.line((3, 12, 8, 12), fill=O, width=1)
    draw_rounded_rect(draw, (12, 1, 22, 22), 2, outline=O, width=1)


def icon_navrail(draw):
    """Vertical navigation rail"""
    draw_rounded_rect(draw, (1, 1, 8, 22), 2, fill=S)
    for y in [4, 10, 16]:
        draw.ellipse((2, y, 7, y+4), fill=P)
    draw_rounded_rect(draw, (10, 1, 22, 22), 2, outline=O, width=1)


def icon_tabs(draw):
    """Tab bar with active indicator"""
    draw.line((1, 8, 22, 8), fill=O, width=1)
    draw.line((2, 4, 8, 4), fill=D, width=1)
    draw.line((10, 4, 16, 4), fill=P, width=2)
    draw.line((10, 8, 16, 8), fill=P, width=2)
    draw.line((18, 4, 22, 4), fill=D, width=1)
    draw_rounded_rect(draw, (1, 10, 22, 22), 2, outline=O, width=1)


def icon_pagecontrol(draw):
    """Page with tab indicators"""
    draw_rounded_rect(draw, (1, 1, 22, 22), 3, outline=O, width=1)
    draw.line((1, 7, 22, 7), fill=O, width=1)
    draw_rounded_rect(draw, (2, 2, 8, 6), 1, fill=P)
    draw_rounded_rect(draw, (9, 2, 15, 6), 1, fill=S)


def icon_listview(draw):
    """List with rows"""
    for y in [3, 9, 15]:
        draw.ellipse((3, y, 7, y+4), fill=S)
        draw.line((10, y+1, 20, y+1), fill=D, width=1)
        draw.line((10, y+3, 16, y+3), fill=O, width=1)


def icon_treeview(draw):
    """Tree structure with lines"""
    draw.line((4, 3, 4, 20), fill=O, width=1)
    draw.line((4, 6, 10, 6), fill=O, width=1)
    draw.rectangle((11, 4, 20, 8), fill=P)
    draw.line((4, 12, 10, 12), fill=O, width=1)
    draw.rectangle((11, 10, 18, 14), fill=S, outline=O)
    draw.line((10, 12, 10, 18), fill=O, width=1)
    draw.line((10, 18, 14, 18), fill=O, width=1)
    draw.rectangle((15, 16, 21, 20), fill=S, outline=O)


def icon_datagrid(draw):
    """Data grid / table"""
    draw_rounded_rect(draw, (1, 2, 22, 21), 2, outline=O, width=1)
    # Header
    draw.rectangle((2, 3, 21, 7), fill=P)
    # Vertical dividers
    draw.line((9, 3, 9, 20), fill=O, width=1)
    draw.line((16, 3, 16, 20), fill=O, width=1)
    # Horizontal rows
    draw.line((2, 11, 21, 11), fill=O, width=1)
    draw.line((2, 16, 21, 16), fill=O, width=1)


def icon_linearprogress(draw):
    """Linear progress bar"""
    draw_rounded_rect(draw, (2, 10, 21, 14), 2, fill=S)
    draw_rounded_rect(draw, (2, 10, 14, 14), 2, fill=P)


def icon_circularprogress(draw):
    """Circular progress indicator"""
    draw.arc((4, 4, 19, 19), 0, 360, fill=S, width=3)
    draw.arc((4, 4, 19, 19), -90, 150, fill=P, width=3)


def icon_loadingindicator(draw):
    """Spinning dots indicator"""
    angles = [0, 45, 90, 135, 180, 225, 270, 315]
    cx, cy, r = 11, 11, 8
    for i, a in enumerate(angles):
        x = cx + int(r * math.cos(math.radians(a)))
        y = cy + int(r * math.sin(math.radians(a)))
        alpha = 255 - i * 28
        c = (P[0], P[1], P[2], max(alpha, 60))
        draw.ellipse((x-1, y-1, x+1, y+1), fill=c)


def icon_timepicker(draw):
    """Clock face"""
    draw.ellipse((2, 2, 21, 21), outline=P, width=2)
    draw.line((11, 11, 11, 5), fill=D, width=2)
    draw.line((11, 11, 16, 14), fill=D, width=1)
    draw.ellipse((10, 10, 13, 13), fill=P)


def icon_tooltip(draw):
    """Speech bubble tooltip"""
    draw_rounded_rect(draw, (2, 3, 21, 15), 4, fill=D)
    draw.polygon([(8, 15), (12, 19), (14, 15)], fill=D)
    draw.line((6, 8, 18, 8), fill=W, width=1)
    draw.line((6, 11, 14, 11), fill=W, width=1)


def icon_bottomsheet(draw):
    """Bottom sheet panel"""
    draw_rounded_rect(draw, (1, 1, 22, 22), 2, outline=O, width=1)
    draw_rounded_rect(draw, (1, 10, 22, 22), 4, fill=S, outline=O, width=1)
    draw.line((8, 11, 15, 11), fill=P, width=2)  # Handle


def icon_sidesheet(draw):
    """Side sheet panel"""
    draw_rounded_rect(draw, (1, 1, 22, 22), 2, outline=O, width=1)
    draw_rounded_rect(draw, (12, 1, 22, 22), 4, fill=S, outline=O, width=1)
    draw.line((15, 5, 20, 5), fill=D, width=1)
    draw.line((15, 8, 19, 8), fill=O, width=1)


def icon_comboedit(draw):
    """Dropdown combo with arrow"""
    draw_rounded_rect(draw, (2, 6, 21, 18), 3, outline=O, width=1)
    draw.line((5, 12, 14, 12), fill=D, width=1)
    draw.polygon([(17, 10), (20, 13), (17, 13)], fill=P)


def icon_checkcomboedit(draw):
    """Combo with checkmark"""
    draw_rounded_rect(draw, (2, 6, 21, 18), 3, outline=O, width=1)
    # Checkmark
    draw.line((5, 11, 7, 14), fill=P, width=2)
    draw.line((7, 14, 11, 9), fill=P, width=2)
    draw.polygon([(17, 10), (20, 13), (17, 13)], fill=P)


def icon_currencyedit(draw):
    """Text field with $ symbol"""
    draw_rounded_rect(draw, (2, 6, 21, 18), 3, outline=O, width=1)
    draw.text((4, 7), "$", fill=P)
    draw.line((10, 12, 18, 12), fill=D, width=1)


def icon_dateedit(draw):
    """Calendar icon"""
    draw_rounded_rect(draw, (2, 4, 21, 21), 3, outline=O, width=1)
    draw.rectangle((3, 5, 20, 9), fill=P)
    # Calendar dots
    for x in [6, 11, 16]:
        for y in [12, 16]:
            draw.rectangle((x-1, y, x+1, y+2), fill=D)


def icon_maskedit(draw):
    """Text field with format mask"""
    draw_rounded_rect(draw, (2, 6, 21, 18), 3, outline=O, width=1)
    # Dashes representing mask
    for x in [5, 9, 15, 19]:
        draw.rectangle((x-1, 11, x+1, 13), fill=P)
    draw.line((12, 11, 13, 13), fill=O, width=1)


def icon_memoedit(draw):
    """Multi-line text area"""
    draw_rounded_rect(draw, (2, 2, 21, 21), 3, outline=O, width=1)
    for y in [6, 10, 14, 18]:
        w = 16 if y < 18 else 10
        draw.line((5, y, 5+w, y), fill=D, width=1)


def icon_searchedit(draw):
    """Magnifying glass"""
    draw.ellipse((3, 3, 15, 15), outline=P, width=2)
    draw.line((14, 14, 20, 20), fill=P, width=3)


def icon_spinedit(draw):
    """Number field with up/down arrows"""
    draw_rounded_rect(draw, (2, 5, 21, 19), 3, outline=O, width=1)
    draw.text((5, 8), "12", fill=D)
    # Up arrow
    draw.polygon([(17, 8), (19, 8), (18, 6)], fill=P)
    # Down arrow
    draw.polygon([(17, 16), (19, 16), (18, 18)], fill=P)


def icon_thememanager(draw):
    """Palette / color theme"""
    draw.ellipse((2, 2, 21, 21), outline=P, width=2)
    draw.ellipse((6, 5, 9, 8), fill=(234, 67, 53, 255))    # Red
    draw.ellipse((11, 3, 14, 6), fill=(66, 133, 244, 255))  # Blue
    draw.ellipse((15, 7, 18, 10), fill=(52, 168, 83, 255))  # Green
    draw.ellipse((5, 11, 8, 14), fill=(251, 188, 4, 255))   # Yellow
    draw.ellipse((10, 14, 13, 17), fill=P)                   # Purple


# Map resource name -> draw function
ICONS = {
    'frmaterialedit':             icon_edit,
    'frmaterialbutton':           icon_button,
    'frmaterialbuttonicon':       icon_buttonicon,
    'frmaterialsplitbutton':      icon_splitbutton,
    'frmaterialcheckbox':         icon_checkbox,
    'frmaterialradiobutton':      icon_radiobutton,
    'frmaterialswitch':           icon_switch,
    'frmaterialslider':           icon_slider,
    'frmaterialappbar':           icon_appbar,
    'frmaterialtoolbar':          icon_toolbar,
    'frmaterialdialog':           icon_dialog,
    'frmaterialsnackbar':         icon_snackbar,
    'frmaterialchip':             icon_chip,
    'frmaterialsegmentedbutton':  icon_segmentedbutton,
    'frmaterialfab':              icon_fab,
    'frmaterialextendedfab':      icon_extendedfab,
    'frmaterialfabmenu':          icon_fabmenu,
    'frmaterialdivider':          icon_divider,
    'frmaterialgroupbox':         icon_groupbox,
    'frmaterialmenu':             icon_menu,
    'frmaterialnavbar':           icon_navbar,
    'frmaterialnavdrawer':        icon_navdrawer,
    'frmaterialnavrail':          icon_navrail,
    'frmaterialtabs':             icon_tabs,
    'frmaterialpagecontrol':      icon_pagecontrol,
    'frmateriallistview':         icon_listview,
    'frmaterialtreeview':         icon_treeview,
    'frmaterialdatagrid':         icon_datagrid,
    'frmateriallinearprogress':   icon_linearprogress,
    'frmaterialcircularprogress': icon_circularprogress,
    'frmaterialloadingindicator': icon_loadingindicator,
    'frmaterialtimepicker':       icon_timepicker,
    'frmaterialtooltip':          icon_tooltip,
    'frmaterialbottomsheet':      icon_bottomsheet,
    'frmaterialsidesheet':        icon_sidesheet,
    'frmaterialcomboedit':        icon_comboedit,
    'frmaterialcheckcomboedit':   icon_checkcomboedit,
    'frmaterialcurrencyedit':     icon_currencyedit,
    'frmaterialdateedit':         icon_dateedit,
    'frmaterialmaskedit':         icon_maskedit,
    'frmaterialmemoedit':         icon_memoedit,
    'frmaterialsearchedit':       icon_searchedit,
    'frmaterialspinedit':         icon_spinedit,
    'frmaterialthememanager':     icon_thememanager,
}


def png_to_lrs(name: str, png_bytes: bytes) -> str:
    """Convert PNG bytes to Lazarus .lrs resource string format.
    
    Uses compact format: #code'text'#code (no + within line, + only at line start)
    """
    lines = [f"LazarusResources.Add('{name}','PNG',["]
    raw = list(png_bytes)
    chunk_size = 64
    i = 0
    first_line = True
    
    while i < len(raw):
        end = min(i + chunk_size, len(raw))
        parts = []
        j = i
        while j < end:
            b = raw[j]
            # Try to collect a run of printable ASCII chars
            if 32 <= b <= 126 and chr(b) not in ("'", '#', '+'):
                start = j
                while (j < end and 32 <= raw[j] <= 126 
                       and chr(raw[j]) not in ("'", '#', '+')):
                    j += 1
                txt = bytes(raw[start:j]).decode('latin-1')
                parts.append(f"'{txt}'")
            else:
                parts.append(f"#{raw[j]}")
                j += 1
        
        # Join without separator (Pascal implicit concatenation)
        line_content = ''.join(parts)
        if first_line:
            lines.append(f"  {line_content}")
            first_line = False
        else:
            lines.append(f"  +{line_content}")
        i = end
    
    lines.append("]);")
    return '\n'.join(lines) + '\n'


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    for name, draw_fn in ICONS.items():
        img = new_img()
        draw = ImageDraw.Draw(img)
        draw_fn(draw)
        
        # Save PNG
        buf = io.BytesIO()
        img.save(buf, format='PNG', optimize=True)
        png_bytes = buf.getvalue()
        
        # Save .lrs
        lrs_content = png_to_lrs(name, png_bytes)
        lrs_path = os.path.join(script_dir, f"{name}_icon.lrs")
        with open(lrs_path, 'w', encoding='utf-8') as f:
            f.write(lrs_content)
        
        print(f"  Generated: {name}_icon.lrs ({len(png_bytes)} bytes)")
    
    print(f"\nDone! {len(ICONS)} icons generated.")


if __name__ == '__main__':
    main()
