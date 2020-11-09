import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ "infoPopup"];

    connect() {
        $(document).bind('click', this.hideDropdowns)
    }

    disconnect() {
        $(document).unbind('click', this.hideDropdowns)
    }

    open(event) {
        event.preventDefault();
        this.infoPopupTarget.classList.add("active");
    }

    close(event) {
        event.preventDefault();
        this.infoPopupTarget.classList.remove("active");
    }

    hideDropdowns(event) {
        if (! $(event.target).parents().hasClass("drop-down")) { $(".drop-down .options ul").hide(); }
    }

    toggleDropdown(event) {
        event.preventDefault();
        let orderId = event.currentTarget.dataset.orderId;
        $(".drop-down[data-order-id=" + orderId + "] .options ul").toggle();
    }

    dropdownSelected(event) {
        event.preventDefault();

        let $event = $(event.currentTarget)
        $.ajax({
            type: 'POST',
            url: $event.data('url'),
            dataType: 'json',
            success: (data) => {
                $('div.OrderSec[data-order-id=' + $event.data('order-id') +']').html(data.order_detail);
            }
        })
    }

    confirmCopyAction(event) {
        this.dropdownSelected(event);
    }
}
