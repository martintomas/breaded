import { Controller } from "stimulus"

export default class extends Controller {
    static targets = [ "phoneNumberInput", "phoneTokenInput", "sentVerificationErrors", "confirmVerificationErrors" ]

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
                    window.location.hash = '#phoneNumberCode'
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
                    window.location.hash = ''
                }
            }
        });
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
