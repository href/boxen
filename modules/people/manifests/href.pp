class people::href {
    include firefox
    include onepassword
    include dropbox
    include wuala
    include skype
    include spotify
    
    include sublime_text_2
    sublime_text_2::package { 'SublimeLinter' :
        source => 'SublimeLinter/SublimeLinter'
    }
    sublime_text_2::package { 'GitGutter' :
        source => 'jisaacks/GitGutter'
    }
    sublime_text_2::package { 'SublimePuppet' :
        source => 'russCloak/SublimePuppet'
    }
}
