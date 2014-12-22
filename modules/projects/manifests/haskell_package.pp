# install a haskell package through cabal
define projects::haskell_package() {

    Class['projects::haskell_platform'] ->

    exec { "cabal install ${name}" :
        unless => "ghc-pkg list | grep ${name} --ignore-case --silent"
    }
}
