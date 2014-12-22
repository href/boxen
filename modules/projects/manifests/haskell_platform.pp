# installs the Haskell platform on OSX, without having to compile anything
class projects::haskell_platform() {

    # we need to do this manually, as it will fail otherwise because of this:
    # https://github.com/haskell/haskell-platform/issues/151
    $parts = [
        'https://downloads.haskell.org/~platform/2014.2.0.0',
        '/Haskell%20Platform%202014.2.0.0%2064bit.signed.pkg'
    ]
    $url = join($parts, '')

    $download_cmd = "curl ${url} -o /tmp/haskell.pkg"
    $install_cmd = '/usr/sbin/installer -pkg /tmp/haskell.pkg -target /'
    $success_file = '/var/db/.haskell-installed'

    exec { 'download haskell platform' :
        command => "curl ${url} -o /tmp/haskell.pkg",
        creates => '/tmp/haskell.pkg',
        unless  => "test -f ${success_file}"
    } ->

    exec { 'install haskell platform' :
        command => "${install_cmd} -verbose",
        creates => $success_file,
        user    => 'root',
        returns => [0, 1]
    } ->

    exec { 'mark haskell as installed' :
        command => "test -e /usr/bin/ghc && touch ${success_file}",
        creates => $success_file,
        user    => 'root'
    }
}