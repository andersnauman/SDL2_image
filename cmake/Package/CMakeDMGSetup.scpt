on run argv
  set image_name to item 1 of argv

  tell application "Finder"
  tell disk image_name

    -- wait for the image to finish mounting
    set open_attempts to 0
    repeat while open_attempts < 4
      try
        open
          delay 1
          set open_attempts to 5
        close
      on error errStr number errorNumber
        set open_attempts to open_attempts + 1
        delay 10
      end try
    end repeat
    delay 5

    -- open the image the first time and save a DS_Store with just
    -- background and icon setup
    open
      set current view of container window to icon view
      set theViewOptions to the icon view options of container window
      set background picture of theViewOptions to file ".background:background.png"
      set arrangement of theViewOptions to not arranged
      delay 5
    close

    -- next setup the position of the app and Applications symlink
    -- plus hide all the window decoration
    open
      update without registering applications
      tell container window
        --do shell script "ln -s /Applications test"
        --set newfo to make new folder at image_name with properties {name:"JobName}
        set UserFrameworks to (((path to library folder from user domain) as text) & "Frameworks")
        if not (exists UserFrameworks) then
          make new folder at ((path to library folder from user domain) as text) with properties { name: "Frameworks" }
        end if
        make new alias to UserFrameworks at image_name with properties { name: "User Frameworks" }

        set LocalFrameworks to (((path to library folder from local domain) as text) & "Frameworks")
        if not (exists LocalFrameworks) then
          make new folder at ((path to library folder from local domain) as text) with properties { name: "Frameworks" }
        end if
        make new alias to LocalFrameworks at image_name with properties { name: "Machine Frameworks" }

        set sidebar width to 0
        set statusbar visible to false
        set toolbar visible to false
        set the bounds to { 400, 100, 900, 465 }
        set position of item "SDL2_image.framework" to { 110, 200 }
        set position of item "User Frameworks" to { 378, 110 }
        set position of item "Machine Frameworks" to { 378, 250 }

        set current view to icon view
        tell its icon view options
           set icon size to 80
        end tell
      end tell
      update without registering applications
      delay 5
    close

    -- one last open and close so you can see everything looks correct
    open
      delay 5
    close
  end tell
  delay 1
end tell
end run