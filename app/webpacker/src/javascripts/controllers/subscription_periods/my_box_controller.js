import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ "infoPopup"];

    connect() {
        $(document).bind('click', this.hideDropdowns)
    }

    disconnect() {
        if(document.clearCache) {
            document.clearCache -= 1;
            Turbolinks.clearCache();
        }
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
            console.log('PICK YOUR BREADS!');
        }
    }
    
    triggerCopyAction(orderId, copyOrderId) {
        Turbolinks.scroll['top'] = document.scrollingElement.scrollTop;
        document.clearCache = 2;
        Turbolinks.visit('/orders/' + orderId + '/copy/?copy_order_id=' + copyOrderId);
    }
}
