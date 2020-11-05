import { ShopBasketStorage } from "../storages/ShopBasketStorage";
import { ShopBasketBaseMutations } from "./ShopBasketBaseMutations";

export class ShopBasketMutation extends ShopBasketBaseMutations {
    constructor(storagePrefix) {
        super();
        this.basketStorage = ShopBasketStorage.getStorage(storagePrefix);
        this.data = this.basketStorage.storage.breads;
    }

    addFoodItem(foodId, foodName) {
        let foodItem = this.findBy(foodId);

        if(foodItem) {
            foodItem.amount += 1;
        } else {
            this.data.push({ id: foodId, foodName: foodName, amount: 1 })
        }
        this.basketStorage.save();
    }

    removeFoodItem(foodId) {
        let foodItem = this.findBy(foodId);

        if(foodItem) {
            if(foodItem.amount === 1) {
                this.data.splice(this.data.indexOf(foodItem), 1);
            } else {
                foodItem.amount -= 1;
            }
        }
        this.basketStorage.save();
    }
}
