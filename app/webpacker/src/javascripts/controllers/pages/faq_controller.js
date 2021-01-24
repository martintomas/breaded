import { Controller } from "stimulus"

export default class extends Controller {
    showAnswer(event) {
        let $event = $(event.currentTarget);
        $event.toggleClass("faq-qustion-bold").children(".faq-triangle").toggleClass("faq-triangle-down");
        $event.siblings(".faq-answer").toggleClass("faq-answer-show");
    }
}
