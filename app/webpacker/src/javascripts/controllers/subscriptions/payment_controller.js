import { Controller } from "stimulus"
import { ShopBasketStorage } from "../../storages/ShopBasketStorage";

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
    static targets = [ "form", "button", "card", "billingAddressCheckbox", "cardHolderName", "addressLine", "street", "city", "postalCode" ]

    initialize() {
        this.errorsArea = $('#error_explanation > ul');
        this.stripe = Stripe(process.env.STRIPE_PUBLISHABLE_KEY);
        this.card = this.stripe.elements().create('card', { style: STYLE, hidePostalCode: true });
        this.originalButtonText = this.buttonTarget.value;
    }

    connect() {
        this.card.mount(this.cardTarget);
        this.activateValidations();
    }

    disconnect() {
        this.card.off();
        if(this.loadingInterval) { clearInterval(this.loadingInterval) }
    }

    formSubmitted(event) {
        event.preventDefault();
        this.buttonTarget.disabled = true;
        this.loadingInterval = setInterval(() => { this.buttonTarget.value += '.' }, 1000)

        this.stripe.createPaymentMethod({type: 'card', card: this.card, billing_details: this.collectData()})
            .then((result) => {
                if (result.error) {
                    this.printErrors([result.error.message]);
                } else {
                    this.createSubscription(result.paymentMethod.id);
                }
            });
    }

    createSubscription(paymentMethodId) {
        $.ajax({
            type: 'POST',
            url: this.data.get('subscription-url'),
            data: { subscription_id: this.data.get('subscription-id'), payment_method_id: paymentMethodId },
            dataType: 'json',
            success: (data) => {
                if(data.errors.length > 0) {
                    this.printErrors(data.errors);
                } else {
                    if (data.response && data.response.status === 'active') {
                        this.markAsPaid();
                    } else  {
                        this.handlePaymentThatRequiresCustomerAction(data.response, paymentMethodId)
                    }
                }
            }
        });
    }

    handlePaymentThatRequiresCustomerAction(subscription, paymentMethodId) {
        let paymentIntent = subscription.latest_invoice.payment_intent;

        if (paymentIntent.status === 'requires_action') {
            clearInterval(this.loadingInterval);
            this.stripe.confirmCardPayment(paymentIntent.client_secret, { payment_method: paymentMethodId })
                .then((result) => {
                    if (result.error) {
                        throw result;
                    } else {
                        if (result.paymentIntent.status === 'succeeded') {
                            this.markAsPaid();
                        } else {
                            this.printErrors([this.data.get('default-error')]);
                        }
                    }
                })
                .catch((result) => {
                    this.printErrors([result.error.message]);
                });
        } else {
            this.printErrors([this.data.get('default-error')]);
        }
    }

    markAsPaid() {
        ShopBasketStorage.getStorage().reset();
        Turbolinks.clearCache();
        Turbolinks.visit(this.data.get('on-success-url'));
    }

    collectData() {
        let address = {}

        if(this.billingAddressCheckboxTarget.checked) {
            address = {
                city: this.cityTarget.dataset.defaultValue,
                country: 'GB',
                line1: this.streetTarget.dataset.defaultValue,
                line2: this.addressLineTarget.dataset.defaultValue,
                postal_code: this.postalCodeTarget.dataset.defaultValue,
                state: 'United Kingdom' }
        } else {
            address = {
                city: this.cityTarget.value,
                country: 'GB',
                line1: this.streetTarget.value,
                line2: this.addressLineTarget.value,
                postal_code: this.postalCodeTarget.value,
                state: 'United Kingdom' }
        }
        return { name: this.cardHolderNameTarget.value, address: address }
    }

    toggleAddress() {
        if(this.billingAddressCheckboxTarget.checked) {
            $('.billing-address-section').css('display', 'none');
        } else {
            $('.billing-address-section').css('display', 'block');
        }
    }

    activateValidations() {
        this.card.on('change', event => {
            if(event.error) {
                this.printErrors([event.error.message]);
            } else {
                $(this.errorsArea).empty();
            }
        });
    }

    printErrors(errors) {
        $(this.errorsArea).empty();
        this.resetPaymentButton();

        $.each(errors, (i, error) => {
            let element = document.createElement("LI");
            element.innerText = error;
            this.errorsArea[0].appendChild(element);
        });
    }

    resetPaymentButton() {
        this.buttonTarget.disabled = false;
        this.buttonTarget.value = this.originalButtonText;
        if(this.loadingInterval) { clearInterval(this.loadingInterval) }
    }
}
