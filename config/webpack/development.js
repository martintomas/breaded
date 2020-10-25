process.env.NODE_ENV = process.env.NODE_ENV || 'development'
process.env.STRIPE_PUBLISHABLE_KEY = 'pk_test_51HeFW8I4g05dLynGZJRfdRRsDN27EsdFzXdp2mKrQ58QqhgVBIPENjzPUFvbQs1PAph7ZkVKSnSKyIAhpmnQFMI6007G0NWpTK'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
