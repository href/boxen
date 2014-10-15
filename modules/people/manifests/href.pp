class people::href {

    # variables
    $home = "/Users/${::boxen_user}"
    $github = 'href'
    $dotfiles = "${home}/.dotfiles"
    $userfiles = "puppet:///modules/people/${github}"
    $userscripts = "${home}/bin"
    $logs = "${home}/Logs"

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
    include hipchat
    include vmware_fusion
    include postgresql
    include littlesnitch
    include bartender
    include memcached
    include textual
    include charles
    include steam
    include minecraft
    include brewcask

    # let kaleidoscope handle the .gitconfig
    class { 'kaleidoscope':
        make_default => false,
    }

    # key remappings
    include karabiner
    include karabiner::login_item

    # remove the non-breaking spaces which ironically breaks code
    karabiner::remap{ 'option_space_to_space': }

    # have the IBM keyboard @ available
    karabiner::remap { 'altgr_2_to_atmark': }

    # user-scripts
    file { $userscripts :
        ensure => directory
    } ->

    file { "${userscripts}/plone-extract" :
        ensure => present,
        source => "${userfiles}/plone-extract",
        mode   => '0770'
    } ->

    file { "${userscripts}/keychain" :
        ensure => present,
        source => "${userfiles}/keychain",
        mode   => '0770'
    }

    # packages
    $homebrew_packages = [
        'aria2',
        'docker',
        'ghi',
        'go',
        'lftp',
        'libjpeg',
        'libmagic',
        'libpng',
        'lynx',
        'offlineimap',
        'packer',
    ]

    $cask_packages = []

    package { $homebrew_packages :
        ensure => present
    }

    package { $cask_packages :
        provider => 'brewcask'
    }

    # globally used ruby
    $globalruby = '2.0.0'
    class { 'ruby::global':
        version => $globalruby
    }

    # gems
    ruby_gem { "puppet-lint for ${globalruby}":
        gem             => 'puppet-lint',
        ruby_version    => $globalruby,
        version         => '~> 0.3.2'
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
    vagrant::plugin { 'vagrant-multiprovider-snap' : }

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
    sublime_text_2::package { 'Tomorrow Color Schemes' :
        source => 'theymaybecoders/sublime-tomorrow-theme'
    }
    sublime_text_2::package { 'Trimmer' :
        source => 'jonlabelle/Trimmer'
    }
    sublime_text_2::package { 'Syntax Highlighting for Sass' :
        source => 'P233/Syntax-highlighting-for-Sass'
    }
    sublime_text_2::package { 'Robot Framework' :
        source => 'shellderp/sublime-robot-plugin'
    }
    sublime_text_2::package { 'Theme - Spacegray' :
        source => 'kkga/spacegray'
    }
    sublime_text_2::package { 'GoSublime' :
        source => 'DisposaBoy/GoSublime'
    }
    sublime_text_2::package { 'Dictionaries' :
        source => 'SublimeText/Dictionaries'
    }
    sublime_text_2::package { 'Dockerfile Syntax Highlighting' :
        source => 'asbjornenge/Dockerfile.tmLanguage'
    }
    sublime_text_2::package { 'Lispindent' :
        source => 'odyssomay/sublime-lispindent'
    }
    sublime_text_2::package { 'Jinja2' :
        source => 'mitsuhiko/jinja2-tmbundle'
    }
    sublime_text_2::package { 'Scheme' :
        source => 'egrachev/sublime-scheme'
    }
    sublime_text_2::package { 'Rust' :
        source => 'jhasse/sublime-rust'
    }
    sublime_text_2::package { 'TOML' :
        source => 'lmno/TOML'
    }

    # dotfiles
    repository { $dotfiles :
        source => "${github}/dotfiles"
    } ->

    file { "${home}/.zshrc" :
        ensure => link,
        target => "${dotfiles}/.zshrc"
    } ->

    file { "${home}/.vimrc" :
        ensure => link,
        target => "${dotfiles}/.vimrc",
    } ->

    file { "${home}/.hydra" :
        ensure => link,
        target => "${dotfiles}/.hydra",
    } ->

    file { "${home}/.pythonrc" :
        ensure => link,
        target => "${dotfiles}/.pythonrc",
    } ->

    file { "${home}/.offlineimaprc" :
        ensure => link,
        target => "${dotfiles}/.offlineimaprc",
    } ->

    file { "${home}/.pdbrc" :
        ensure => link,
        target => "${dotfiles}/.pdbrc"
    } ->

    file { "${home}/.pdbrc.py" :
        ensure => link,
        target => "${dotfiles}/.pdbrc.py"
    } ->

    # buildout defaults
    file { [
        "${home}/.buildout",
        "${home}/.buildout/extends",
        "${home}/.buildout/downloads",
        "${home}/.buildout/eggs"
    ] :
        ensure => directory
    } ->
    file { "${home}/.buildout/default.cfg" :
        ensure => link,
        target => "${dotfiles}/default.cfg"
    }

    # use zsh as default shell
    osx_chsh { $::boxen_user :
        shell => '/bin/zsh',
    }

    # python
    class { 'python' : } ->
    class { 'python::virtualenvwrapper' : } ->

    python::pip { 'pipsi==0.8' :
        ensure     => 'present',
        virtualenv => $python::config::global_venv
    }

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

    # cronjobs
    file { "${home}/Minecraft" :
        ensure => directory
    }

    # logs
    file { $logs :
        ensure => directory
    }

    case $::hostname {
        'home': {
            cron { 'daily minecraft backup' :
                hour    => '19',
                minute  => '0',
                command => "${userscripts}/minecraft-backup",
                user    => denis
            }
            cron { 'daily mail backup' :
                hour    => '19',
                minute  => '30',
                command => "/opt/boxen/homebrew/bin/offlineimap > ${logs}/mail-backup.log",
                user    => denis
            }
        }
        'dk': {
            cron { 'daily minecraft backup' :
                hour    => '10',
                minute  => '0',
                command => "${userscripts}/minecraft-backup",
                user    => denis
            }
        }

    }
}
