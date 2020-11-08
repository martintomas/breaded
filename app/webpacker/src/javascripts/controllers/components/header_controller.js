import { Controller } from "stimulus"
import * as Sentry from "@sentry/browser";

export default class extends Controller {
    static targets = [ "menu" ]

    toggleMobMenu() {
        $(this.menuTarget).toggleClass("mobMenu");
    }

    hideHeader() {
        let menu = $(this.menuTarget);
        let st = $(window).scrollTop();
        let lastScrollTop = Number(this.data.get('last-scroll'));

        if (Math.abs(lastScrollTop - st) <= Number(this.data.get('delta')))
            return;

        if (st > lastScrollTop && st > menu.outerHeight()) { // Scroll Down
            menu.removeClass('nav-down').addClass('nav-up');
        } else if(st + $(window).height() < $(document).height()) { // Scroll Up
            menu.removeClass('nav-up').addClass('nav-down');
        }

        if (st <= 50) {
            menu.removeClass('nav-down').removeClass('nav-up');
        }
        this.data.set('last-scroll', st);
    }
}
