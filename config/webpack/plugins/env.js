const webpack = require('webpack')

module.exports = new webpack.EnvironmentPlugin({
    NODE_ENV: 'development',
    SENTRY_DSN_FE: 'https://7957b64fa06f4edb844ad68af81e3535@o446163.ingest.sentry.io/5443818'
});
