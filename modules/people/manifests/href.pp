# configure's the osx environment of user 'href'

# lint:ignore:relative_classname_inclusion
# => there are no relative classes here that could clash here
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
    include osx::global::enable_standard_function_keys
    include osx::global::tap_to_click
    include osx::global::expand_print_dialog
    include osx::global::expand_save_dialog
    include osx::global::disable_remote_control_ir_receiver
    include osx::dock::disable_dashboard
    include osx::finder::empty_trash_securely
    include osx::finder::enable_quicklook_text_selection
    include osx::finder::no_file_extension_warnings
    include osx::safari::enable_developer_mode

    class { 'osx::global::natural_mouse_scrolling' :
        enabled => false
    }

    class { 'osx::dock::hot_corners' :
        bottom_right => 'Mission Control'
    }

    class { 'osx::sound::interface_sound_effects' :
        enable => false
    }

    # remove old nodeenv
    file { '/opt/boxen/env.d/30_nodejs.sh' :
        ensure => 'absent'
    }

    # git config
    git::config::global { 'user.useConfigOnly' :
        value => true
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
    git::config::global { 'alias.prune' :
        value => 'fetch --prune'
    }
    git::config::global { 'alias.undo' :
        value => 'reset --soft HEAD^'
    }
    git::config::global { 'alias.stash-all' :
        value => 'stash save --include-untracked'
    }
    git::config::global { 'merge.ff' :
        value => 'only'
    }
    git::config::global { 'commit.gpgSign' :
        value => true
    }
    git::config::global { 'push.followTags' :
        value => true
    }
    git::config::global { 'status.showUntrackedFiles' :
        value => 'all'
    }
    git::config::global { 'transfer.fsckobjects' :
        value => true
    }

    # core modules
    include alfred
    include brewcask
    include elasticsearch
    include littlesnitch
    include memcached
    include ohmyzsh
    include onepassword
    include postgresql
    include textual

    # libraries / cli tools
    $core_packages = [
        'aria2',
        'go',
        'keybase',
        'lftp',
        'jpeg',
        'libmagic',
        'libpng',
        'packer',
        'tarsnap'
    ]

    package { $core_packages :
        ensure => present
    }

    # mac apps (from cask)
    $applications = [
        'dash',
        'firefox',
        'franz',
        'google-chrome',
        'hammerspoon',
        'harvest',
        'inkscape',
        'iterm2-beta',
        'kaleidoscope',
        'navicat-premium',
        'omnifocus',
        'sketch',
        'steam',
        'the-tagger',
        'the-unarchiver',
        'viscosity',
    ]

    homebrew::tap { 'caskroom/versions' : } ->

    package { $applications :
        provider => 'brewcask'
    }

    # setup kaleidoscope
    Package['kaleidoscope'] ->

    file { "${boxen::config::bindir}/ksdiff" :
        ensure => link,
        target => '/Applications/Kaleidoscope.app/Contents/Resources/bin/ksdiff',
        mode   => '0755',
    } ->
    git::config::global { 'difftool "Kaleidoscope".cmd':
      value => 'ksdiff --partial-changeset --relative-path "$MERGED" -- "$LOCAL" "$REMOTE"',
    }
    git::config::global { 'diff.tool':
      value => 'Kaleidoscope',
    }
    git::config::global { 'mergetool "Kaleidoscope".cmd':
      value => 'ksdiff --merge --output "$MERGED" --base "$BASE" -- "$LOCAL" --snapshot "$REMOTE" --snapshot',
    }
    git::config::global { 'mergetool "Kaleidoscope".trustExitCode':
      value => true,
    }
    git::config::global { 'merge.tool' :
      value => 'Kaleidoscope',
    }

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
        ruby_version => $globalruby
    } ->
    projects::puppet_lint_plugin { [
        'puppet-lint-variable_contains_upcase',
        'puppet-lint-absolute_template_path',
        'puppet-lint-unquoted_string-check',
        'puppet-lint-empty_string-check',
        'puppet-lint-leading_zero-check',
        'puppet-lint-undef_in_function-check'
    ] :
        ruby_version => $globalruby
    }
    ruby_gem { "scss-lint for ${globalruby}" :
        gem          => 'scss-lint',
        ruby_version => $globalruby,
        version      => '~> 0.31.0'
    }
    ruby_gem { "svn2git for ${globalruby}" :
        gem          => 'svn2git',
        ruby_version => $globalruby,
        version      => '~> 2.3.2'
    }
    ruby_gem { "lunchy for ${globalruby}" :
        gem          => 'lunchy',
        ruby_version => $globalruby,
        version      => '~> 0.10.3'
    }

    # haskell
    include 'projects::haskell_platform'
    projects::haskell_package { 'shellcheck' : }

    # have a link to the icloud drive
    $icloud = '/Users/denis/Library/Mobile Documents/com~apple~CloudDocs'
    file { '/Users/denis/iCloud Drive' :
        ensure => 'link',
        target => $icloud
    }

    # sublime text syncing
    $application_support = '/Users/denis/Library/Application Support'

    Class['sublime_text_3'] ->

    exec { "mkdir -p ${icloud}/Sublime-Sync/Packages/User" :
        creates => "${icloud}/Sublime-Sync/Packages/User"
    } ->

    file { "${application_support}/Sublime Text 3/Packages/User" :
        ensure => 'link',
        target => "${icloud}/Sublime-Sync/Packages/User",
        force  => true
    }

    # vagrant
    class { 'vagrant' :
        version => '1.8.0'
    } ->
    vagrant::plugin { 'vagrant-cachier' : }

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
    sublime_text_3::package { 'sublime-nginx' :
        source => 'brandonwamboldt/sublime-nginx'
    }
    sublime_text_3::package { 'babel-sublime' :
        source => 'babel/babel-sublime'
    }
    sublime_text_3::package { 'SublimeLinter-jsxhint' :
        source => 'SublimeLinter/SublimeLinter-jsxhint'
    }
    sublime_text_3::package { 'MagicPython' :
        source => 'MagicStack/MagicPython'
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

    file { "${home}/.hammerspoon" :
        ensure => link,
        target => "${dotfiles}/.hammerspoon",
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
    } ->

    file { "${home}/.mackup.cfg" :
        ensure => link,
        target => "${dotfiles}/.mackup.cfg"
    } ->

    file { "${home}/.tarsnaprc" :
        ensure => link,
        target => "${dotfiles}/.tarsnaprc"
    }

    file { "${home}/.psqlrc" :
        ensure => link,
        target => "${dotfiles}/.psqlrc"
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

    # install zsh plugins
    file { ["${home}/.zsh", "${home}/.zsh/plugins"] :
        ensure => 'directory',
    }

    # python
    class { 'python' : } ->
    class { 'python::virtualenvwrapper' : } ->

    python::pip { ['pipsi', 'percol', 'httpie'] :
        ensure     => 'present',
        virtualenv => $python::config::global_venv
    }

    # logs
    file { $logs :
        ensure => directory
    }

    # quicklook improvements
    include 'projects::quicklook_textfiles'

    case $::hostname {
        'home': {
            projects::offlineimap { $::boxen_user :
                logs => $logs
            }
        }
        default : {

        }
    }

    # disable last login message
    file { "${home}/.hushlogin" :
        ensure => 'present'
    }
}
# lint:endignore
