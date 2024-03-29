import { Controller } from "stimulus"

require('slick-carousel');

export default class extends Controller {
    static targets = [ "popup"];

    initialize() {
        this.arrowImage = require('../../../../images/arrow.png');
        this.dateField = $('#delivery_date_from_field');
        this.dateFieldHidden = $('#delivery_date_from_hidden_field');
        this.selectedTimeField = $('div#calender ul.slide > li > span.active')[0];
        this.numItems = $('div#calender ul.slide > li:nth-of-type(1)').length;
    }

    connect() {
        this.updateDateFields();
        this.initializeSlider();
    }

    open(event) {
        event.preventDefault();
        this.popupTarget.classList.add("active");
    }

    close(event) {
        event.preventDefault();
        this.popupTarget.classList.remove("active");
    }

    selectDate(event) {
        event.preventDefault();
        if(this.selectedTimeField) { this.selectedTimeField.classList.remove("active"); }
        this.selectedTimeField = event.target
        this.selectedTimeField.classList.add("active");
    }

    submit(event) {
        event.preventDefault();
        if(this.selectedTimeField === undefined) { return this.close(event); }

        this.updateDateFields();
        this.close(event);
    }

    updateDateFields() {
        if(this.selectedTimeField == null) { return; }
        this.dateField.val(this.selectedTimeField.dataset.timestampPretty);
        this.dateFieldHidden.val(this.selectedTimeField.dataset.timestamp);
    }

    initializeSlider() {
        $('.dateSlider').not('.slick-initialized').slick({
            slidesToShow: 4,
            slidesToScroll: 1,
            autoplay: false,
            autoplaySpeed: 1500,
            infinite: false,
            arrows: (this.numItems > 4),
            prevArrow: '<div class="slick-prev"><img src="' + this.arrowImage + '" /></div>',
            nextArrow: '<div class="slick-next"><img src="' + this.arrowImage + '" /></div>',
            dots: false,
            pauseOnHover: false,
            responsive: [{
                breakpoint: 768,
                settings: {
                    arrows: (this.numItems > 3),
                    slidesToShow: 3
                }
            }, {
                breakpoint: 520,
                settings: {
                    arrows: (this.numItems > 2),
                    slidesToShow: 2
                }
            }]
        });
    }
}
