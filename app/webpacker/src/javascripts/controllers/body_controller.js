import { Controller } from "stimulus"

export default class extends Controller {
    static targets = ["menu"]

    connect() {
        this.checkIfInView();
    }

    checkIfInView() {
        let window_top_position = $(window).scrollTop();
        let window_bottom_position = (window_top_position + $(window).height());
        this.animateElements(window_top_position, window_bottom_position);
    }

    animateElements(window_top_position, window_bottom_position) {
        $.each($('.fade'), (index, element) => {
            element = $(element);
            let element_top_position = element.offset().top;
            let element_bottom_position = (element_top_position + element.outerHeight());

            //check to see if this current container is within viewport
            if ((element_bottom_position >= window_top_position) &&
                (element_top_position <= window_bottom_position)) {
                element.addClass('in-view');
            } else {
                element.removeClass('in-view');
            }
        });
    }
}
