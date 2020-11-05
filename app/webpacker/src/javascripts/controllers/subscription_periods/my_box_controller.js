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

    selectDropdown(event) {
        event.preventDefault();

        let $event = $(event.currentTarget)
        let orderId = event.currentTarget.dataset.orderId;

        let hiddenOption = $(".drop-down[data-order-id=" + orderId + "] .options ul li[style*='display: none']")
        let selectedOption = $(".drop-down[data-order-id=" + orderId + "] .selected a")
        let selectedOptionText = $(".drop-down[data-order-id=" + orderId + "] .selected a span")

        selectedOptionText.text($event.text());
        selectedOption.attr('data-button-action', $event.data('button-action'))
        selectedOption.attr('data-copy-order-id', $event.data('copy-order-id'))
        $event.parent().hide();
        hiddenOption.show();
        $(".drop-down .options ul").hide();
    }

    submitAction(event) {
        event.preventDefault();

        let orderId = event.currentTarget.dataset.orderId;
        let selectedOption = $(".drop-down[data-order-id=" + orderId + "] .selected a")[0]
        if (selectedOption.dataset.buttonAction === 'copy') {
            this.triggerCopyAction(orderId, selectedOption.dataset.copyOrderId);
        } else {
            Turbolinks.visit('/orders/' + orderId + '/edit')
        }
    }

    triggerCopyAction(orderId, copyOrderId) {
        $.ajax({
            type: 'POST',
            url: "/orders/" + orderId + "/copy",
            data: { copy_order_id: copyOrderId },
            dataType: 'json',
            success: (data) => {
                if(data.errors.length > 0) {
                    alert(data.errors[0]);
                } else {
                    $('section.order-detail-section[data-order-id=' + orderId +']')[0].innerHTML = data.order_detail;
                }
            }
        })
    }
}
