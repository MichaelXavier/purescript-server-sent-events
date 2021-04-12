{ name = "server-sent-events"
, license = "MIT"
, repository = "https://github.com/MichaelXavier/purescript-server-sent-events"
, dependencies =
  [ "console"
  , "effect"
  , "functions"
  , "maybe"
  , "prelude"
  , "psci-support"
  , "web-events"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
