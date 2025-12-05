#!/usr/bin/env python3
"""
Script to generate adaptive app icons for SmartToolkit (Android API 26+)
Creates separate foreground and background layers
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_adaptive_background(size, output_path):
    """Create adaptive icon background (solid blue)"""
    img = Image.new('RGB', (size, size), '#1976D2')  # Material Blue
    img.save(output_path, 'PNG', quality=95)
    print(f"Created adaptive background: {output_path} ({size}x{size})")

def create_adaptive_foreground(size, output_path):
    """Create adaptive icon foreground (tools logo on transparent)"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))  # Transparent background
    draw = ImageDraw.Draw(img)
    
    # Create logo within safe zone (72dp out of 108dp)
    safe_zone = int(size * 0.67)  # 72/108 = 0.67
    offset = (size - safe_zone) // 2
    
    center_x, center_y = size // 2, size // 2
    
    # Create gear icon in center (adaptive safe zone)
    gear_radius = int(safe_zone * 0.25)
    inner_radius = int(safe_zone * 0.15)
    tooth_height = int(safe_zone * 0.05)
    num_teeth = 8
    
    # Draw gear teeth
    import math
    for i in range(num_teeth):
        angle = (2 * math.pi * i) / num_teeth
        
        # Outer tooth points
        outer_x1 = center_x + int((gear_radius + tooth_height) * math.cos(angle - 0.2))
        outer_y1 = center_y + int((gear_radius + tooth_height) * math.sin(angle - 0.2))
        outer_x2 = center_x + int((gear_radius + tooth_height) * math.cos(angle + 0.2))
        outer_y2 = center_y + int((gear_radius + tooth_height) * math.sin(angle + 0.2))
        
        # Inner base points
        inner_x1 = center_x + int(gear_radius * math.cos(angle - 0.3))
        inner_y1 = center_y + int(gear_radius * math.sin(angle - 0.3))
        inner_x2 = center_x + int(gear_radius * math.cos(angle + 0.3))
        inner_y2 = center_y + int(gear_radius * math.sin(angle + 0.3))
        
        # Draw tooth as polygon
        draw.polygon([
            (inner_x1, inner_y1),
            (outer_x1, outer_y1),
            (outer_x2, outer_y2),
            (inner_x2, inner_y2)
        ], fill='white')
    
    # Draw main gear circle
    draw.ellipse([
        center_x - gear_radius, center_y - gear_radius,
        center_x + gear_radius, center_y + gear_radius
    ], fill='white')
    
    # Draw inner hole (transparent for adaptive)
    draw.ellipse([
        center_x - inner_radius, center_y - inner_radius,
        center_x + inner_radius, center_y + inner_radius
    ], fill=(0, 0, 0, 0))
    
    # Add small center dot
    center_dot = int(safe_zone * 0.025)
    draw.ellipse([
        center_x - center_dot, center_y - center_dot,
        center_x + center_dot, center_y + center_dot
    ], fill='white')
    
    # Gear logo complete
    
    img.save(output_path, 'PNG', quality=95)
    print(f"Created adaptive foreground: {output_path} ({size}x{size})")

def main():
    """Generate adaptive icons for all densities"""
    base_path = "/Users/macos/Downloads/Application/smarttoolkit/android/app/src/main/res"
    
    # Adaptive icon sizes (108dp for different densities)
    sizes = {
        'mipmap-mdpi': 108,
        'mipmap-hdpi': 162,
        'mipmap-xhdpi': 216,
        'mipmap-xxhdpi': 324,
        'mipmap-xxxhdpi': 432
    }
    
    for folder, size in sizes.items():
        folder_path = os.path.join(base_path, folder)
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
        
        # Create background and foreground
        bg_path = os.path.join(folder_path, 'ic_launcher_background.png')
        fg_path = os.path.join(folder_path, 'ic_launcher_foreground.png')
        
        create_adaptive_background(size, bg_path)
        create_adaptive_foreground(size, fg_path)
    
    print("\n✅ All adaptive app icons created successfully!")
    print("Adaptive icons include:")
    print("- Separate background and foreground layers")
    print("- Compatible with Android 8.0+ (API 26+)")
    print("- Follows adaptive icon guidelines")
    print("- Safe zone compliance for text placement")

if __name__ == "__main__":
    main()