export class QuerySelectorBuilder {
    constructor(dataTagAttribute) {
        this.dataTagAttribute = dataTagAttribute;
    }

    build(ids, styles, initStyles = '') {
        let query = (initStyles === '') ? [] : [initStyles];
        $.each(ids, (i, id) => {
            query.push(styles + '['+ this.dataTagAttribute +'="'+ id +'"]')
        })
        return query.join(',')
    }
}
