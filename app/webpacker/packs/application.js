// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

require.context('../images', true);
require.context('../fonts', true);

//import '../src/javascripts/imagesloaded.pkgd.min'
import '../src/javascripts/TweenMax.min' // TODO: deprecated, fix at future
import '../src/javascripts/animatedImage'

import '../src/javascripts/controllers'
import '../src/javascripts/script'

import './stylesheets.scss'
