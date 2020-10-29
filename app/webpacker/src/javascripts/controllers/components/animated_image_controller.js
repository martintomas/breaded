import { Controller } from "stimulus"

import { ImageTrail } from '../../services/imageTrail'

export default class extends Controller {
    connect() {
        this.prepareImageTrailing();
    }

    disconnect() {
        if(document.imageTrail) {
            document.imageTrail.deactivate();
        }
    }

    prepareImageTrailing() {
        const imagesLoaded = require('imagesloaded')

        // Preload images
        const preloadImages = () => {
            return new Promise((resolve, reject) => {
                imagesLoaded(document.querySelectorAll('.content__img'), resolve);
            });
        };

        // And then..
        preloadImages().then(() => {
            // Remove the loader
            document.body.classList.remove('loading');
            document.imageTrail = new ImageTrail();
            document.imageTrail.activate();
        });
    }
}
