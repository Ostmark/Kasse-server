barcode = require "../app/models/barcode"
bluebird = require "bluebird"

bluebird.all (barcode.generate_namespace() for _ in [1..5]), () -> process.exit 0
