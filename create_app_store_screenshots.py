from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os
import textwrap

# App Store 6.7" size
CANVAS_WIDTH = 1290
CANVAS_HEIGHT = 2796

# Device dimensions
DEVICE_WIDTH = 1170
DEVICE_HEIGHT = 2532
DEVICE_X = (CANVAS_WIDTH - DEVICE_WIDTH) // 2
DEVICE_Y = CANVAS_HEIGHT - DEVICE_HEIGHT - 100

RADIUS_OUTER = 120
RADIUS_INNER = 105
BORDER_WIDTH = 30

def create_rounded_rect(width, height, radius, color, border_width=0, border_color="black"):
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    if border_width > 0:
        draw.rounded_rectangle((0, 0, width-1, height-1), radius, fill=color, outline=border_color, width=border_width)
    else:
        draw.rounded_rectangle((0, 0, width-1, height-1), radius, fill=color)
    return img

def mask_image_rounded(image, radius):
    mask = Image.new('L', image.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle((0, 0, image.size[0], image.size[1]), radius, fill=255)
    image.putalpha(mask)
    return image

def draw_dynamic_island(draw, offset_x, offset_y):
    # Dynamic island capsule
    di_width = 330
    di_height = 95
    di_x = offset_x + (DEVICE_WIDTH - di_width) // 2
    di_y = offset_y + 35
    draw.rounded_rectangle([di_x, di_y, di_x + di_width, di_y + di_height], radius=47, fill="black")

def generate_promotional_image(screenshot_path, output_path, title_text):
    # 1. Background (Gradient)
    base = Image.new('RGBA', (CANVAS_WIDTH, CANVAS_HEIGHT), (250, 250, 250, 255))
    draw = ImageDraw.Draw(base)
    # Draw simple gradient
    for y in range(CANVAS_HEIGHT):
        r = int(245 - (y / CANVAS_HEIGHT) * 15)
        g = int(247 - (y / CANVAS_HEIGHT) * 10)
        b = int(255 - (y / CANVAS_HEIGHT) * 5)
        draw.line([(0, y), (CANVAS_WIDTH, y)], fill=(r, g, b, 255))

    # 2. Add text
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 100)
    except:
        font = ImageFont.load_default()
    
    # Simple text wrapping and centering
    # Using roughly estimated character width
    lines = textwrap.wrap(title_text, width=22)
    text_y = 250
    for line in lines:
        left, top, right, bottom = draw.textbbox((0, 0), line, font=font)
        text_w = right - left
        draw.text(((CANVAS_WIDTH - text_w) // 2, text_y), line, font=font, fill=(30, 41, 59, 255))
        text_y += 130
        
    # 3. Process Screenshot
    try:
        screenshot = Image.open(screenshot_path).convert('RGBA')
    except Exception as e:
        print(f"Skipping {screenshot_path}, could not load: {e}")
        return

    screenshot = screenshot.resize((DEVICE_WIDTH - BORDER_WIDTH*2, DEVICE_HEIGHT - BORDER_WIDTH*2), Image.Resampling.LANCZOS)
    screenshot = mask_image_rounded(screenshot, RADIUS_INNER)

    # 4. Device Frame
    device_frame = create_rounded_rect(DEVICE_WIDTH, DEVICE_HEIGHT, RADIUS_OUTER, color=(0,0,0,0), border_width=BORDER_WIDTH, border_color="#1E293B")
    
    # Add shadow
    shadow = create_rounded_rect(DEVICE_WIDTH, DEVICE_HEIGHT, RADIUS_OUTER, color=(0,0,0,40))
    # Apply blur to shadow (simplified)
    # Not using actual gaussian blur on the whole canvas for perf, just simple offset
    base.paste(shadow, (DEVICE_X + 25, DEVICE_Y + 25), shadow)
    
    # 5. Composite
    # Paste screenshot
    base.paste(screenshot, (DEVICE_X + BORDER_WIDTH, DEVICE_Y + BORDER_WIDTH), screenshot)
    # Paste frame
    base.paste(device_frame, (DEVICE_X, DEVICE_Y), device_frame)
    # Draw dynamic island
    draw_dynamic_island(ImageDraw.Draw(base), DEVICE_X, DEVICE_Y)

    # Finally convert to RGB and save
    base = base.convert('RGB')
    base.save(output_path, quality=95)
    print(f"Generated {output_path}")

def main():
    input_dir = "app_store_screenshots/raw"
    output_dir = "app_store_screenshots/output"
    
    if not os.path.exists(input_dir):
        os.makedirs(input_dir)
        print(f"Created {input_dir}. Please put your raw screenshots there, then run this script again.")
        return
        
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    files = [f for f in os.listdir(input_dir) if f.lower().endswith(('.png', '.jpg', '.jpeg'))]
    if not files:
        print(f"No images found in {input_dir}. Please place your screenshots there and run again.")
        return

    # Basic titles based on index or name, modify as needed
    titles = [
        "Manage Requests",
        "View Approvals",
        "Submit Leave",
        "Track Budget",
        "Streamline Workflow"
    ]

    for i, file in enumerate(files):
        title = titles[i % len(titles)]
        input_path = os.path.join(input_dir, file)
        output_path = os.path.join(output_dir, f"promo_{file}")
        generate_promotional_image(input_path, output_path, title)

if __name__ == "__main__":
    main()
