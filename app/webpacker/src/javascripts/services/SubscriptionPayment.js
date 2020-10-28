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

export class SubscriptionPayment {
    constructor(cardField, cardButton) {
        this.stripe = Stripe(process.env.STRIPE_PUBLISHABLE_KEY);
        this.card = this.stripe.elements().create('card', { style: STYLE });
        this.cardField = cardField;
        this.cardButton = cardButton;
    }

    show() {
        this.card.mount(this.cardField);
        this.activateValidations();
    }

    destroyCardFields() {
        this.card.off();
    }

    payFor(subscriptionId, onSuccess) {
        this.cardButton.disabled = true;
        let billingName = $('#cardholder').val();

        this.stripe.createPaymentMethod({type: 'card', card: this.card, billing_details: { name: billingName }})
            .then((result) => {
                if (result.error) {
                    this.displayError(result.error);
                } else {
                    this.createSubscription(subscriptionId, result.paymentMethod.id, onSuccess);
                }
            });
    }

    createSubscription(subscriptionId, paymentMethodId, onSuccess) {
        $.ajax({
            type: 'POST',
            url: this.cardField.dataset.subscriptionUrl,
            data: { subscription_id: subscriptionId, payment_method_id: paymentMethodId },
            dataType: 'json',
            success: (data) => {
                if(data.errors.length > 0) {
                    this.displayError({ message: data.errors.first })
                } else {
                    if (data.response && data.response.status === 'active') {
                        onSuccess();
                    } else  {
                        this.handlePaymentThatRequiresCustomerAction(data.response, paymentMethodId, onSuccess)
                    }
                }
            }
        });
    }

    handlePaymentThatRequiresCustomerAction(subscription, paymentMethodId, onSuccess) {
        let paymentIntent = subscription.latest_invoice.payment_intent;

        if (paymentIntent.status === 'requires_action') {
            return this.stripe.confirmCardPayment(paymentIntent.client_secret, { payment_method: paymentMethodId })
                .then((result) => {
                    if (result.error) {
                        throw result;
                    } else {
                        if (result.paymentIntent.status === 'succeeded') {
                            onSuccess();
                        } else {
                            this.displayError({ message: this.cardField.dataset.defaultError });
                        }
                    }
                })
                .catch((result) => {
                    this.displayError(result.error);
                });
        } else {
            this.displayError({ message: this.cardField.dataset.defaultError });
        }
    }

    activateValidations() {
        this.card.on('change', event => {
            this.displayError(event.error);
        });
    }

    displayError(error) {
        let displayError = document.getElementById('card-errors');
        if (error) {
            this.resetCardButton()
            displayError.textContent = error.message;
        } else {
            displayError.textContent = '';
        }
    }

    resetCardButton() {
        this.cardButton.value = this.cardButton.dataset.originText;
        this.cardButton.disabled = false;
    }
}
