import { Controller } from "stimulus"

require('slick-carousel');

export default class extends Controller {
    initialize() {
        this.arrowImage = require('../../../images/arrow.png');
        this.dateField = $('#delivery_date_from_field');
        this.dateFieldHidden = $('#delivery_date_from_hidden_field');
    }

    connect() {
        this.updateDateField();
        this.initializeSlider();
    }

    selectDate(event) {
        this.dateFieldHidden.val(event.target.dataset.timestamp);
        this.updateDateField();
        window.location.hash = ''
    }

    updateDateField() {
        if(this.dateFieldHidden.val() === '') { return; }

        let date = new Date(this.dateFieldHidden.val());
        let dateString = date.getDate()  + "-" + (date.getMonth()+1) + "-" + date.getFullYear();
        this.dateField.val(dateString);
    }

    initializeSlider() {
        $('.dateSlider').slick({
            slidesToShow: 4,
            slidesToScroll: 1,
            autoplay: false,
            autoplaySpeed: 1500,
            infinite: false,
            arrows: true,
            prevArrow: '<div class="slick-prev"><img src="' + this.arrowImage + '" /></div>',
            nextArrow: '<div class="slick-next"><img src="' + this.arrowImage + '" /></div>',
            dots: false,
            pauseOnHover: false,
            responsive: [{
                breakpoint: 768,
                settings: {
                    slidesToShow: 3
                }
            }, {
                breakpoint: 520,
                settings: {
                    slidesToShow: 2
                }
            }]
        });
    }
}
