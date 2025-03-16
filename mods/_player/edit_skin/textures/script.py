import os
from PIL import Image
import sys

# Get the path to the skin files (a folder argument)
# right arm (40, 16) -> (56, 32) needs to be copied to left arm (32, 48) -> (48, 64)
    # within this portion, {(40, 20)->(52, 32)} needs to be mirrored x-axis AFTER being copied
    # so does {(44, 16)->(48, 20)}
# right leg (0, 16) -> (16, 32) needs to be copied to left leg (16, 48) -> (32, 64)
    # within this portion, {(0, 20)->(12, 32)} needs to be mirrored x-axis AFTER being copied
    # so does {(4, 16)->(8, 20)}

# write these skins to the same file, and only take the first argument for the skin file

def convert_skin(image_path):
    img = Image.open(image_path)
    if img.size != (64, 32):
        print(f"Skipping {image_path}, not a 64x32 image.")
        return

    new_img = Image.new("RGBA", (64, 64))
    new_img.paste(img, (0, 0))

    # Copy right arm to left arm
    right_arm = img.crop((40, 16, 56, 32))
    new_img.paste(right_arm, (32, 48))

    # Mirror x-axis for specific portions of the right arm
    right_arm_top = img.crop((44, 16, 48, 20)).transpose(Image.FLIP_LEFT_RIGHT)
    new_img.paste(right_arm_top, (36, 48))
    right_arm_bottom = img.crop((40, 20, 52, 32)).transpose(Image.FLIP_LEFT_RIGHT)
    new_img.paste(right_arm_bottom, (32, 52))

    # Copy right leg to left leg
    right_leg = img.crop((0, 16, 16, 32))
    new_img.paste(right_leg, (16, 48))

    # Mirror x-axis for specific portions of the right leg
    right_leg_top = img.crop((4, 16, 8, 20)).transpose(Image.FLIP_LEFT_RIGHT)
    new_img.paste(right_leg_top, (20, 48))
    right_leg_bottom = img.crop((0, 20, 12, 32)).transpose(Image.FLIP_LEFT_RIGHT)
    new_img.paste(right_leg_bottom, (16, 52))

    new_img.save(image_path)
    print(f"Converted {image_path} to 64x64 format.")

def main(folder_path):
    for root, _, files in os.walk(folder_path):
        for filename in files:
            if filename.endswith(".png"):
                convert_skin(os.path.join(root, filename))

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <folder_path>")
        sys.exit(1)
    main(sys.argv[1])



