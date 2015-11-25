reg = require "error-registry"

reg.registerError "notfound", {status: 404, message: "resource not found"}
reg.registerError "exists", {status: 422, message: "resource already exists"}
reg.registerError "auth", {status: 401, message: "auth failed"}
reg.registerError "balance", {status: 402, message: "balance not sufficient"}
