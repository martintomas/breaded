import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["confirmationPopup", "form"];

    open(event) {
        event.preventDefault();
        this.confirmationPopupTarget.classList.add("active");
    }

    close(event) {
        event.preventDefault();
        this.confirmationPopupTarget.classList.remove("active");
    }

    formSubmitted(event) {
        event.preventDefault();
        let checkedRadio = $("input[name='subscription[subscription_plan_id]']:checked");
        if(this.data.get('current') === checkedRadio.val()) { return Turbolinks.visit(this.data.get('root-url'));}

        this.copyDataToPopup(checkedRadio.closest('.plan-section'));
        this.open(event);
    }

    submitForm(event) {
        event.preventDefault();
        this.formTarget.submit();
    }

    copyDataToPopup(checkedOption) {
        let $target = $(this.confirmationPopupTarget);
        $target.find('.new-plan .description').html(checkedOption.find('.plan-description').html())
        $target.find('.new-plan .price').html(checkedOption.find('rate').html())
        if(Number(checkedOption.data('subscription-price')) > Number($target.data('current-price'))) {
            $(this.confirmationPopupTarget).find('.note .higher').show()
            $(this.confirmationPopupTarget).find('.note .lower').hide()
        } else {
            $(this.confirmationPopupTarget).find('.note .higher').hide()
            $(this.confirmationPopupTarget).find('.note .lower').show()
        }
    }
}
