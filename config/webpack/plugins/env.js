const webpack = require('webpack')

module.exports = new webpack.EnvironmentPlugin({
    SENTRY_DSN_FE: 'https://7957b64fa06f4edb844ad68af81e3535@o446163.ingest.sentry.io/5443818',
    FE_VERSION: '0.0.1'
});
