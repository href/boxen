# makes all textfiles usable through quicklook
class projects::quicklook_textfiles() {
    $parts = [
        'https://github.com/whomwah/qlstephen/releases/download/1.4.2/',
        'QLStephen.qlgenerator.1.4.2.zip'
    ]

    $url = join($parts, '')
    $directory = "/Users/${::boxen_user}/Library/Quicklook"

    exec { "curl ${url} --location -o /tmp/qlstephen.zip" :
        creates => '/tmp/qlstephen.zip',
        unless  => "test -d ${directory}/QLStephen.qlgenerator"
    } ->

    file { $directory :
        ensure => 'directory',
        owner  => $::boxen_user
    } ->

    exec { 'unzip /tmp/qlstephen.zip' :
        cwd     => $directory,
        creates => "${directory}/QLStephen.qlgenerator"
    }
}