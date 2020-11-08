import { Controller } from "stimulus"

export default class extends Controller {
    connect() {
        $(document).bind('click', this.hideDropdowns)
    }

    disconnect() {
        $(document).unbind('click', this.hideDropdowns)
    }

    hideDropdowns(event) {
        if (! $(event.target).parents().hasClass("drop-down")) { $(".drop-down .options ul").hide(); }
    }

    toggleDropdown(event) {
        event.preventDefault();
        $(".drop-down .options ul").toggle();
    }

    selectDropdown(event) {
        event.preventDefault();

        let $event = $(event.currentTarget)
        let selectedOptionText = $(".drop-down .selected a")

        $('#address_address_type_id').val($event.data('address-type-id'))
        selectedOptionText.text($event.text());
        selectedOptionText.parent().removeClass('optional');
        $(".drop-down .options ul").hide();
    }
}
