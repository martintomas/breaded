export class BaseStorage {
    constructor(storageName, defaultStructure) {
        this.storageName = storageName;
        this.defaultStructure = defaultStructure;
        this.loadStorage();
    }

    loadStorage() {
        if(window.sessionStorage.getItem(this.storageName)) {
            this.storage = JSON.parse(window.sessionStorage.getItem(this.storageName));
        } else {
            this.defaultStructure['version'] = process.env.FE_VERSION;
            this.storage = this.defaultStructure;
        }
    }

    reset() {
        window.sessionStorage.removeItem(this.storageName);
    }

    save() {
        window.sessionStorage.setItem(this.storageName, JSON.stringify(this.storage));
    }
}
