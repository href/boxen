class people::href {

    # variables
    $home = "/Users/${::boxen_user}"
    $github = "href"
    $dotfiles = "${home}/.dotfiles"

    # core
    include firefox
    include onepassword
    include dropbox
    include wuala
    include skype
    include spotify
    include chrome
    include ohmyzsh
    
    # sublime text
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

    # dotfiles
    repository { $dotfiles :
        source => "${github}/dotfiles"
    }

    file { "${home}/.zshrc":
      ensure  => link,
      target  => "${dotfiles}/.zshrc",
      require => Repository[$dotfiles]
    }

    file { "${home}/.vimrc":
      ensure  => link,
      target  => "${dotfiles}/.vimrc",
      require => Repository[$dotfiles]
    }

    file { "${home}/.slate":
      ensure  => link,
      target  => "${dotfiles}/.slate",
      require => Repository[$dotfiles]
    }

    # use zsh as default shell
    osx_chsh { $::boxen_user :
        shell => "/bin/zsh",
    }
}
