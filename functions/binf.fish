function binf
    # Function: binf
    set -l binf_version "Version 1.0.0"
    # Define required commands
    set -l binf_required_cmds jq
    # Author Laurent Taupiac
    # Purpose: display the last changlog of a brew formula

    set -x verbose 0
    set -l commande ""

    # Using argparse to handle arguments
    # --stop-nonopt stops parsing at the first non-option argument
    # v/verbose, d/debug, h/help define short and long options
    argparse --stop-nonopt v/version t/trace h/help d/debug -- $argv
    or begin
        # If argparse fails (unknown option or other error), show help and exit
        echo "Error parsing arguments."
        echo "Use brewclog --help for more information."
        set -e fish_trace fish_log
        return 1
    end

    if set -q _flag_debug
        set -x fish_trace 1
        set -U fish_log 3
    end

        # If --version / -v is set, display version
    if set -q _flag_version
        echo $binf_version
        set -e fish_trace fish_log
        return 0
    end

    # If --help / -h is set, display help
    if set -q _flag_help
        echo "Usage: binf [options] <formula>"
        echo $binf_version
        echo "Purpose: display the description, homepage URL, and the version of a brew formula."
        echo
        echo "Options:"
        echo "  -t, --trace   : Verbose mode"
        echo "  -d, --debug   : Show debugging information"
        echo "  -h, --help    : Show this help message"
        echo "  -v, --version : Show version"
        return 0
    end

    # Check if trace mode is enabled
    if set -q _flag_trace
        echo "Verbose mode"
        set -x verbose 1
    end

    # After argparse, $argv contains only non-option arguments
    if test (count $argv) -ne 1
        echo "Error: no formula specified."
        echo "Use binf --help for more information."
        set -e fish_trace fish_log
        return 1
    end
    # The first non-option argument is the formula name
    set -l commande $argv[1]

    # Check and install required commands
    check_and_install_cmds $binf_required_cmds

    # get json informations
    set -l json_data (brew info --json=v2 "$commande")

    # Check the result of the function
    if test -z "$json_data"
        trace "Failed to retrieve json data  for formula: <$commande>"
        set -e fish_trace fish_log
        return 1
    end

    # Filter informations
    set -l infos (echo "$json_data" | jq '
        .casks[]? // .formulae[]? |
        if .tap == "homebrew/cask" then
            {description: .desc, "homepage   ": .homepage, "version    ": .version, "installed  ": (.installed // "not installed")}
        else
            {description: .desc, "homepage   ": .homepage, "version    ": .versions.stable, "installed  ": (.installed[0]?.version // "not installed")}
        end
    ')

    # Check filtered infos
    if test -z "$infos"
        trace "Error while filtering data in json"
        set -e fish_trace fish_log
        return 1
    end

    # Display data informations
    parse_and_display_json "$infos"

    # clear trace or debug mode
    set -e fish_trace fish_log
end

function trace
    if test "$verbose" = "1"
        echo (set_color green)"Trace: $argv[1]"(set_color normal) >&2
    end
end

function show
      echo $argv[1] >&2
end

function check_and_install_cmds
    # Required commands
    set -l required_cmds $argv
    trace "check_and_install_cmds [$required_cmds]"

    # Initialize a variable to hold missing commands
    set -l missing_cmds

    # Loop through the required commands
    for c in $required_cmds
        if not type -q $c
            # Append missing command to the list
            set missing_cmds $missing_cmds $c
        end
    end

    # Check if there are any missing commands
    if test -n "$missing_cmds"
        echo "The following commands are missing: $missing_cmds"
        # Prompt to install missing commands
        echo
        echo "Would you like to install them now? (y/n)"
        read -l choice

        if test "$choice" = "y"
            echo "Installing missing commands with Homebrew..."
            brew install $missing_cmds
            if test $status -ne 0
                echo "Error: Failed to install one or more commands."
                set -e fish_trace fish_log
                return 1
            else
                echo "All missing commands installed successfully!"
            end
        else
            echo "Please install the missing commands manually. (brew install $missing_cmds)"
            set -e fish_trace fish_log
            return 1
        end
    end
end

function parse_and_display_json
    # Prendre en paramètre la chaîne JSON
    set -l json_data $argv[1]
    trace "parse_and_display_json with [$json_data]"

    # Parcourir chaque clé-valeur de l'objet JSON
    for key in (echo $json_data | jq -r 'keys[]')
        set value (echo $json_data | jq -r ".\"$key\"")
        # Afficher avec couleurs directement
        echo -e (set_color blue)$key(set_color normal)(set_color white): (set_color green)$value(set_color normal)
    end
end
