import { BaseStorage} from "./BaseStorage";

const DEFAULT_STRUCTURE = { breads: {} };

export class ShopBasketStorage extends BaseStorage {
    constructor() {
        super('shop-basket', DEFAULT_STRUCTURE);
    }

    static getStorage() {
        if(document.basketStorage) { return document.basketStorage; }

        document.basketStorage = new ShopBasketStorage();
        return document.basketStorage;
    }
}
