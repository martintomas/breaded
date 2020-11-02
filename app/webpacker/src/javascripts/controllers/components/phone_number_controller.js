import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ "phoneNumberInput", "verifiedIcon", "popup", "verifyPhoneLink", "phoneTokenInput", "sentVerificationErrors", "confirmVerificationErrors" ]

    connect() {
        if(this.phoneNumberInputTarget.value === '') {
            this.markAsNotVerified();
        } else {
            this.markAsVerified();
        }
    }

    open(event) {
        event.preventDefault();
        this.popupTarget.classList.add("active");
    }

    close(event) {
        event.preventDefault();
        this.popupTarget.classList.remove("active");
    }

    sendVerificationCode(event) {
        event.preventDefault();
        this.resetErrors()

        $.ajax({
            type: 'POST',
            url: this.data.get('sms-verification-url'),
            data: {
                phone_number: this.phoneNumberInputTarget.value
            },
            dataType: 'json',
            success: (data) => {
                if(data.errors.length > 0) {
                    this.showError(data.errors[0]);
                } else {
                    this.open(event);
                }
            }
        });
    }

    verifyVerificationCode(event) {
        event.preventDefault();
        this.resetErrors()

        $.ajax({
            type: 'POST',
            url: this.data.get('code-verification-url'),
            data: {
                phone_token: this.phoneTokenInputTarget.value
            },
            dataType: 'json',
            success: (data) => {
                if(data.errors.length > 0) {
                    this.showError(data.errors[0]);
                } else {
                    this.markAsVerified();
                    this.close(event);
                }
            }
        });
    }

    markAsVerified() {
        this.verifyPhoneLinkTarget.classList.remove("active");
        this.verifiedIconTarget.classList.add("active");
    }

    markAsNotVerified() {
        this.verifyPhoneLinkTarget.classList.add("active");
        this.verifiedIconTarget.classList.remove("active");
    }

    resetErrors() {
        this.sentVerificationErrorsTarget.innerHTML = '';
        this.confirmVerificationErrorsTarget.innerHTML = '';
    }

    showError(value) {
        this.sentVerificationErrorsTarget.innerHTML = value;
        this.confirmVerificationErrorsTarget.innerHTML = value
    }
}
