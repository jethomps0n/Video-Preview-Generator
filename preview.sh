#!/bin/bash
# For macOS, please make sure you have downloaded Homebrew (https://brew.sh/) and have installed ffmpeg via the lines below:
# brew tap homebrew-ffmpeg/ffmpeg
# brew install homebrew-ffmpeg/ffmpeg/ffmpeg --with-fdk-aac --with-opencore-amr --with-openh264 --with-openjpeg --with-speex

# --------------------------------------------------------- #
# | Video Preview Generator                               | #
# | Version: 1.0.1                                        | #
# | https://github.com/jethomps0n/Video-Preview-Generator | #
# --------------------------------------------------------- #

#--------DEFAULT INTERACTION VALUES--------#
single="1" # ------- | Input to select a 'Generation Type' of 'single'.
batch="2" # -------- | Input to select a 'Generation Type' of 'batch'.
quit="q" # --------- | Input to exit the program.
back="b" # --------- | Input to return to the previous step in the process.
continue="c" # ----- | Input to continue to the next step in the process.
settings="s" # ----- | Input to enter 'Settings'.
advancedtoggle="a" # | Input to toggle 'Advanced Mode'.
isadvanced=false # - | Value to check if 'Advanced Mode' is active.
currentval="d" # --- | Input to keep the current 'Settings' element.

#--------DEFAULT INPUT VALUES--------#
# | IMPORTANT: To insert a drive letter, use semicolon format as modeled below.
# | Ex. C:/folder1/folder2/...
inputfolderpath="./" # ------- | The folder path where the input file is located.
outputfolderpath="./" # ------ | The folder path where the output file/folder will go.
outputfoldername="previews/" # | Creates a subfolder within the output folder path
                             # | where the generated previews will go.
startseconds=20 # ------------ | The amount of seconds trimmed from the beginning of the input file.
endseconds="sixth" # --------- | The amount of seconds trimmed from the end of the input file.
numminiclips=5 # ------------- | The number of mini-clips to be created from the given parameters of
                             # | the input file.
minicliplength=2 # ----------- | The length in seconds to be had in each mini-clip.

#--------DEFAULT ENCONDER INPUT VALUES--------#
CRF=23 # -------------- | ffmpeg '-crf' value for encoding the output file. Modifies the constant quality.
Bit="5M" # ------------ | ffmpeg '-b:v' value for encoding the output file. Modifies the bitrate.
Pre="fast" # ---------- | ffmpeg '-preset' value for encoding the output file. Modifies the comrpression speed.
audiotoggle="off" # --- | Value to check if audio will be included in the output file.
resolution="useinput" # | ffmpeg 'filter:v scale' value for encoding the output file (preserves aspect ratio).

#---------CONSTANT VARIABLES (Probably Shouldn't Change)--------#
re="^[0-9]+([.][0-9]+)?$" # ------------------ | A regular expression to find any character that is not a digit.
minlength=$(($minicliplength*$numminiclips)) # | The minimum length in seconds a given input file (after
                                             # | parameters are applied) must be to generate a preview.
tempdir=miniclips # -------------------------- | The name of the temporary folder directory where the miniclips
                                             # | are stored.
listfile=miniclipslist.txt # ----------------- | The name of the temporary text file where the miniclips are
                                             # | referenced.
dimensions=0 # ------------------------------- | The ffmpeg 'filter:v scale' value for encoding the output file,
                                             # | referenced from '$resolution'.
p="p" # -------------------------------------- | Visual identifier for 'pixels'.
M="M" # -------------------------------------- | Identifier for 'megapixels'.
Audio="-an" # -------------------------------- | ffmpeg '-an' value for encoding the output file. Modifies the
                                             # | inclusion of audio.

#---------EARLY VALIDATIONS--------#
if [ ! -d "$inputfolderpath" ]; then
    inputfolderpath="./"
elif [ ! "${inputfolderpath: -1}" == "/" ]; then
    inputfolderpath="$inputfolderpath/"
fi

if [ ! -d "$outputfolderpath" ]; then
    outputfolderpath="./"
elif [ ! "${outputfolderpath: -1}" == "/" ]; then
    outputfolderpath="$outputfolderpath/"
