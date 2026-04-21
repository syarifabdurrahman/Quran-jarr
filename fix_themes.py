import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # We want to replace instances of AppTextStyles.lora...() 
    # and AppTextStyles.amiri...() with their ForTheme(context) equivalents,
    # UNLESS they are inside app_text_styles.dart or theme_config.dart
    
    if "app_text_styles.dart" in filepath or "theme_config.dart" in filepath:
        return

    # Patterns to match AppTextStyles.stylename(optional_args)
    # Examples:
    # AppTextStyles.loraBodySmall()
    # AppTextStyles.loraBodyMedium(multiplier)
    # AppTextStyles.amiriVerseLarge()
    
    # Regex break down:
    # AppTextStyles\.(lora[A-Za-z]+|amiri[A-Za-z]+|surahName)(?<!ForTheme)\s*\(([^)]*)\)
    # This matches AppTextStyles.loraBodySmall( args )
    
    pattern = r'AppTextStyles\.(lora[A-Za-z]+|amiri[A-Za-z]+|surahName|buttonText)(?<!ForTheme)\s*\(([^)]*)\)'
    
    def replacer(match):
        method_name = match.group(1)
        args_str = match.group(2).strip()
        
        # Build new args
        if args_str:
            new_args = f"context, {args_str}"
        else:
            new_args = "context"
            
        return f"AppTextStyles.{method_name}ForTheme({new_args})"

    new_content = re.sub(pattern, replacer, content)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
