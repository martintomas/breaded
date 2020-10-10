export class BaseStorage {
    constructor(storageName, defaultStructure) {
        this.storageName = storageName;
        this.loadStorage(storageName, defaultStructure);
    }

    loadStorage(storageName, defaultStructure) {
        if(window.sessionStorage.getItem(storageName)) {
            this.storage = JSON.parse(window.sessionStorage.getItem(storageName));
        } else {
            defaultStructure['version'] = process.env.FE_VERSION;
            this.storage = defaultStructure;
        }
    }

    save() {
        window.sessionStorage.setItem(this.storageName, JSON.stringify(this.storage));
    }
}
