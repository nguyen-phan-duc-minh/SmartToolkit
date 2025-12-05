#!/usr/bin/env python3
"""
Create high-resolution 512x512 app icon for Google Play Console
"""

from PIL import Image, ImageDraw
import math

def create_play_store_icon():
    """Create 512x512 icon for Google Play Console"""
    size = 512
    
    # Create image with blue background
    img = Image.new('RGB', (size, size), '#1976D2')  # Material Blue
    draw = ImageDraw.Draw(img)
    
    # Create gear icon in center
    center_x, center_y = size // 2, size // 2
    
    # Gear dimensions
    gear_radius = int(size * 0.2)
    inner_radius = int(size * 0.12)
    tooth_height = int(size * 0.04)
    num_teeth = 8
    
    # Draw gear teeth
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
    
    # Draw inner hole
    draw.ellipse([
        center_x - inner_radius, center_y - inner_radius,
        center_x + inner_radius, center_y + inner_radius
    ], fill='#1976D2')
    
    # Add small center dot
    center_dot = int(size * 0.02)
    draw.ellipse([
        center_x - center_dot, center_y - center_dot,
        center_x + center_dot, center_y + center_dot
    ], fill='white')
    
    # Save high-quality PNG
    output_path = 'play_store_icon_512.png'
    img.save(output_path, 'PNG', quality=100, optimize=False)
    print(f"✅ Created Google Play Store icon: {output_path} (512x512)")
    
    return output_path

if __name__ == "__main__":
    create_play_store_icon()