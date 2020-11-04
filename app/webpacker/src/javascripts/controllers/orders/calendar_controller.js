import calendar_controller from "../components/calendar_controller";

export default class extends calendar_controller {
    static targets = [ "popup"];

    initialize() {
        this.arrowImage = require('../../../../images/arrow.png');
        this.selectedTimeField = $('div#calender[data-order-id='+ this.data.get('order-id') +'] ul.slide > li > span.active')[0];
    }

    connect() {
        this.initializeSlider();
    }

    submit(event) {
        event.preventDefault();

        $.ajax({
            type: 'POST',
            url: "/orders/" + this.data.get('order-id') + "/update_date",
            data: { timestamp: this.selectedTimeField.dataset.timestamp },
            dataType: 'json',
            success: (data) => {
                $('span.date-time.day-in-month[data-order-id='+ this.data.get('order-id') +']')[0].innerHTML = data.delivery_date
                $('span.date-time.time-range[data-order-id='+ this.data.get('order-id') +']')[0].innerHTML = data.delivery_date_range
                this.close(event);
            }
        })
    }
}
