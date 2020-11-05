export class ShoppingButtonUpdater {
    constructor(storageMiddleware, querySelector) {
        this.storageMiddleware = storageMiddleware;
        this.querySelector = querySelector;
    }

    update() {
        let query = this.querySelector.build(this.storageMiddleware.itemIds(), '.dec.button');

        $(query).each((i, button) => {
            let amount = this.storageMiddleware.getAmountOf(button.getAttribute(this.querySelector.dataTagAttribute));
            this.setButtonOf(button, amount);
        });
        $('.dec.button').not(query).each((i, button) => this.setButtonOf(button, 0))
    }

    setButtonOf(target, toValue) {
        let $target = $(target);
        let pickedFoodSection = $target.closest('ul.itemsection').find('.picked-food');

        $target.parent().find('input').val(toValue);
        if(toValue > 0) {
            pickedFoodSection.addClass('active');
        } else {
            pickedFoodSection.removeClass('active');
        }
    }
}
