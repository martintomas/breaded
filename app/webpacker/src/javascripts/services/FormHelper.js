export class FormHelper {
    constructor(form) {
        this.form = $(form);
    }

    serializedData() {
        let unindexed_array = this.form.serializeArray();
        let indexed_array = {};

        $.map(unindexed_array, (n, i) => {
            indexed_array[n['name']] = n['value'];
        });
        return indexed_array;
    }
}
