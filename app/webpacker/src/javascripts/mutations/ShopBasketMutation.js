import { ShopBasketStorage } from "../storages/ShopBasketStorage";

export class ShopBasketMutation {
    constructor() {
        this.basketStorage = ShopBasketStorage.getStorage();
        this.breads = this.basketStorage.storage.breads;
    }

    addFoodItem(foodId, food_name) {
        if(this.breads[foodId]) {
            this.breads[foodId].amount += 1;
        } else {
            this.breads[foodId] = { food_name: food_name, amount: 1 }
        }
        this.basketStorage.save();
    }

    removeFoodItem(foodId) {
        if(this.breads[foodId]) {
            if(this.breads[foodId].amount === 1) {
                delete this.breads[foodId]
            } else {
                this.breads[foodId].amount -= 1;
            }
        }
        this.basketStorage.save();
    }

    foodItems() {
        return this.breads;
    }

    sumOfFoodItems() {
        let sum = 0
        $.each(this.foodItems(), (foodId, foodValues) => {
            sum += foodValues.amount
        });
        return sum;
    }

    getAmountOf(foodId) {
        if(this.breads[foodId]) {
            return this.breads[foodId].amount
        } else {
            return 0;
        }
    }
}
