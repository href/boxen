# configure's the osx environment of user 'href'
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

    class { 'osx::global::natural_mouse_scrolling' :
        enabled => false
    }

    class { 'osx::global::key_repeat_rate' :
        rate => 0
    }

    class { 'osx::global::key_repeat_delay' :
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
    git::config::global { 'core.precomposeunicode' :
        value => true
    }

    # core modules
    include alfred
    include brewcask
    include charles
    include dropbox
    include iterm2::stable
    include littlesnitch
    include memcached
    include ohmyzsh
    include onepassword
    include postgresql
    include steam
    include textual

    # libraries / cli tools
    $core_packages = [
        'aria2',
        'docker',
        'ghi',
        'go',
        'lftp',
        'jpeg',
        'libmagic',
        'libpng',
        'lynx',
        'packer'
    ]

    package { $core_packages :
        ensure => present
    }

    # mac apps (from cask)
    $applications = [
        'bartender',
        'firefox',
        'firefoxdeveloperedition',
        'google-chrome',
        'harvest',
        'hipchat',
        'hive',
        'skype',
        'spotify',
        'panic-unison',
        'wuala'
    ]

    homebrew::tap { 'caskroom/versions' : } ->

    package { $applications :
        provider => 'brewcask'
    }

    # make sure wuala is started in the background
    Package ['wuala'] ->
    file_line { 'wuala silent start' :
        path => "${home}/Library/Application Support/Wuala/Wuala.cfg",
        line => 'silent=true'
    }

    # let kaleidoscope handle the .gitconfig
    class { 'kaleidoscope' :
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

    # globally used ruby
    $globalruby = '2.0.0'
    class { 'ruby::global' :
        version => $globalruby
    }

    # gems
    ruby_gem { "puppet-lint for ${globalruby}" :
        gem          => 'puppet-lint',
        ruby_version => $globalruby,
        version      => '~> 1.1.0'
    }
    ruby_gem { "scss-lint for ${globalruby}" :
        gem          => 'scss-lint',
        ruby_version => $globalruby,
        version      => '~> 0.31.0'
    }

    # haskell
    include 'projects::haskell_platform'
    projects::haskell_package { 'shellcheck' : }

    # sublime text syncing
    $dropbox = '/Users/denis/Dropbox'
    $application_support = '/Users/denis/Library/Application Support'

    Class['dropbox'] ->
    Class['sublime_text_3'] ->

    exec { "mkdir -p ${dropbox}/Sublime-Sync/Packages/User" :
        creates => "${dropbox}/Sublime-Sync/Packages/User"
    } ->

    file { "${application_support}/Sublime Text 3/Packages/User" :
        ensure => 'link',
        target => "${dropbox}/Sublime-Sync/Packages/User",
        force  => true
    }

    # vagrant
    include vagrant
    vagrant::plugin { 'vagrant-multiprovider-snap' : }

    # sublime text 3
    include sublime_text_3
    include sublime_text_3::package_control

    sublime_text_3::package { 'SublimeLinter' :
        source => 'SublimeLinter/SublimeLinter3'
    }
    sublime_text_3::package { 'SublimeLinter-puppet-lint' :
        source => 'stopdropandrew/SublimeLinter-puppet-lint'
    }
    sublime_text_3::package { 'SublimeLinter-flake8' :
        source => 'SublimeLinter/SublimeLinter-flake8'
    }
    sublime_text_3::package { 'SublimeLinter-jshint' :
        source => 'SublimeLinter/SublimeLinter-jshint'
    }
    sublime_text_3::package { 'SublimeLinter-pep8' :
        source => 'SublimeLinter/SublimeLinter-pep8'
    }
    sublime_text_3::package { 'SublimeLinter-pep257' :
        source => 'SublimeLinter/SublimeLinter-pep257'
    }
    sublime_text_3::package { 'SublimeLinter-pyyaml' :
        source => 'SublimeLinter/SublimeLinter-pyyaml'
    }
    sublime_text_3::package { 'GitGutter' :
        source => 'jisaacks/GitGutter'
    }
    sublime_text_3::package { 'SublimePuppet' :
        source => 'russCloak/SublimePuppet'
    }
    sublime_text_3::package { 'Tomorrow Color Schemes' :
        source => 'theymaybecoders/sublime-tomorrow-theme'
    }
    sublime_text_3::package { 'Trimmer' :
        source => 'jonlabelle/Trimmer'
    }
    sublime_text_3::package { 'Syntax Highlighting for Sass' :
        source => 'P233/Syntax-highlighting-for-Sass'
    }
    sublime_text_3::package { 'Robot Framework' :
        source => 'shellderp/sublime-robot-plugin'
    }
    sublime_text_3::package { 'Theme - Spacegray' :
        source => 'kkga/spacegray'
    }
    sublime_text_3::package { 'Dictionaries' :
        source => 'SublimeText/Dictionaries'
    }
    sublime_text_3::package { 'Dockerfile Syntax Highlighting' :
        source => 'asbjornenge/Dockerfile.tmLanguage'
    }
    sublime_text_3::package { 'Lispindent' :
        source => 'odyssomay/sublime-lispindent'
    }
    sublime_text_3::package { 'Jinja2' :
        source => 'mitsuhiko/jinja2-tmbundle'
    }
    sublime_text_3::package { 'Scheme' :
        source => 'egrachev/sublime-scheme'
    }
    sublime_text_3::package { 'Rust' :
        source => 'jhasse/sublime-rust'
    }
    sublime_text_3::package { 'TOML' :
        source => 'lmno/TOML'
    }
    sublime_text_3::package { 'FileBrowser' :
        source => 'aziz/SublimeFileBrowser'
    }
    sublime_text_3::package { 'Theme - Glacier' :
        source => 'joeyfigaro/glacier-theme'
    }
    sublime_text_3::package { 'BracketHighlighter' :
        source => 'facelessuser/BracketHighlighter'
    }
    sublime_text_3::package { 'ColorHighlighter' :
        source => 'href/ColorHighlighter'
    }
    sublime_text_3::package { 'SublimeLinter-shellcheck' :
        source => 'SublimeLinter/SublimeLinter-shellcheck'
    }
    sublime_text_3::package { 'SublimeLinter-rst' :
        source => 'SublimeLinter/SublimeLinter-rst'
    }
    sublime_text_3::package { 'SublimeLinter-csslint' :
        source => 'SublimeLinter/SublimeLinter-csslint'
    }
    sublime_text_3::package { 'SublimeLinter-scss-lint' :
        source => 'attenzione/SublimeLinter-scss-lint'
    }
    sublime_text_3::package { 'SublimeLinter-ruby' :
        source => 'SublimeLinter/SublimeLinter-ruby'
    }
    sublime_text_3::package { 'sublimetext-markdown-preview' :
        source => 'revolunet/sublimetext-markdown-preview'
    }

    # for sublime linter
    $linter_python_packages = [
        'docutils',
        'flake8',
        'pep257',
        'pep8',
        'pygments',
        'pyyaml',
    ]
    projects::global_python_package { $linter_python_packages : }

    $linter_node_packages = [
        'csslint',
        'jshint',
    ]
    nodejs::module { $linter_node_packages :
        node_version => 'v0.10'
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

    file { "${home}/.jshintrc" :
        ensure => link,
        target => "${dotfiles}/.jshintrc"
    }

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

    # logs
    file { $logs :
        ensure => directory
    }

    # quicklook improvements
    include 'projects::quicklook_textfiles'

    # disable dashboard
    include 'projects::turn_off_dashboard'

    case $::hostname {
        'home': {
            projects::offlineimap { $::boxen_user :
                logs => $logs
            }
        }
        default : {

        }
    }
}
