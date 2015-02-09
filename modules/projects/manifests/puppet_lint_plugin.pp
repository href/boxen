# puppet lint plugin
define projects::puppet_lint_plugin ($ruby_version) {
    ruby_gem { "puppet-lint plugin ${name}" :
        gem          => $name,
        ruby_version => $ruby_version
    }
}