import { Controller } from "stimulus"
import { ShopBasketStorage } from "../../storages/ShopBasketStorage";

export default class extends Controller {
    static targets = [ "form" ]

    initialize() {
        this.basketStorage = ShopBasketStorage.getStorage();
    }

    formSubmitted(event) {
        event.preventDefault();
        this.addBasketItems();
        this.formTarget.submit();
    }

    addBasketItems() {
        let basketItemsInput = document.querySelector('input[name="basket_items"]');
        console.log(basketItemsInput)
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
}
