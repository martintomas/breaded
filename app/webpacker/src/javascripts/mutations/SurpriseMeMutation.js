import { ShopBasketStorage } from "../storages/ShopBasketStorage";
import { ShopBasketBaseMutations } from "./ShopBasketBaseMutations";

export class SurpriseMeMutation extends ShopBasketBaseMutations {
    constructor() {
        super();
        this.basketStorage = ShopBasketStorage.getStorage();
        this.data = this.basketStorage.storage.surpriseMe;
    }

    addItem(tagId, tagName, section, initialValue = null) {
        let tagItem = this.findBy(tagId);

        if(tagItem) {
            tagItem.amount += 1;
        } else {
            this.data.push({ id: tagId, tagName: tagName, section: section, amount: initialValue });
        }
        this.basketStorage.save();
    }

    removeItem(tagId) {
        let tagItem = this.findBy(tagId);

        if(tagItem) {
            if(tagItem.amount === 1 || tagItem.amount === null) {
                this.data.splice(this.data.indexOf(tagItem), 1);
            } else {
                tagItem.amount -= 1;
            }
        }
        this.basketStorage.save();
    }
}
