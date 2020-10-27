import { Controller } from "stimulus"
import { ShopBasketStorage } from "../storages/ShopBasketStorage";
import { FormHelper } from "../services/FormHelper";

export default class extends Controller {
    static targets = [ "form", "button" ]

    initialize() {
        this.basketStorage = ShopBasketStorage.getStorage();
        this.errorsArea = $('#error_explanation > ul');
    }

    formSubmitted(event) {
        event.preventDefault();
        this.buttonTarget.disabled = true;
        this.addBasketItems();
        this.submitForm();
    }

    submitForm() {
        this.buttonTarget.value = this.buttonTarget.dataset.confirmText;

        $.ajax({
            type: 'POST',
            url: this.formTarget.action,
            data: new FormHelper(this.formTarget).serializedData(),
            dataType: 'json',
            success: (data) => {
                if(data.errors.length > 0) {
                    this.printErrors(data.errors);
                    window.scrollTo(0, this.errorsArea);
                } else {
                    this.basketStorage.reset();
                    this.redirectToCheckout(data.response.subscription_id, data.response.stripe_checkout)
                }
            }
        });
    }

    redirectToCheckout(subscriptionID, checkoutURL) {
        this.buttonTarget.value = this.buttonTarget.dataset.redirectText;

        $.ajax({
            type: 'POST',
            url: checkoutURL,
            data: {
                subscription_id: subscriptionID
            },
            dataType: 'json',
            success: (data) => {
                if(data.errors.length > 0) {
                    alert(data.errors[0].message);
                } else {
                    this.stripe.redirectToCheckout({ sessionId: data.response.id })
                }
            }
        });
    }

    addBasketItems() {
        let basketItemsInput = document.querySelector('input[name="basket_items"]');
        if(basketItemsInput === null) {
            basketItemsInput = document.createElement('input');
            basketItemsInput.setAttribute('type', 'hidden');
            basketItemsInput.setAttribute('name', 'basket_items');
            this.formTarget.appendChild(basketItemsInput);
        }
        basketItemsInput.setAttribute('value', JSON.stringify(this.getBasketItems()));
    }

    getBasketItems() {
        if(this.data.get('variant') === 'pick-up') {
            return this.basketStorage.storage.breads
        } else {
            return this.basketStorage.storage.surpriseMe
        }
    }

    printErrors(errors) {
        this.buttonTarget.value = this.buttonTarget.dataset.originText;
        this.buttonTarget.disabled = false;
        $(this.errorsArea).empty();

        $.each(errors, (i, error) => {
            let element = document.createElement("LI");
            element.innerText = error;
            this.errorsArea[0].appendChild(element);
        });
    }
}
