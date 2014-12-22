# installs a python package globally into python2 *and* python 3
define projects::global_python_package() {
    exec { "pip2 install ${name}" :
        unless => "pip2 freeze list | grep ${name} --silent"
    }
    exec { "pip3 install ${name}" :
        unless => "pip3 freeze list | grep ${name} --silent"
    }
}