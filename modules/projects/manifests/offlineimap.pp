# install offline imap and make sure it's run on each start
define projects::offlineimap($logs) {

    $user = $name
    $home = "/Users/${user}"

    if !defined(File["${home}/.offlineimaprc"]) {
        fail("${home}/.offlineimaprc is undefined")
    }

    package { 'offline-imap' :
        ensure => present
    } ->

    file { "${home}/Library/LaunchAgents/org.${user}.offlineimap.plist" :
        ensure  => present,
        content => template('projects/offlineimap.plist')
    }
}