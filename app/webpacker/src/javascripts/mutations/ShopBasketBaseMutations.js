export class ShopBasketBaseMutations {
    itemIds() {
        let ids = [];
        $.each(this.data, (i, item) => { ids.push(item.id) });
        return ids;
    }

    findBy(id) {
        let foundItem = null;
        $.each(this.data, (i, item) => {
            if(Number(item.id) === Number(id)) {
                foundItem = item;
            }
        });
        return foundItem;
    }

    numOfItems() {
        let sum = 0
        $.each(this.data, (i, item) => {
            if(item.amount) { sum += item.amount }
        });
        return sum;
    }

    getAmountOf(id) {
        let item = this.findBy(id);

        if(item) {
            return item.amount
        } else {
            return 0;
        }
    }
}
