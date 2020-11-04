import Turbolinks from "turbolinks";

Turbolinks.scroll = {};

const turbolinksPersistScroll = () => {
    if (Turbolinks.scroll['top']) {
        document.scrollingElement.scrollTo(0, Turbolinks.scroll['top']);
    }

    Turbolinks.scroll = {};
}

document.addEventListener('turbolinks:load', turbolinksPersistScroll);
document.addEventListener('turbolinks:render', turbolinksPersistScroll);
