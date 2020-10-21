import { Controller } from "stimulus"
import { ShopBasketStorage } from "../storages/ShopBasketStorage";

const STYLE = {
    base: {
        color: '#32325d',
        fontFamily: '"Montserrat',
        fontSmoothing: 'antialiased',
        fontSize: '20px',
        '::placeholder': {
            color: '#aab7c4'
        }
    },
    invalid: {
        color: '#fa755a',
        iconColor: '#fa755a'
    }
}

export default class extends Controller {
    static targets = [ "card", "form" ]

    initialize() {
        this.basketStorage = ShopBasketStorage.getStorage();
        this.stripe = Stripe(process.env.STRIPE_PUBLISHABLE_KEY)
        this.card = this.stripe.elements().create('card', { style: STYLE, hidePostalCode: true });
    }

    connect() {
        this.card.mount(this.cardTarget);
        this.activateValidations();
    }

    disconnect() {
        this.card.off();
    }

    formSubmitted(event) {
        event.preventDefault();

        this.stripe.createToken(this.card).then( result => {
            if (result.error) {
                let errorElement = document.getElementById('card-errors');
                errorElement.textContent = result.error.message;
            } else {
                this.updateFormFieldsWith(result.token);
            }
        });
    }

    updateFormFieldsWith(token) {
        this.addTokenField(token);
        this.addBasketItems();
        this.formTarget.submit();
    }

    addTokenField(token) {
        if(document.tokenInput) {
            document.tokenInput.setAttribute('value', token.id)
        } else {
            document.tokenInput = document.createElement('input');
            document.tokenInput.setAttribute('type', 'hidden');
            document.tokenInput.setAttribute('name', 'stripe_token');
            document.tokenInput.setAttribute('value', token.id);
            this.formTarget.appendChild(document.tokenInput);
        }
    }

    addBasketItems() {
        if(document.basketItemsInput) {
            console.log(JSON.stringify(this.getBasketItems()))
            document.basketItemsInput.setAttribute('value', JSON.stringify(this.getBasketItems()));
        } else {
            document.basketItemsInput = document.createElement('input');
            document.basketItemsInput.setAttribute('type', 'hidden');
            document.basketItemsInput.setAttribute('name', 'basket_items');
            document.basketItemsInput.setAttribute('value', JSON.stringify(this.getBasketItems()));
            this.formTarget.appendChild(document.basketItemsInput);
        }
    }

    getBasketItems() {
        if(this.data.get('variant') === 'pick-up') {
            return this.basketStorage.storage.breads
        } else {
            return this.basketStorage.storage.surpriseMe
        }
    }

    activateValidations() {
        this.card.on('change', event => {
            let displayError = document.getElementById('card-errors');
            if (event.error) {
                displayError.textContent = event.error.message;
            } else {
                displayError.textContent = '';
            }
        });
    }
}
