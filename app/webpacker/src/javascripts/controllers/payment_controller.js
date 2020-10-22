import { Controller } from "stimulus"
import { ShopBasketStorage } from "../storages/ShopBasketStorage";

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
        if(document.basketItemsInput) {
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
}
