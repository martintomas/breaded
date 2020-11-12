import new_controller from "./new_controller";

export default class extends new_controller {
    static targets = [ "button", "card", "billingAddressCheckbox", "cardHolderName", "addressLine", "street", "city", "postalCode" ]

    formSubmitted(event) {
        event.preventDefault();
        this.buttonTarget.disabled = true;

        this.stripe.confirmCardSetup(this.data.get('client-secret'), { payment_method: { card: this.card, billing_details: this.collectData() } })
            .then((result) => {
                if (result.error) {
                    this.printErrors([result.error.message]);
                } else {
                    this.markAsSuccess(result);
                }
            })
            .catch((result) => {
                this.printErrors([result.error.message]);
            });
    }

    markAsSuccess(response) {
        $.ajax({
            type: 'POST',
            url: this.data.get('payment-method-url'),
            data: { subscription_id: this.data.get('subscription-id'), payment_method_id: response.setupIntent.payment_method },
            dataType: 'json',
            success: (data) => {
                if(data.errors.length > 0) {
                    this.printErrors(data.errors);
                } else {
                    Turbolinks.visit(this.data.get('on-success-url'))
                }
            }
        });
    }
}
