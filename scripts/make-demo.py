#!/usr/bin/env python3
"""Make the site's short illustrated demo. Requires Pillow and ffmpeg."""
from pathlib import Path
import subprocess
import tempfile
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FONT = "/System/Library/Fonts/Supplemental/Arial.ttf"

with tempfile.TemporaryDirectory() as temp:
    frames = []
    for desktop in (1, 2):
        image = Image.new("RGB", (960, 540), "#202020")
        draw = ImageDraw.Draw(image)
        draw.rounded_rectangle((75, 75, 885, 385), 10, fill="#454545")
        draw.rectangle((75, 75, 885, 103), fill="#666666")
        draw.rounded_rectangle((110, 135, 850, 330), 8, fill="#777777" if desktop == 1 else "#999999")
        title = ImageFont.truetype(FONT, 38)
        small = ImageFont.truetype(FONT, 27)
        draw.text((145, 204), f"Desktop {desktop}", font=title, fill="white")
        draw.text((480, 442), "Ctrl + Right Arrow", font=small, fill="white", anchor="mm")
        draw.text((480, 491), "Illustration", font=ImageFont.truetype(FONT, 17), fill="#bbbbbb", anchor="mm")
        path = Path(temp) / f"desktop-{desktop}.png"
        image.save(path)
        frames.append(path)
    subprocess.run([
        "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
        "-loop", "1", "-t", "2.5", "-i", str(frames[0]),
        "-loop", "1", "-t", "2.5", "-i", str(frames[1]),
        "-filter_complex", "[0:v][1:v]concat=n=2:v=1:a=0,format=yuv420p[v]",
        "-map", "[v]", "-r", "24", "-c:v", "libx264", "-crf", "22",
        "-movflags", "+faststart", str(ROOT / "docs" / "demo.mp4"),
    ], check=True)
