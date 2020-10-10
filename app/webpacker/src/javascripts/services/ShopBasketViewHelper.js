import { ShopBasketMutation } from "../mutations/ShopBasketMutation";

export class ShopBasketViewHelper {
    constructor() {
        this.shopBasket = new ShopBasketMutation();
    }

    updateShoppingBasket() {
        if(this.shopBasket.sumOfFoodItems() === 0) {
            this.deactivateShoppingBasket();
        } else {
            this.activateShoppingBasket();
        }
        this.updateShoppingDashboard();
        this.updateShoppingButtons();
    }

    activateShoppingBasket() {
        $('span.no-breads-title').removeClass('active');
        $('div.selectedBreadsActive').addClass('active')
    }

    deactivateShoppingBasket() {
        $('span.no-breads-title').addClass('active');
        $('div.selectedBreadsActive').removeClass('active')
    }

    updateShoppingButtons() {
        let query = this.buildSelectorQuery(Object.keys(this.shopBasket.foodItems()), '.dec.button');

        $(query).each((i, button) => this.setButtonOf(button, this.shopBasket.getAmountOf(button.dataset.foodId)));
        $('.dec.button').not(query).each((i, button) => this.setButtonOf(button, 0))
    }

    setButtonOf(target, toValue) {
        $(target).parent().find('input').val(toValue);
    }

    updateShoppingDashboard() {
        if(document.getElementById('shopping-basket') == null) { return; }

        let foodIds = Object.keys(this.shopBasket.foodItems());
        let query = this.buildSelectorQuery(foodIds, '.shopping-basket-item', '#shopping-basket-frame');

        document.querySelector('.selectedItems .size-of-basket').innerHTML = this.shopBasket.sumOfFoodItems();
        document.querySelector('#shopping-basket .number-selected-breads').innerHTML = foodIds.length;

        $.each(this.shopBasket.foodItems(), (foodId, foodValues) => this.addNewBasketItemFor(foodId, foodValues));
        $('.shopping-basket-item').not(query).remove();
    }

    addNewBasketItemFor(foodId, foodValues) {
        if($('.shopping-basket-item[data-food-id="'+ foodId +'"]').length !== 0) { return; }

        let element = document.getElementById('shopping-basket-frame').cloneNode(true)
        element.style.display = 'block';
        element.removeAttribute('id')
        element.dataset.foodId = foodId;
        element.querySelector(".food-name").innerHTML = foodValues.food_name
        element.querySelector('.dec.button').dataset.foodId = foodId
        element.querySelector('.dec.button').dataset.foodName = foodValues.food_name
        element.querySelector('.inc.button').dataset.foodId = foodId
        element.querySelector('.inc.button').dataset.foodName = foodValues.food_name
        document.querySelector('#shopping-basket .shopping-basket-items').appendChild(element);
    }

    buildSelectorQuery(foodIds, styles, initStyles = '') {
        let query = (initStyles === '') ? [] : [initStyles];
        $.each(foodIds, (i, foodId) => {
            query.push(styles + '[data-food-id="'+ foodId +'"]')
        })
        return query.join(',')
    }
}