fi

if [ "${audiotoggle,,}" == "on" ]; then
    Audio=""
else
    audiotoggle="off"
    Audio="-an"
fi

if [ "${resolution: -1}" == "p" ]; then
    resolution="${resolution%$p}"
    if [[ $resolution =~ $re ]]; then
        if [ $resolution = 0 ]; then
            resolution="useinput"
            dimensions=0
        else
            dimensions=$resolution
        fi
    fi
elif [[ $resolution =~ $re ]]; then
    if [ $resolution = 0 ]; then
        resolution="useinput"
        dimensions=0
    else
        dimensions=$resolution
    fi
elif [ "$resolution" == "useinput" ]; then
    dimensions=0
else
    resolution="useinput"
    dimensions=0
fi

function modify_encoder_settings() {
    clear

    echo ""
    if [ "$generationtype" == "$single" ]; then
        echo "[Single Generation - FINAL PARAMETERS]"
    elif [ "$generationtype" == "$batch" ]; then
        echo "[Batch Generation - FINAL PARAMETERS]"
    fi

    echo ""
    echo ""
    echo "Current Encoder Settings - STATUS: MODIFYING"
    echo "----------------------------------------------"
    echo "CRF value:       $CRF"
    echo "Bitrate in mbps: $Bit"
    echo "Preset type:     $Pre"
    if [[ $resolution =~ $re ]]; then
        echo "Resolution:      $resolution$p"
    else
        echo "Resolution:      $resolution"
    fi
    echo "Audio Toggle:    $audiotoggle"
    echo ""
    echo "Keywords                        Description"
    echo "----------                      -------------"
    echo "'ultrafast', 'superfast'        Words for preset that provide a"
    echo "'veryfast', 'faster',           certain encoding speed to compression"
    echo "'fast', 'medium', 'slow',       ratio for the output file"
    echo "'slower', 'veryslow'"
    echo "                                Words for resolution that"
    echo "'useinput'                      define the width dimensions"
    echo "                                of the output file"
    echo ""
    echo "Actions"
    echo "---------"
    echo "[$back]Back                         Return to the previous page without saving"
    echo "[$quit]Quit                         Quit"
    echo ""
    echo ""

    CRFpre=$CRF
    Bitpre=$Bit
    Prepre=$Pre
    Respre=$resolution
    dimensionpre=$dimensions

    echo '(Type "d" to keep current value)'
    echo -n "Insert new CRF value (0–51): "; read newCRF

    if [ "$newCRF" == "$currentval" ]; then
        CRF=$CRF
    elif [[ $newCRF =~ $re ]]; then
        CRF=$newCRF
    elif [ "$newCRF" == "$back" ]; then
        if [ "$generationtype" == "$single" ]; then
            generate_single
        elif [ "$generationtype" == "$batch" ]; then
            generate_batch
        fi
    elif [ "$newCRF" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    else
        echo ""
        echo ""
        echo "Invalid number. Quitting..."
        exit
    fi

    echo -n "Insert new bitrate value: "; read newBit

    if [ "$newBit" == "$currentval" ]; then
        Bit=$Bit
    elif [ "${newBit: -1}" == "M" ]; then
        newBit="${newBit%$M}"
        if [[ $newBit =~ $re ]]; then
            if [ $newBit = 0 ]; then
                echo ""
                echo ""
                echo "Invalid number inputted. Quitting..."
                exit
            fi
            Bit=$newBit$M
        fi
    elif [[ $newBit =~ $re ]]; then
        if [ $newBit = 0 ]; then
            echo ""
            echo ""
            echo "Invalid number inputted. Quitting..."
            exit
        fi
        Bit=$newBit$M
    elif [ "$newBit" == "$back" ]; then
        CRF=$CRFpre
        if [ "$generationtype" == "$single" ]; then
            generate_single
        elif [ "$generationtype" == "$batch" ]; then
            generate_batch
        fi
    elif [ "$newBit" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    else
        echo ""
        echo ""
        echo "Invalid number. Quitting..."
        exit
    fi

    echo -n "Insert new preset value (Keywords available): "; read newPre

    if [ "$newPre" == "$currentval" ]; then
        Pre=$Pre
    elif [[ "$newPre" == "ultrafast" || "$newPre" == "superfast" || "$newPre" == "veryfast" || "$newPre" == "faster" || "$newPre" == "fast" || "$newPre" == "medium" || "$newPre" == "slow" || "$newPre" == "slower" || "$newPre" == "veryslow" || "$newPre" == "placebo" ]]; then
        Pre=$newPre
    elif [ "$newPre" == "$back" ]; then
        CRF=$CRFpre
        Bit=$Bitpre
        if [ "$generationtype" == "$single" ]; then
            generate_single
        elif [ "$generationtype" == "$batch" ]; then
            generate_batch
        fi
    elif [ "$newPre" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    else
        echo ""
        echo ""
        echo "Invalid value. Quitting..."
        exit
    fi

    echo -n "Insert new resolution (Ex. 720p | Keywords availiable): "; read newresolution

    if [ "$newresolution" == "$currentval" ]; then
        resolution=$resolution
    elif [ "${newresolution: -1}" == "p" ]; then
        newresolution="${newresolution%$p}"
        if [[ $newresolution =~ $re ]]; then
            if [ $newresolution = 0 ]; then
                echo ""
                echo ""
                echo "Invalid number inputted. Quitting..."
                exit
            fi
            dimensions=$newresolution
            resolution=$newresolution
        fi
    elif [[ $newresolution =~ $re ]]; then
        if [ $newresolution = 0 ]; then
            echo ""
            echo ""
            echo "Invalid number inputted. Quitting..."
            exit
        fi
        dimensions=$newresolution
        resolution=$newresolution
    elif [ "$newresolution" == "useinput" ]; then
        dimensions=0;
    elif [ "$newresolution" == "$back" ]; then
        CRF=$CRFpre
        Bit=$Bitpre
        Pre=$Prepre
        if [ "$generationtype" == "$single" ]; then
            generate_single
        elif [ "$generationtype" == "$batch" ]; then
            generate_batch
        fi
    elif [ "$newresolution" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    else
        echo ""
        echo ""
        echo "Invalid number. Quitting..."
        exit
    fi

    echo -n "Toggle audio inclusion (on/off): "; read newaudiotoggle

    if [ "$newaudiotoggle" == "$currentval" ]; then
        audiotoggle=$audiotoggle
    elif [ "${newaudiotoggle,,}" == "on" ]; then
        audiotoggle=$newaudiotoggle
        Audio=""
    elif [ "${newaudiotoggle,,}" == "off" ]; then
        audiotoggle=$newaudiotoggle
        Audio="-an"
    elif [ "$newaudiotoggle" == "$back" ]; then
        CRF=$CRFpre
        Bit=$Bitpre
        Pre=$Prepre
        resolution=$Respre
        dimensions=$dimensionpre
        if [ "$generationtype" == "$single" ]; then
            generate_single
        elif [ "$generationtype" == "$batch" ]; then
            generate_batch
        fi
    elif [ "$newaudiotoggle" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    else
        echo ""
        echo ""
        echo "Invalid value. Quitting..."
        exit
    fi

    if [ "$generationtype" == "$single" ]; then
        generate_single
    elif [ "$generationtype" == "$batch" ]; then
        generate_batch
    fi
}

function generate_single() {
    clear

    echo ""
    echo "[Single Generation - FINAL PARAMETERS]"
    echo ""
    echo ""
    echo "Current Encoder Settings"
    echo "--------------------------"
    echo "CRF value:       $CRF"
    echo "Bitrate in mbps: $Bit"
    echo "Preset type:     $Pre"
    if [[ $resolution =~ $re ]]; then
        echo "Resolution:      $resolution$p"
    else
        echo "Resolution:      $resolution"
    fi
    echo "Audio Toggle:    $audiotoggle"
    echo ""
    echo "Actions                         Description"
    echo "---------                       -------------"
    echo "[$back]Back                         Return to the previous page"
    echo "[$settings]Settings                     Access settings"
    echo "[$quit]Quit                         Quit"
    echo ""
    echo "-------------------------------------------------------------------"
    echo "Please enter the input and output parameters to begin the process"
    echo "[] = REQUIRED    {} = *NOT REQUIRED           *Defaults to preset"
    echo "                                             values if left blank"
    echo "Format:"
    echo "[inputfile] {outputfile}   -OR-  [inputfile] {outputextension}"
    echo "Ex. input.mp4 output.webm  -OR-  input.mp4 .webm"
    echo "-------------------------------------------------------------------"
    echo ""
    echo ""

    echo -n "[Input]: "; read sourcefile

    if [ "$sourcefile" == "$settings" ]; then
        modify_encoder_settings
    elif [ "$sourcefile" == "$back" ]; then
        setup
    elif [ "$sourcefile" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    elif [ ! -e "$inputfolderpath$sourcefile" ]; then
        echo ""
        echo ""
        echo "Invalid input selector. Quitting..."
        exit
    fi

    echo -n "{Output}: "; read outputname

    if [ "$outputname" == "$settings" ]; then
        modify_encoder_settings
    elif [ "$outputname" == "$back" ]; then
        setup
    elif [ "$outputname" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    fi

    sourceex=${sourcefile#*.}
    extension=""

    defaultname="${sourcefile%.$sourceex}-preview" # | Default output file name
    defaultex=$sourceex                            # | Default output extension type

    sourcefile="$inputfolderpath$sourcefile"

    if [ -z "$outputname" ]; then
        outputname=$defaultname
    elif [ "${outputname:0:1}" == "." ]; then
        extension=$outputname
        outputname=$defaultname
    elif [[ $outputname =~ "." ]]; then
        extension=${outputname#*.}
        outputname="${outputname%.$extension}"
    fi

    if [ -z "$extension" ]; then
        extension=$defaultex
    elif [ "${extension:0:1}" == "." ]; then
        extension=${extension#*.}
    fi

    length=$(ffprobe "$sourcefile"  -show_format 2>&1 | sed -n 's/duration=//p' | awk '{print int($0)}' |cut -d\. -f1)

    half=$((length/2))   # | Half of the video length in seconds
    third=$((length/3))  # | A third of the video length in seconds
    fourth=$((length/4)) # | A fourth of the video length in seconds
    fifth=$((length/5))  # | A fifth of the video length in seconds
    sixth=$((length/6))  # | A sixth of the video length in seconds

    echo ""
    echo 'Video length: ' $length 'seconds'
    length=$(($length - $endseconds ))
    length=$(($length-$startseconds))
    echo 'Video length with trimmed seconds: ' $length 'seconds'
    echo ""
    
    if [ "$length" -lt "$minlength" ]; then
        echo ""
        echo 'Video is too short.  Quitting...'
        exit
    fi
    
    mkdir "$outputfolderpath$tempdir"

    interval=$(($length/$numminiclips))

    for i in $(seq 1 $numminiclips); do
        # Format the second marks into hh:mm:ss format
        start=$(($(($(($i-1))*$interval))+$startseconds))
        formattedstart=$(printf "%02d:%02d:%02d\n" $(($start/3600)) $(($start%3600/60)) $(($start%60)))
        echo 'Generating preview part ' $i $formattedstart
        # Generate the snippet at calculated time
        if [ "$extension" == "webm" ]; then
            ffmpeg -loglevel quiet -ss $formattedstart -i "$sourcefile" -c:v libvpx -crf $CRF -b:v $Bit -filter:v scale=$dimensions:-2 -c:a libvorbis -preset $Pre $Audio -t $minicliplength "$outputfolderpath$tempdir/$i.$extension"
        else
            ffmpeg -loglevel quiet -ss $formattedstart -i "$sourcefile" -crf $CRF -b:v $Bit -filter:v scale=$dimensions:-2 -preset $Pre $Audio -t $minicliplength "$outputfolderpath$tempdir/$i.$extension"
        fi
        echo "file '$tempdir/$i.$extension'" >> "$outputfolderpath$listfile"
    done

    echo ""
    echo 'Generating final preview file...'

    if [ ! -d "$outputfolderpath$outputfoldername" ]; then
        mkdir "$outputfolderpath$outputfoldername"
    fi

    if [ -e "$outputfolderpath$outputfoldername$outputname.$extension" ]; then
        j=1
        while [ -e "$outputfolderpath$outputfoldername$outputname($j).$extension" ]; do
            let j++
        done
            outputname="$outputname($j)"
    fi

    ffmpeg -loglevel quiet -avoid_negative_ts 1 -f concat -safe 0 -i "$outputfolderpath$listfile" -c copy "$outputfolderpath$outputfoldername$outputname.$extension"
    
    echo ""
    echo 'Done! Check' "$outputfolderpath$outputfoldername$outputname.$extension"'!'

    # Cleanup
    rm -rf "$outputfolderpath$tempdir" "$outputfolderpath$listfile"

    echo ""
    echo ""
    echo -n "Would you like to generate another file? [y/N]: "; read response

    if [ "${response,,}" = "y" ]; then
        generate_single
    elif [ "${response,,}" = "n" ]; then
        echo ""
        echo ""
        echo "Thank you for using my tool!"
        echo "Goodbye!"
        exit
    else
        echo ""
        echo ""
        echo "Goodbye!"
        echo ""
    fi
}

function generate_batch() {
    clear

    echo ""
    echo "[Batch Generation - FINAL PARAMETERS]"
    echo ""
    echo ""
    echo "Current Encoder Settings"
    echo "--------------------------"
    echo "CRF value:       $CRF"
    echo "Bitrate in mbps: $Bit"
    echo "Preset type:     $Pre"
    if [[ $resolution =~ $re ]]; then
        echo "Resolution:      $resolution$p"
    else
        echo "Resolution:      $resolution"
    fi
    echo "Audio Toggle:    $audiotoggle"
    echo ""
    echo "Actions                         Description"
    echo "---------                       -------------"
    echo "[$back]Back                         Return to the previous page"
    echo "[$settings]Settings                     Access settings"
    echo "[$quit]Quit                         Quit"
    echo ""
    echo "-------------------------------------------------------------------"
    echo "Please enter the input and output parameters to begin the process"
    echo "[] = REQUIRED    {} = *NOT REQUIRED           *Defaults to preset"
    echo "                                             values if left blank"
    echo "Format:"
    echo "[inputextension] {outputextension}"
    echo "Ex. .mp4 .webm"
    echo "-------------------------------------------------------------------"
    echo ""
    echo ""

    echo -n "[Input]: "; read sourceex

    if [ "$sourceex" == "$settings" ]; then
        modify_encoder_settings
    elif [ "$sourceex" == "$back" ]; then
        generate_batch
    elif [ "$sourceex" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    fi

    echo -n "{Output}: "; read outputex

    if [ "$outputex" == "$settings" ]; then
        modify_encoder_settings
    elif [ "$outputex" == "$back" ]; then
        generate_batch
    elif [ "$outputex" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    fi

    sourceex=${sourceex#*.}

    count=0
    total=0
    for k in "$inputfolderpath"*.$sourceex; do
        if [ -e "$k" ]; then
            let total++
        fi
    done

    if [ $total = 0 ]; then
        echo ""
        echo ""
        echo "File type not found. Quitting..."
        exit
    fi

    for k in "$inputfolderpath"*.$sourceex; do
        let count++
        echo ""
        echo ""
        echo "Starting file $count... | $count/$total processing"
        sourcefile="${k#*"$inputfolderpath"}"

        defaultname="${sourcefile%.$sourceex}-preview" # | Default output file name

        if [ -z "$outputex" ]; then
            outputex=$sourceex # | Default output file extension
        elif [ "${outputex:0:1}" == "." ]; then
            outputex=${outputex#*.}
        fi

        sourcefile="$inputfolderpath$sourcefile"

        outputname="$defaultname"
        extension=$outputex

        length=$(ffprobe "$sourcefile"  -show_format 2>&1 | sed -n 's/duration=//p' | awk '{print int($0)}' |cut -d\. -f1)

        half=$((length/2))   # | Half of the video length in seconds
        third=$((length/3))  # | A third of the video length in seconds
        fourth=$((length/4)) # | A fourth of the video length in seconds
        fifth=$((length/5))  # | A fifth of the video length in seconds
        sixth=$((length/6))  # | A sixth of the video length in seconds

        echo ""
        echo 'Video length: ' $length 'seconds'
        length=$(($length - $endseconds ))
        length=$(($length-$startseconds))
        echo 'Video length with trimmed seconds: ' $length 'seconds'
        echo ""
        
        if [ "$length" -lt "$minlength" ]
        then
            echo ""
            echo 'Video is too short.  Quitting...'
            exit
        fi
        
        mkdir "$outputfolderpath$tempdir"

        interval=$(($length/$numminiclips))

        for i in $(seq 1 $numminiclips); do
            # Format the second marks into hh:mm:ss format
            start=$(($(($(($i-1))*$interval))+$startseconds))
            formattedstart=$(printf "%02d:%02d:%02d\n" $(($start/3600)) $(($start%3600/60)) $(($start%60)))
            echo 'Generating preview part ' $i $formattedstart
            # Generate the snippet at calculated time
            if [ "$extension" == "webm" ]; then
                ffmpeg -loglevel quiet -ss $formattedstart -i "$sourcefile" -c:v libvpx -crf $CRF -b:v $Bit -filter:v scale=$dimensions:-2 -c:a libvorbis -preset $Pre $Audio -t $minicliplength "$outputfolderpath$tempdir/$i.$extension"
            else
                ffmpeg -loglevel quiet -ss $formattedstart -i "$sourcefile" -crf $CRF -b:v $Bit -filter:v scale=$dimensions:-2 -preset $Pre $Audio -t $minicliplength "$outputfolderpath$tempdir/$i.$extension"
            fi
            echo "file '$tempdir/$i.$extension'" >> "$outputfolderpath$listfile"
        done

        echo ""
        echo 'Generating final preview file...'

        if [ ! -d "$outputfolderpath$outputfoldername" ]; then
            mkdir "$outputfolderpath$outputfoldername"
        fi

        if [ -e "$outputfolderpath$outputfoldername$outputname.$extension" ]; then
            j=1
            while [ -e "$outputfolderpath$outputfoldername$outputname($j).$extension" ]; do
                let j++
            done
                outputname="$outputname($j)"
        fi

        ffmpeg -loglevel quiet -avoid_negative_ts 1 -f concat -safe 0 -i "$outputfolderpath$listfile" -c copy "$outputfolderpath$outputfoldername$outputname.$extension"

        echo ""
        echo 'Done! Check' "$outputfolderpath$outputfoldername$outputname.$extension"'!'

        # Cleanup
        rm -rf "$outputfolderpath$tempdir" "$outputfolderpath$listfile"
    done

    echo ""
    echo ""
    echo -n "Would you like to generate another batch? [y/N]: "; read response

    if [ "${response,,}" = "y" ]; then
        generate_batch
    elif [ "${response,,}" = "n" ]; then
        echo ""
        echo ""
        echo "Thank you for using my tool!"
        echo "Goodbye!"
        exit
    else
        echo ""
        echo ""
        echo "Goodbye!"
        echo ""
    fi
}

function modify_settings() {
    clear

    echo ""
    if [ "$generationtype" == "$single" ]; then
        echo "[Single Generation - SETUP]"
    elif [ "$generationtype" == "$batch" ]; then
        echo "[Batch Generation - SETUP]"
    fi

    echo ""
    echo ""
    if [ "$isadvanced" = false ]; then
        echo "Current Settings - STATUS: MODIFYING"
        echo "--------------------------------------"
    else
        echo "Current Advanced Settings - STATUS: MODIFYING"
        echo "-----------------------------------------------"
    fi
    echo "Input folder path:               $inputfolderpath"
    echo "Output folder path:              $outputfolderpath$outputfoldername"
    if [ "$isadvanced" = true ]; then
        echo "Seconds trimmed from start:      $startseconds"
        echo "Seconds trimmed from end:        $endseconds"
        echo "Number of mini-clips to create:  $numminiclips"
        echo "Length of mini-clips in seconds: $minicliplength"
    fi
    echo ""
    if [ "$isadvanced" = true ]; then
        echo "Keywords                        Description"
        echo "----------                      -------------"
        echo "'half'                          Words for trimming features"
        echo "'third'                         that represent the fraction"
        echo "'fourth'                        of the total video length of"
        echo "'fifth'                         the input file in seconds"
        echo "'sixth'"
        echo ""
    fi
    echo "Actions"
    echo "---------"
    echo "[$back]Back                         Return to the previous page without saving"
    echo "[$quit]Quit                         Quit"
    echo ""
    echo ""

    inputpre=$inputfolderpath
    outputpre=$outputfolderpath
    startpre=$startseconds
    endpre=$endseconds
    numminipre=$numminiclips

    echo "To insert a drive letter, use semicolon format"
    echo "Ex. C:/folder1/folder2/..."
    echo "------------------------------------------------"
    echo '(Type "d" to keep current value)'
    echo -n "Insert new input folder path: "; read newinputfolderpath

    if [ "$newinputfolderpath" == "$currentval" ]; then
        inputfolderpath=$inputfolderpath
    elif [ -d "$newinputfolderpath" ]; then
        inputfolderpath=$newinputfolderpath
        if [ ! "${inputfolderpath: -1}" == "/" ]; then
            inputfolderpath="$inputfolderpath/"
        fi
    elif [ "$newinputfolderpath" == "$back" ]; then
        setup
    elif [ "$newinputfolderpath" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    else
        echo ""
        echo ""
        echo "Invalid file path. Quitting..."
        exit
    fi

    echo -n "Insert new output folder path: "; read newoutputfolderpath

    if [ "$newoutputfolderpath" == "$currentval" ]; then
        outputfolderpath=$outputfolderpath
    elif [ -d "$newoutputfolderpath" ]; then
        outputfolderpath=$newoutputfolderpath
        if [ ! "${outputfolderpath: -1}" == "/" ]; then
            outputfolderpath="$outputfolderpath/"
        fi
    elif [ "$newoutputfolderpath" == "$back" ]; then
        inputfolderpath=$inputpre
        setup
    elif [ "$newoutputfolderpath" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    else
        echo ""
        echo ""
        echo "Invalid file path. Quitting..."
        exit
    fi

    if [ "$isadvanced" = true ]; then
        echo -n "Insert new amount of seconds trimmed from start (Keywords available): "; read newstartseconds

        if [ "$newstartseconds" == "$currentval" ]; then
            startseconds=$startseconds
        elif [[ $newstartseconds =~ $re || "$newstartseconds" == "half" || "$newstartseconds" == "third" || "$newstartseconds" == "fourth" || "$newstartseconds" == "fifth" || "$newstartseconds" == "sixth" ]]; then
            startseconds=$newstartseconds
        elif [ "$newstartseconds" == "$back" ]; then
            inputfolderpath=$inputpre
            outputfolderpath=$outputpre
            setup
        elif [ "$newstartseconds" == "$quit" ]; then
            echo ""
            echo ""
            echo "Quitting..."
            exit
        else
            echo ""
            echo ""
            echo "Invalid number. Quitting..."
            exit
        fi

        echo -n "Insert new amount of seconds trimmed from end (Keywords available): "; read newendseconds

        if [ "$newendseconds" == "$currentval" ]; then
            endseconds=$endseconds
        elif [[ $newendseconds =~ $re || "$newendseconds" == "half" || "$newendseconds" == "third" || "$newendseconds" == "fourth" || "$newendseconds" == "fifth" || "$newendseconds" == "sixth" ]]; then
            endseconds=$newendseconds
        elif [ "$newendseconds" == "$back" ]; then
            inputfolderpath=$inputpre
            outputfolderpath=$outputpre
            startseconds=$startpre
            setup
        elif [ "$newendseconds" == "$quit" ]; then
            echo ""
            echo ""
            echo "Quitting..."
            exit
        else
            echo ""
            echo ""
            echo "Invalid number. Quitting..."
            exit
        fi

        echo -n "Insert new number of mini-clips to create: "; read newnumminiclips

        if [ "$newnumminiclips" == "$currentval" ]; then
            numminiclips=$numminiclips
        elif [[ $newnumminiclips =~ $re ]]; then
            numminiclips=$newnumminiclips
        elif [ "$newnumminiclips" == "$back" ]; then
            inputfolderpath=$inputpre
            outputfolderpath=$outputpre
            startseconds=$startpre
            endseconds=$endpre
            setup
        elif [ "$newnumminiclips" == "$quit" ]; then
            echo ""
            echo ""
            echo "Quitting..."
            exit
        else
            echo ""
            echo ""
            echo "Invalid number. Quitting..."
            exit
        fi

        echo -n "Insert new length of mini-clips in seconds: "; read newminicliplength

        if [ "$newminicliplength" == "$currentval" ]; then
            minicliplength=$minicliplength
        elif [[ $newminicliplength =~ $re ]]; then
            minicliplength=$newminicliplength
        elif [ "$newminicliplength" == "$back" ]; then
            inputfolderpath=$inputpre
            outputfolderpath=$outputpre
            startseconds=$startpre
            endseconds=$endpre
            numminiclips=$numminipre
            setup
        elif [ "$newminicliplength" == "$quit" ]; then
            echo ""
            echo ""
            echo "Quitting..."
            exit
        else
            echo ""
            echo ""
            echo "Invalid number. Quitting..."
            exit
        fi
    fi

    setup
}

function setup() {
    clear

    echo ""
    if [ "$generationtype" == "$single" ]; then
        echo "[Single Generation - SETUP]"
    elif [ "$generationtype" == "$batch" ]; then
        echo "[Batch Generation - SETUP]"
    fi

    echo ""
    echo ""
    if [ "$isadvanced" = false ]; then
        echo "Current Settings"
        echo "------------------"
    else
        echo "Current Advanced Settings"
        echo "---------------------------"
    fi
    echo "Input folder path:               $inputfolderpath"
    echo "Output folder path:              $outputfolderpath$outputfoldername"
    if [ "$isadvanced" = true ]; then
        echo "Seconds trimmed from start:      $startseconds"
        echo "Seconds trimmed from end:        $endseconds"
        echo "Number of mini-clips to create:  $numminiclips"
        echo "Length of mini-clips in seconds: $minicliplength"
    fi
    echo ""
    echo "Actions                         Description"
    echo "---------                       -------------"
    echo "[$continue]Continue                     Continue"
    echo "[$back]Back                         Return to the previous page"
    echo "[$settings]Settings                     Access settings"
    echo "[$advancedtoggle]Advanced                     Toggle Advanced mode"
    echo "[$quit]Quit                         Quit"
    echo ""
    echo ""

    echo -n "Select an action: "; read setupinput

    if [ "$setupinput" == "$continue" ]; then
        if [ "$generationtype" == "$single" ]; then
            generate_single
        elif [ "$generationtype" == "$batch" ]; then
            generate_batch
        fi
    elif [ "$setupinput" == "$settings" ]; then
        modify_settings
    elif [ "$setupinput" == "$advancedtoggle" ]; then
        if [ "$isadvanced" = false ]; then
            isadvanced=true
        else
            isadvanced=false
        fi
        setup
    elif [ "$setupinput" == "$back" ]; then
        start
    elif [ "$setupinput" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    else
        echo ""
        echo ""
        echo "Invalid input selector. Quitting..."
        exit
    fi 
}

function start() {
    clear

    echo ""
    echo "[*]     Video Preview Generator                                  [*]"
    echo "[*]     Version : 1.0.1                                          [*]"
    echo "[*]     Originally Created By : David Walsh (davidwalshblog)     [*]"
    echo "[*]     Modified & Developed By : Jonathan Thompson (jethomps0n) [*]"
    echo ""
    echo "Project Home: https://github.com/jethomps0n/Video-Preview-Generator"
    echo ""
    echo "Generation Type                 Description"
    echo "-----------------               -------------"
    echo "[$single]Single                       Generate a preview from a single file"
    echo "[$batch]Batch                        Generate series of previews from multiple files"
    echo ""
    echo "Actions"
    echo "---------"
    echo "[$quit]Quit                         Quit"
    echo ""
    echo ""

    echo -n "Select an option to begin: "; read generationtype

    if [[ "$generationtype" == "$single" || "$generationtype" == "$batch" ]]; then
        setup
    elif [ "$generationtype" == "$quit" ]; then
        echo ""
        echo ""
        echo "Quitting..."
        exit
    else
        echo ""
        echo ""
        echo "Invalid input selector. Quitting..."
        exit
    fi
}

start