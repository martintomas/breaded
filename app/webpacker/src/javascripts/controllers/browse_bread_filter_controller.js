import { Controller } from "stimulus"

require('intersection-observer');

export default class extends Controller {
    static targets = ["entries", "pagination"]

    initialize() {
        if(document.selectedSection == null) {
            document.selectedSection = 'breads';
            document.selectedCategory = { breads: 'breads-all' }
        }
        this.updateStatusOfFilter();
        this.intersectionObserver = new IntersectionObserver(entries => this.processIntersectionEntries(entries))
    }

    connect() {
        this.intersectionObserver.observe(this.paginationTarget)
    }

    disconnect() {
        this.intersectionObserver.unobserve(this.paginationTarget)
    }

    changeFilterSection(event) {
        document.selectedSection = event.target.id
        if(document.selectedCategory[document.selectedSection] === undefined) {
            document.selectedCategory[document.selectedSection] = document.selectedSection + '-all'; // default is all
        }
        this.loadFoods();
        this.updateStatusOfFilter();
    }

    changeFilterCategory(event) {
        event.preventDefault();
        document.selectedCategory[document.selectedSection] = $(event.currentTarget).find('a').data('name')
        this.loadFoods();
        this.updateStatusOfFilter();
    }

    processIntersectionEntries(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                this.loadFoods(false)
            }
        })
    }

    loadFoods(hardReset = true) {
        let url = this.obtainUrl(hardReset)
        if(url === null) { return }

        $.ajax({
            type: 'GET',
            url: url,
            data: { section: document.selectedSection,
                    category: document.selectedCategory[document.selectedSection].split('-').pop() },
            dataType: 'json',
            success: (data) => {
                if(hardReset) { this.entriesTarget.innerHTML = '' }
                this.processFoodData(data)
                this.updateStatusOfCategory()
                if(hardReset) { window.scrollTo(0, 0); }
            }
        })
    }

    processFoodData(data) {
        if(document.selectedSection === 'breads' && this.entriesTarget.querySelector("span.dd") == null) {
            this.entriesTarget.innerHTML = data.header
        }
        this.entriesTarget.insertAdjacentHTML('beforeend', data.entries)
        this.paginationTarget.innerHTML = data.pagination
    }

    obtainUrl(hardReset) {
        if(this.paginationTarget.querySelector('.pagy-nav.pagination') == null || hardReset) {
            return this.data.get('base-url')
        } else {
            let nextPage = this.paginationTarget.querySelector("a[rel='next']")
            if (nextPage == null) { return null }
            return nextPage.href
        }
    }

    toggleMobDropdown() {
        $('.wrapper-dropdown-3').toggleClass('active');
        $('ul.'+ document.selectedSection +'ListMob').toggleClass('active');
    }

    keepFilterStick() {
        let windowPos = $(window).scrollTop();
        let contentHeight = $(".itemsBlock").height() - 100;
        if (windowPos >= 300 && windowPos <= contentHeight) {
            $('.sticker').addClass("stick");
        } else {
            $('.sticker').removeClass("stick");
        }
    }

    updateStatusOfFilter() {
        $('.bakersBread li, .listItems li, .listItems, .dropdown, .wrapper-dropdown-3').removeClass('active');
        $('#'+ document.selectedSection).addClass('active');
        $('ul.'+ document.selectedSection +'List').addClass('active');
        this.updateStatusOfCategory();
    }

    updateStatusOfCategory() {
        let category = $('*[data-name='+ document.selectedCategory[document.selectedSection] +']')
        category.parent().addClass('active');
        $(".dd").replaceWith('<span class="dd">' + category.first().text() + '</span>');
    }
}
