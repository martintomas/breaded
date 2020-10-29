import { Controller } from "stimulus"
import { SurpriseMeMutation } from "../../mutations/SurpriseMeMutation";
import { SurpriseMeViewHelper } from "../../services/foods/SurpriseMeViewHelper";

export default class extends Controller {
  initialize() {
    this.surpriseMeMutation = new SurpriseMeMutation();
    this.surpriseMeViewHelper = new SurpriseMeViewHelper();
  }

  connect() {
    this.surpriseMeViewHelper.updateView();
  }

  addItem(event) {
    if(this.surpriseMeMutation.numOfItems() >= this.data.get('maxItems')) { return; }

    event = $(event.target);
    this.surpriseMeMutation.addItem(event.data('tagId'), event.data('tagName'), 'ingredients-preference', 1);
    this.surpriseMeViewHelper.updateView();
  }

  removeItem(event) {
    if(this.surpriseMeMutation.numOfItems() <= 0) { return; }

    event = $(event.target);
    this.surpriseMeMutation.removeItem(event.data('tagId'));
    this.surpriseMeViewHelper.updateView();
  }

  updateCategoryPreferences(event) {
    let target = event.target;
    if(target.checked) {
      this.surpriseMeMutation.addItem(target.dataset.tagId, target.dataset.tagName, 'favourite_bread_types');
    } else {
      this.surpriseMeMutation.removeItem(target.dataset.tagId);
    }
    this.surpriseMeViewHelper.updateView();
  }
}
