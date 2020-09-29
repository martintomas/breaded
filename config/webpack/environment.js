const { environment } = require('@rails/webpacker')
const jquery = require('./plugins/jquery')
const env = require('./plugins/env')

environment.plugins.prepend('jquery', jquery)
environment.plugins.prepend('env', env)
module.exports = environment
