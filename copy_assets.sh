#!/bin/bash

# This is a convenience script to copy the code examples and corresponding SVG
# visualizations from the rustviz repository. See README.md for more details.

for DIR in ../rustviz/svg_generator/examples/*/; do
    BASENAME=`basename $DIR`
    if [[ -f  "$DIR/source.rs" && -f "$DIR/vis_code.svg" && -f "$DIR/vis_timeline.svg" ]]
    then
        mkdir -p "./src/assets/code_examples/$BASENAME" && \
            cp "$DIR/source.rs" "./src/assets/code_examples/$BASENAME/source.rs" && \
            cp "$DIR/vis_code.svg" "./src/assets/code_examples/$BASENAME/vis_code.svg" && \
            cp "$DIR/vis_timeline.svg" "./src/assets/code_examples/$BASENAME/vis_timeline.svg"
        
        echo "Successfully copied $BASENAME."
    else
        echo "$BASENAME does not have the required files, skipping."
    fi
done