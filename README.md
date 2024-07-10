# Video Preview Generator
Generate a short preview of a single video, or generate multiple at once! This tool gives you the power to break up your video into many short miniclips, fully customizable in how long or how many there are for that ultimate preview experience. [View Example.](#examplesect)
## What You Need
* Works natively with Linux and MacOS terminal
* Windows users must install a Unix-like environment terminal such as [Git for Windows](https://gitforwindows.org/) or use the native [Windows Subsystem for Linux](https://superuser.com/a/1059340)
* Must have [ffmpeg](https://ffmpeg.org/download.html) installed
  * <details>
      <br>
      <summary>For MacOS Users</summary>
      <p>Additionally, MacOS users may have to install the line of code below for access to full codec and encoding functionality:</p>
      <code>brew install ffmpeg --with-fdk-aac --with-ffplay --with-freetype --with-frei0r --with-libass --with-libvo-aacenc --with-libvorbis --with-libvpx --with-opencore-amr --with-openjpeg --with-opus --with-rtmpdump --with-speex --with-theora --with-tools --with-libvorbis</code>
    </details>
## Features
This project builds upon the [original](#creditssect), but also expands upon it in many ways. The program is increasingly customizable, offering the ability to change a wide set of parameters without having to go into the file itself.
* Generate a preview of a single video file
* Generate a bulk of previews from a batch of files
* Customize the parameters of the video preview(s):
  * Can modify the amount of seconds trimmed from the beginning of the input file (useful to skip past opening credits)
  * Can modify the amount of seconds trimmed from the end of the input file (useful to skip past closing credits)
  * Can modify the number of mini-clips to be created in the video preview
  * Can modify the length of each mini-clip
  * Can modify the encoding values of the video preview as well (CRF, bitrate, preset, resolution, and audio)
<span id="howtosect"></span>
## How to Use
Download the `preview.sh` file.

This command can be run from ANYWHERE! It works with folders and file names with both spaces and without spaces.

To run, replace the `/path/to/...` section with the directory to where you have the `preview.sh` file located:
```
$ /path/to/preview.sh
```
And that's it! The rest is pretty straightforward from there.

Here is an example as to what the first page looks like after you run:
```
[*]     Video Preview Generator                                  [*]
[*]     Version : 1.0.0                                          [*]
[*]     Originally Created By : David Walsh (davidwalshblog)     [*]
[*]     Modified & Developed By : Jonathan Thompson (jethomps0n) [*]

Project Home: https://github.com/jethomps0n/Video-Preview-Generator

Generation Type                 Description
-----------------               -------------
[1]Single                       Generate a preview from a single file
[2]Batch                        Generate series of previews from multiple files

Actions
---------
[q]Quit                         Quit


Select an option to begin:
```
And generating a preview of a single file:
```
[Single Generation - FINAL PARAMETERS]


Current Encoder Settings
--------------------------
CRF value:       23
Bitrate in mbps: 5M
Preset type:     fast
Resolution:      720p
Audio Toggle:    off

Actions                         Description
---------                       -------------
[b]Back                         Return to the previous page
[s]Settings                     Access settings
[q]Quit                         Quit

-------------------------------------------------------------------
Please enter the input and output parameters to begin the process
[] = REQUIRED    {} = *NOT REQUIRED           *Defaults to preset
                                             values if left blank
Format:
[inputfile] {outputfile}   -OR-  [inputfile] {outputextension}
Ex. input.mp4 output.webm  -OR-  input.mp4 .webm
-------------------------------------------------------------------


[Input]:
{Output}:
```
## More
### Contributing
If you would like to help add or improve a feature within this project in any way, follow the steps below:
1. Fork the project!
2. Create your new branch: `$ git checkout -b my-new-branch`
4. Add and commit your changes: `$ git commit -m "Add new supercool feature"`
5. Push to the branch: `$ git push origin my-new-branch`
6. Submit a pull request!
### Discussions & Issues
To engage with the community or for more information, write about it in the Discussions tab.
- Ask for help
- Share ideas
- Write feedback
- View announcements
- And many more...

For issues found with the tool, direct this information to the Issues tab.
- Flag bugs and issues the program shouldn't be doing
<span id="examplesect"></span>
## Generated Example
https://github.com/jethomps0n/Video-Preview-Generator/assets/171000344/4a87e7a7-7952-4b65-a7ae-07f542380f2f

_"Christopher Nolan Wins Best Director for 'Oppenheimer' | 96th Oscars (2024)" - Oscars, YouTube (March 10, 2024)_
<span id="creditssect"></span>
## Credits
[Original](https://davidwalsh.name/video-preview) file and much of the core functionality was created by David Walsh.
<details>
  <summary><b>See all changes that have been made</b></summary>
  <br>
  <ul>
    <li>Added a user interface</li>
    <li>Added support for WebM and other codec and encoding features</li>
    <li>Added support for multiple files to be generated at once (batch mode)</li>
    <li>Fixed the way the intervals between miniclips were calculated</li>
    <li>Fixed an issue where the miniclips would be out of order in the output file if the number of miniclips was 10 or more</li>
    <li>Added an input to modify the seconds trimmed from the end of the video file</li>
    <li>Added functionality for files to be referenced from any directory</li>
    <li>Added functionality for files and folders with spaces</li>
    <li>Added a special subfolder for generated preview files in the output path</li>
    <li>Added a default naming system for empty fields</li>
    <li>Added compatibility if a file on a users device has the same name of the output file in the output directory</li>
    <li>Added heavy customization features for input and output settings</li>
  </ul>
</details>

## Disclaimer
Despite creating this project and sharing it with you all, I do not know Bash. Bash is a language I've never learned, and never heard of or come across until I uploaded this. I've been in need of a program like this for my [website project](https://github.com/jethomps0n/jethomps0n.github.io) and upon finding the [original](#creditssect), I decided to add some functionality to it. Any modifications I've made have been done purely out of my knowledge of other coding languages and the similar syntax they share. A few sources of online people in past discussions that are way smarter than me helped as well. With this being said, I'm sure my code my not be up to par with similar programs and can be made to be much more efficient. Nevertheless, I am always looking for ways to improve, so any comments or feedback anyone may have is always welcome! I hope you are able to find some comfort with this project and can put this tool to good use!
