#!/bin/bash

# This is a convenience script to copy the code examples and corresponding SVG
# visualizations from the rustviz repository. See README.md for more details.

for DIR in ../rustviz/dsl/examples_dsl/*/; do
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

# # Copy new files to modified_examples
# DSL='../rustviz/dsl/examples_dsl'
# for DIR in ./src/assets/modified_examples/*; do
#     BASENAME=`basename $DIR`
#     if [[ -f  "$DSL/$BASENAME/source.rs" && -f "$DSL/$BASENAME/vis_code.svg" && -f "$DSL/$BASENAME/vis_timeline.svg" ]]
#     then
#         cp "$DSL/$BASENAME/source.rs" "$DIR/source.rs" && \
#         cp "$DSL/$BASENAME/vis_code.svg" "$DIR/vis_code.svg" && \
#         cp "$DSL/$BASENAME/vis_timeline.svg" "$DIR/vis_timeline.svg"
        
#         echo "Successfully copied $BASENAME."
#     else
#         echo "$BASENAME does not have the required files, skipping."
#     fi
# done
