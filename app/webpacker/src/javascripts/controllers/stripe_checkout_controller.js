import { Controller } from "stimulus"
import { ShopBasketStorage } from "../storages/ShopBasketStorage";

export default class extends Controller {
    static targets = ["waitingText"]

    initialize() {
        this.stripe = Stripe(process.env.STRIPE_PUBLISHABLE_KEY)
        this.basketStorage = ShopBasketStorage.getStorage();
    }

    connect() {
        this.interval = setInterval(() => this.waitingTextTarget.innerHTML += '.', 1000)
        this.basketStorage.reset();
        this.redirectToCheckout();
    }

    disconnect() {
        clearInterval(this.interval);
    }

    redirectToCheckout() {
        $.ajax({
            type: 'POST',
            url: this.data.get('url'),
            data: {
                subscription_id: this.data.get('subscription-id')
            },
            dataType: 'json',
            success: (data) => {
                if(data.errors.length > 0) {
                    alert(data.errors[0].message);
                } else {
                    this.stripe.redirectToCheckout({ sessionId: data.response.id })
                }
            },
            statusCode: {
                403: () => {
                    alert("forbidden");
                }
            }
        });
    }
}
