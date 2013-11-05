class people::href {

    # variables
    $home = "/Users/${::boxen_user}"
    $github = "href"
    $dotfiles = "${home}/.dotfiles"

    # osx config
    include osx::global::enable_keyboard_control_access
    include osx::global::expand_print_dialog
    include osx::global::expand_save_dialog
    include osx::global::disable_remote_control_ir_receiver

    class { 'osx::global::natural_mouse_scrolling':
        enabled => false
    }

    class { 'osx::global::key_repeat_rate':
        rate => 2
    }

    class { 'osx::global::key_repeat_delay':
        delay => 10
    }

    # git config
    git::config::global { 'user.email' :
        value => 'denis@href.ch'
    }
    git::config::global { 'user.name' :
        value => 'Denis Krienbühl'
    }
    git::config::global { 'color.ui' :
        value => true
    }
    git::config::global { 'core.autocrlf' :
        value => 'input'
    }

    # core
    include firefox
    include onepassword
    include dropbox
    include wuala
    include skype
    include spotify
    include chrome
    include ohmyzsh
    include iterm2::stable
    include alfred
    include slate
    include hipchat
    
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

    file { "${home}/.pythonrc":
      ensure  => link,
      target  => "${dotfiles}/.pythonrc",
      require => Repository[$dotfiles]
    }

    # use zsh as default shell
    osx_chsh { $::boxen_user :
        shell => "/bin/zsh",
    }

    # python
    include python
    include python::virtualenvwrapper
}
