import { Controller } from "stimulus"
import { ShopBasketMutation } from "../mutations/ShopBasketMutation";
import { ShopBasketViewHelper } from "../services/ShopBasketViewHelper";

export default class extends Controller {
    initialize() {
        this.shopBasketMutation = new ShopBasketMutation();
        this.shopBasketViewHelper = new ShopBasketViewHelper();
    }

    connect() {
        this.shopBasketViewHelper.updateShoppingBasket();
    }

    addItem(event) {
        if(this.shopBasketMutation.sumOfFoodItems() >= this.data.get('max-items')) { return; }

        event = $(event.target);
        this.shopBasketMutation.addFoodItem(event.data('food-id'), event.data('food-name'));
        this.shopBasketViewHelper.updateShoppingBasket();
    }

    removeItem(event) {
        if(this.shopBasketMutation.sumOfFoodItems() <= 0) { return; }

        event = $(event.target);
        this.shopBasketMutation.removeFoodItem(event.data('food-id'));
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
