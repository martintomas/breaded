import { ShopBasketMutation } from "../mutations/ShopBasketMutation";
import { QuerySelectorBuilder } from "./QuerySelectorBuilder";
import { ShoppingButtonUpdater } from "./ShoppingButtonUpdater";

export class ShopBasketViewHelper {
    constructor(maxItems) {
        this.maxItems = Number(maxItems);
        this.shopBasketMutation = new ShopBasketMutation();
        this.querySelectorBuilder = new QuerySelectorBuilder('data-food-id');
        this.shoppingButtonUpdater = new ShoppingButtonUpdater(this.shopBasketMutation, this.querySelectorBuilder);
    }

    updateShoppingBasket() {
        if(this.shopBasketMutation.numOfItems() === 0) {
            this.deactivateShoppingBasket();
        } else {
            this.activateShoppingBasket();
        }
        this.updateShoppingDashboard();
        this.shoppingButtonUpdater.update();
    }

    activateShoppingBasket() {
        $('span.no-breads-title').removeClass('active');
        $('div.selectedBreadsActive').addClass('active')
    }

    deactivateShoppingBasket() {
        $('span.no-breads-title').addClass('active');
        $('div.selectedBreadsActive').removeClass('active')
    }

    updateShoppingDashboard() {
        if(document.getElementById('shopping-basket') == null) { return; }

        let query = this.querySelectorBuilder.build(this.shopBasketMutation.itemIds(), '.shopping-basket-item', '#shopping-basket-frame');

        document.querySelector('.selectedItems .size-of-basket').innerHTML = this.shopBasketMutation.numOfItems();
        document.querySelector('#shopping-basket .number-selected-breads').innerHTML = this.shopBasketMutation.itemIds().length;
        this.updateConfirmButton()

        $.each(this.shopBasketMutation.data, (i, foodValues) => this.addNewBasketItemFor(foodValues));
        $('.shopping-basket-item').not(query).remove();
    }

    updateConfirmButton() {
        if(this.shopBasketMutation.numOfItems() === this.maxItems) {
            $('.selectedItems button.shopping-basket-confirm').addClass('active')
        } else {
            $('.selectedItems button.shopping-basket-confirm').removeClass('active')
        }
    }

    addNewBasketItemFor(foodValues) {
        if($('.shopping-basket-item[data-food-id="'+ foodValues.id +'"]').length !== 0) { return; }

        let element = document.getElementById('shopping-basket-frame').cloneNode(true)
        element.style.display = 'block';
        element.removeAttribute('id')
        element.dataset.foodId = foodValues.id;
        element.querySelector(".food-name").innerHTML = foodValues.foodName
        element.querySelector('.dec.button').dataset.foodId = foodValues.id
        element.querySelector('.dec.button').dataset.foodName = foodValues.foodName
        element.querySelector('.inc.button').dataset.foodId = foodValues.id
        element.querySelector('.inc.button').dataset.foodName = foodValues.foodName
        document.querySelector('#shopping-basket .shopping-basket-items').appendChild(element);
    }
}
