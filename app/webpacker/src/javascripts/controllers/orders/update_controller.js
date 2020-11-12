import confirmation_controller from "../subscriptions/confirmation_controller";

export default class extends confirmation_controller {
    static targets = [ "form", "addressPopup", "addressResultFirstPart", "addressResultSecondPart", "addressLine", "street", "city", "postalCode" ]

    addressPopupOpen(event) {
        event.preventDefault();
        this.addressPopupTarget.classList.add("active");
    }

    addressPopupClose(event) {
        event.preventDefault();
        this.addressPopupTarget.classList.remove("active");
    }

    addressUpdated(event) {
        event.preventDefault();
        $('#orders_update_former_address_line').val(this.addressLineTarget.value);
        $('#orders_update_former_street').val(this.streetTarget.value);
        $('#orders_update_former_city').val(this.cityTarget.value);
        $('#orders_update_former_postal_code').val(this.postalCodeTarget.value);
        this.addressResultFirstPartTarget.innerText = this.addressLineTarget.value + ', ' + this.streetTarget.value + ', ' + this.cityTarget.value;
        this.addressResultSecondPartTarget.innerText = this.postalCodeTarget.value;
        this.addressPopupClose(event);
    }
}
