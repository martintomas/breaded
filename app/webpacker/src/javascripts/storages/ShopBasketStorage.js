import { BaseStorage} from "./BaseStorage";

const DEFAULT_STRUCTURE = { breads: [], surpriseMe: [] };

export class ShopBasketStorage extends BaseStorage {
    constructor(storageName) {
        super(storageName, DEFAULT_STRUCTURE);
    }

    static getStorage(storagePrefix) {
        let storageName = 'shop-basket'
        if(storagePrefix) { storageName += '-' + storagePrefix }

        if(document[storageName]) { return document[storageName]; }
        document[storageName] = new ShopBasketStorage(storageName);
        return document[storageName];
    }
}
