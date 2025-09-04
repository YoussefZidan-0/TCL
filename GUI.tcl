#! /usr/bin/wish

# Callback to run when the button is clicked.
proc show_message {} {
    # If a label exists, update its text; otherwise create and grid one.
    if {[winfo exists .msg]} {
        .msg configure -text "Button clicked!"
    } else {
        ttk::label .msg -text "Button clicked!"
        grid .msg -row 1 -column 0 -pady 10
    }

    # Also show a simple modal message box.
    tk_messageBox -type ok -message "You clicked the button!"
}

# Create the button and attach the callback.
ttk::button .mybutton -text "Hello World" -command show_message
grid .mybutton -row 0 -column 0 -padx 10 -pady 10
]