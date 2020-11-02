import { Controller } from "stimulus"

require('slick-carousel');

export default class extends Controller {
    static targets = [ "popup"];

    initialize() {
        this.arrowImage = require('../../../../images/arrow.png');
        this.dateField = $('#delivery_date_from_field');
        this.dateFieldHidden = $('#delivery_date_from_hidden_field');
        this.selectedTimeField = $('div#calender ul.slide > li > span.active')[0];
    }

    connect() {
        this.updateDateFields(this.dateFieldHidden.val());
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

        this.updateDateFields(this.selectedTimeField.dataset.timestamp);
        this.close(event);
    }

    updateDateFields(timestamp) {
        if(timestamp === '') { return; }

        let date = new Date(timestamp);
        let dateString = date.getDate()  + "-" + (date.getMonth()+1) + "-" + date.getFullYear();
        this.dateField.val(dateString);
        this.dateFieldHidden.val(timestamp);
    }

    initializeSlider() {
        $('.dateSlider').not('.slick-initialized').slick({
            slidesToShow: 4,
            slidesToScroll: 1,
            autoplay: false,
            autoplaySpeed: 1500,
            infinite: false,
            arrows: false,
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
                    arrows: true,
                    slidesToShow: 2
                }
            }]
        });
    }
}
