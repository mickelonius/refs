#!/usr/bin/env python
# Batch thumbnail generation script using PIL

import sys
import shutil
import os.path
# from image import Image
from PIL import Image
thumbnail_height = 200

filepath = sys.argv[1]
shutil.rmtree(os.path.join(filepath, "thumbs"))
os.makedirs(os.path.join(filepath, "thumbs"))

for root, dirs, files in os.walk(os.path.join(filepath, "orig")):
    for file in files:
        try:
            # Attempt to open an image file
            image = Image.open(os.path.join(filepath, "orig", file))

            # Resize the image
            aspect_ratio = image.size[0] / image.size[1]
            h = thumbnail_height
            w = int(aspect_ratio * thumbnail_height)
            print(f"{file}, {image.size} to {(w, h)}")

            thumbnail_size = (w, h)
            image = image.resize(thumbnail_size, Image.ANTIALIAS)

            # Split our original filename into name and extension
            (name, extension) = os.path.splitext(filepath)

            # Save the thumbnail as "(original_name)_thumb.png"
            image.save(os.path.join(filepath, "thumbs", f"{file}__thumb.png"))
        except Exception as e:  # IOError, e:
            # Report error, and then skip to the next argument
            print("Problem opening", file, ":", e)
            continue

