{ name = "purescript-server-sent-events"
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
