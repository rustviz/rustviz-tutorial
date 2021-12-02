#!/bin/bash
red=$'\e[1;31m'
end=$'\e[0m'

# Write the first line of SUMMARY.md. This clears anything that was there previously
# printf "# Summary\n\n" > src/SUMMARY.md

printf "Generating visualizations for the following examples: \n"

# Uncomment the examples are being tested
declare -a targetExamples=(
    # "copy"
    # "func_take_ownership"
    # "func_take_return_ownership"
    # "function"
    # "hatra1"
    # "hatra1_test"
    # "hatra2"
    # "immutable_borrow"
    # "immutable_borrow_method_call"
    # "immutable_variable"
    # "move_assignment"
    # "move_different_scope"
    # "move_func_return"
    # "multiple_immutable_borrow"
    # "mutable_borrow"
    # "mutable_borrow_method_call"
    # "mutable_variables"
    # "nll_lexical_scope_different"
    # "printing"
    # "string_from_move_print"
    # "string_from_print"
    # "struct_lifetime"
    # "struct_rect"
    # "struct_rect2"
    # "struct_string"
    # "extra_credit"
    "thread_vec"
    "thread_vec2"
)

LOCALEX="src/assets/code_examples"
EX="../rustviz/src/examples"
# Loop through the specified examples
for target in ${targetExamples[@]}; do
    printf "building %s...\n" $target
    
    if ! [[ -d "$EX/$target" ]]
    then
        mkdir $EX/$target
    fi
    cp "$LOCALEX/$target/source.rs" "$EX/$target/source.rs"

    # Check if required files are there
    if [[ -f "$EX/$target/source.rs" ]]
    then
        # Check if file headers exist
        if ! [[ -f "$EX/$target/main.rs" ]]
        then
            printf "\ngenerating header for %s..." $target
            cd "../rustviz/src/RustvizParse"
            cargo run "../examples/$target/source.rs" >/dev/null 2>&1
            cd "../../../rustviz-tutorial"
            cp "$EX/$target/main.rs" "$LOCALEX/$target/main.rs"
            printf "\nPlease define events and rerun current script\n"
            continue
        fi
        cp "$LOCALEX/$target/main.rs" "$EX/$target/main.rs"
        cd "../rustviz/src/" # switch to appropriate folder
        # Run svg generation for example
        cargo run $target >/dev/null 2>&1

        # If the svg generation exited with an error or the required SVGs weren't created, report failure and continue
        if [[ $? -ne 0 || !(-f "examples/$target/vis_code.svg") || !(-f "examples/$target/vis_timeline.svg") ]]; then
            printf "${red}FAILED${end} on SVG generation.\n"
            cd ../../rustviz-tutorial
            continue
        fi
        cd ../../rustviz-tutorial
        
        # Copy files to mdbook directory
        mkdir -p "./src/assets/code_examples/$target"
        cp "$EX/$target/vis_code.svg" "./src/assets/code_examples/$target/vis_code.svg"
        cp "$EX/$target/vis_timeline.svg" "./src/assets/code_examples/$target/vis_timeline.svg"
        
    else
        # Not Necessary (file double check)
        printf "${red}FAILED${end}. The required files are not in the examples dir.\n"
    fi
done

# Build mdbook
mdbook build

# Run HTTP server on docs directory
cd book
python3 -m http.server 8000