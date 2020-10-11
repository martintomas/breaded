import { SurpriseMeMutation } from "../mutations/SurpriseMeMutation";
import { QuerySelectorBuilder } from "./QuerySelectorBuilder";
import { ShoppingButtonUpdater } from "./ShoppingButtonUpdater";

export class SurpriseMeViewHelper {
    constructor() {
        this.surpriseMeMutation = new SurpriseMeMutation();
        this.querySelectorBuilder = new QuerySelectorBuilder('data-tag-id');
        this.shoppingButtonUpdater = new ShoppingButtonUpdater(this.surpriseMeMutation, this.querySelectorBuilder);
    }

    updateView() {
        this.shoppingButtonUpdater.update();
        this.updateSurpriseMeCheckBoxes();
        this.updateSurpriseMeList();
    }

    updateSurpriseMeCheckBoxes() {
        let query = this.querySelectorBuilder.build(this.surpriseMeMutation.itemIds(), '.baker_container input');

        $(query).each((i, button) => { button.checked = true });
        $('.dec.button').not(query).each((i, button) => { button.checked = false });
    }

    updateSurpriseMeList() {
        let query = this.querySelectorBuilder.build(this.surpriseMeMutation.itemIds(), '.preferences-tag');

        $.each(this.surpriseMeMutation.data, (i, tagValues) => this.addNewTagItem(tagValues));
        $('.preferences-tag').not(query).remove();
    }

    addNewTagItem(tagValues) {
        if($('.preferences-tag[data-tag-id="'+ tagValues.id +'"]').length !== 0) { return; }

        let element = document.createElement("P");
        element.dataset.tagId = tagValues.id;
        element.classList.add("preferences-tag");
        element.innerText = tagValues.tagName
        document.querySelector('.surpriseList .'+ tagValues.section).appendChild(element);
    }
}
