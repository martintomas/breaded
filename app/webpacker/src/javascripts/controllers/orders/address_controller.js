import { Controller } from "stimulus"
import { FormHelper } from "../../services/FormHelper";

export default class extends Controller {
    static targets = ["popup", "form", "button", "addressLine"];

    open(event) {
        event.preventDefault();
        this.popupTarget.classList.add("active");
    }

    close(event) {
        event.preventDefault();
        this.popupTarget.classList.remove("active");
    }

    formSubmitted(event) {
        event.preventDefault();

        $.ajax({
            type: 'POST',
            url: this.formTarget.action,
            data: new FormHelper(this.formTarget).serializedData(),
            dataType: 'json',
            success: (data) => {
                this.addressLineTarget.innerHTML = data.address_line + ', ' + data.street + ' ' + data.city + ' - ' + data.postal_code;
                this.buttonTarget.disabled = false;
                this.close(event);
            }
        });
    }
}
