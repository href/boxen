class people::href {

    # variables
    $home = "/Users/${::boxen_user}"
    $github = "href"
    $dotfiles = "${home}/.dotfiles"
    $userfiles = "puppet:///modules/people/${github}"
    $userscripts = "${home}/bin"

    # osx config
    include osx::global::enable_keyboard_control_access
    include osx::global::expand_print_dialog
    include osx::global::expand_save_dialog
    include osx::global::disable_remote_control_ir_receiver

    class { 'osx::global::natural_mouse_scrolling':
        enabled => false
    }

    class { 'osx::global::key_repeat_rate':
        rate => 0
    }

    class { 'osx::global::key_repeat_delay':
        delay => 0
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
    include vmware_fusion
    include postgresql
    include littlesnitch
    include bartender
    include memcached
    include textual
    include charles

    # key remappings
    include keyremap4macbook
    include keyremap4macbook::login_item

    # remove the non-breaking spaces which ironically breaks code
    keyremap4macbook::remap{ 'option_space_to_space': }

    # have the IBM keyboard @ available
    keyremap4macbook::remap { 'altgr_2_to_atmark': }

    # user-scripts
    file { $userscripts :
        ensure => directory
    }

    # sublime text syncing
    Class['dropbox'] ->
    Class['sublime_text_2'] ->
    
    file { "${userscripts}/setup-sublime-sync" :
        ensure => present,
        source => "${userfiles}/setup-sublime-sync",
        mode   => '0770'
    } ->
    
    exec { "${userscripts}/setup-sublime-sync" : }

    # vagrant
    include vagrant

    vagrant::plugin { 'vagrant-vmware-fusion':
        license => "${userfiles}/licenses/vagrant.lic"
    }
    
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

    # virtualenvwrapper postactivate
    file { "${home}/.virtualenvs" :
        ensure => directory
    } ->
    file { "${home}/.virtualenvs/postactivate" : 
        ensure => present,
        source => "${userfiles}/postactivate",
        mode   => '0775'
    } ->
    file { "${home}/.virtualenvs/postmkvirtualenv" :
        ensure => present,
        source => "${userfiles}/postmkvirtualenv",
        mode   => '0775'
    }
}
