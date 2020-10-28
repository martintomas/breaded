import { Controller } from "stimulus"
import { ShopBasketStorage } from "../storages/ShopBasketStorage";
import { FormHelper } from "../services/FormHelper";
import { SubscriptionPayment } from "../services/SubscriptionPayment";

export default class extends Controller {
    static targets = [ "form", "button", "card" ]

    initialize() {
        this.basketStorage = ShopBasketStorage.getStorage();
        this.errorsArea = $('#error_explanation > ul');
        this.subscriptionPayment = new SubscriptionPayment(this.cardTarget, this.buttonTarget);
        this.confirmedData = null;
        this.paid = false;
    }

    connect() {
        this.subscriptionPayment.show();
    }

    disconnect() {
        this.subscriptionPayment.destroyCardFields();
    }

    formSubmitted(event) {
        event.preventDefault();
        this.buttonTarget.disabled = true;
        this.processWithFlow();
    }

    confirmForm() {
        this.buttonTarget.value = this.buttonTarget.dataset.confirmText;
        this.addBasketItems();

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
                    this.confirmedData = data.response;
                    this.processWithFlow()
                }
            }
        });
    }

    doPayment() {
        this.buttonTarget.value = this.buttonTarget.dataset.processingPayment;

        this.subscriptionPayment.payFor(this.confirmedData.subscription_id, () => {
            this.paid = true
            this.processWithFlow();
        });
    }

    processWithFlow() {
        if(this.confirmedData === null) {
            this.confirmForm();
        } else if(!this.paid) {
            this.doPayment();
        } else {
            this.basketStorage.reset();
            location.href = this.data.get('on-success-url');
        }
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
