#!/bin/sh

# Strip simulator architectures from embedded frameworks
# This script removes x86_64 and i386 slices from frameworks to fix App Store validation errors

echo "Stripping simulator architectures from frameworks..."

FRAMEWORKS_DIR="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Frameworks"

if [ -d "$FRAMEWORKS_DIR" ]; then
    for FRAMEWORK in "$FRAMEWORKS_DIR"/*.framework; do
        if [ -d "$FRAMEWORK" ]; then
            FRAMEWORK_NAME=$(basename "$FRAMEWORK" .framework)
            FRAMEWORK_EXECUTABLE="$FRAMEWORK/$FRAMEWORK_NAME"
            
            if [ -f "$FRAMEWORK_EXECUTABLE" ]; then
                # Check if the framework has multiple architectures
                ARCHS=$(lipo -info "$FRAMEWORK_EXECUTABLE" 2>/dev/null)
                
                if echo "$ARCHS" | grep -q "x86_64\|i386"; then
                    echo "Processing $FRAMEWORK_NAME..."
                    
                    # Get current architectures
                    CURRENT_ARCHS=$(lipo -info "$FRAMEWORK_EXECUTABLE" | sed 's/^.*: //')
                    
                    # Create a temporary file
                    TMP_FILE="${FRAMEWORK_EXECUTABLE}.tmp"
                    
                    # Extract only arm64 architecture
                    if echo "$CURRENT_ARCHS" | grep -q "arm64"; then
                        lipo -thin arm64 -output "$TMP_FILE" "$FRAMEWORK_EXECUTABLE" 2>/dev/null
                        if [ $? -eq 0 ]; then
                            mv "$TMP_FILE" "$FRAMEWORK_EXECUTABLE"
                            echo "  Stripped x86_64/i386 from $FRAMEWORK_NAME"
                        else
                            rm -f "$TMP_FILE"
                            echo "  Warning: Could not strip $FRAMEWORK_NAME, leaving as-is"
                        fi
                    fi
                fi
            fi
        fi
    done
else
    echo "Frameworks directory not found: $FRAMEWORKS_DIR"
fi

echo "Done stripping simulator architectures."
