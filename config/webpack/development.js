process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const webpack = require('webpack')
const dotenv = require('dotenv')

const dotenvFiles = ['.env']
dotenvFiles.forEach((dotenvFile) => {
    dotenv.config({ path: dotenvFile, silent: true })
})

environment.plugins.insert(
    "Environment",
    new webpack.EnvironmentPlugin(process.env)
)

module.exports = environment.toWebpackConfig()
