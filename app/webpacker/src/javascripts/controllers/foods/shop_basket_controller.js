import { Controller } from "stimulus"
import { ShopBasketMutation } from "../../mutations/ShopBasketMutation";
import { ShopBasketViewHelper } from "../../services/foods/ShopBasketViewHelper";

export default class extends Controller {
    initialize() {
        this.shopBasketMutation = new ShopBasketMutation();
        this.shopBasketViewHelper = new ShopBasketViewHelper(this.data.get('maxItems'));
    }

    connect() {
        this.shopBasketViewHelper.updateShoppingBasket();
    }

    addItem(event) {
        if(this.shopBasketMutation.numOfItems() >= this.data.get('maxItems')) { return; }

        event = $(event.target);
        this.shopBasketMutation.addFoodItem(event.data('foodId'), event.data('foodName'));
        this.shopBasketViewHelper.updateShoppingBasket();
    }

    removeItem(event) {
        if(this.shopBasketMutation.numOfItems() <= 0) { return; }

        event = $(event.target);
        this.shopBasketMutation.removeFoodItem(event.data('foodId'));
        this.shopBasketViewHelper.updateShoppingBasket();
    }

    openBasket() {
        $('#shopping-basket .shopping-basket-items').addClass('active');
        $('#shopping-basket .close-basket-button').addClass('active');
        $('#shopping-basket .open-basket-button').removeClass('active');
    }

    closeBasket() {
        $('#shopping-basket .shopping-basket-items').removeClass('active');
        $('#shopping-basket .close-basket-button').removeClass('active');
        $('#shopping-basket .open-basket-button').addClass('active');
    }
}
