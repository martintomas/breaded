import { Controller } from "stimulus"

export default class extends Controller {
    connect() {
        $(document).bind('click', this.hideDropdowns)
        $(".drop-down .options ul").hide();
        if(!$('#contacts_subscription_period_id').val()) $(".options.box-option ul li").hide();
    }

    disconnect() {
        $(document).unbind('click', this.hideDropdowns)
    }

    hideDropdowns(event) {
        if ($(event.target).parents().is(".drop-down.month")) { $(".drop-down.box .options ul").hide(); }
        else if($(event.target).parents().is(".drop-down.box")) { $(".drop-down.month .options ul").hide(); }
        else { $(".drop-down .options ul").hide(); }
    }

    toggleMonthDropdown(event) {
        event.preventDefault();
        $(".drop-down.month .options ul").toggle();
    }

    toggleBoxDropdown(event) {
        event.preventDefault();
        $(".drop-down.box .options ul").toggle();
    }

    selectMonthDropdown(event) {
        event.preventDefault();

        let $event = $(event.currentTarget)
        let selectedOptionText = $(".drop-down.month .selected a span")

        this.refreshBoxes($event);

        $('#contacts_subscription_period_id').val($event.data('record-id'))
        selectedOptionText.text($event.text());
        $(".drop-down.month .options ul").hide();
    }

    selectBoxDropdown(event) {
        event.preventDefault();

        let $event = $(event.currentTarget)
        let selectedOptionText = $(".drop-down.box .selected a span")

        $('#contacts_order_id').val($event.data('record-id'));
        selectedOptionText.text($event.text());
        $(".drop-down.box .options ul").hide();
    }

    refreshBoxes($event) {
        $(".drop-down.box .selected a span").text($event.data('default-box'));
        $('#contacts_order_id').val(null);

        $(".options.box-option ul li").hide();
        $.each($event.data('boxes'), i => {
            let $box = $(".options.box-option ul li:nth-of-type("+ (i + 1) +")")
            $box.show();
            $box.data('record-id', $event.data('boxes')[i]);
        });
    }
}
