chorus.views.DataTabDataset = chorus.views.Base.extend({
    constructorName: "DataTabDatasetView",
    templateName: "data_tab_dataset",
    tagName: "li",

    events: {
        "click .name a": "nameClicked",
        "click .toggle_visibility": "toggleVisibility"
    },

    postRender: function() {
        this.$el.data("fullname", this.model.toText());
        this.$el.data("name", this.model.name());
        this.setupQTip();
    },

    setup: function() {
        this.columnsVisible = false;
    },

    setupQTip: function() {
        this.$el.qtip("destroy");
        this.$el.qtip({
            content: "<a>" + t('database.sidebar.insert') + "</a>",
            events: {
                render: _.bind(function(e, api) {
                    e.preventDefault();
                    e.stopPropagation();
                    $(api.elements.content).find('a').click(_.bind(this.insertText, this));
                }, this),
                show: function(e, api) {
                    $(api.elements.target).addClass('hover');
                },
                hide: function(e, api) {
                    $(api.elements.target).removeClass('hover');
                }
            },
            show: {
                delay: 0,
                solo: true,
                effect: false
            },
            hide: {
                delay: 0,
                fixed: true,
                effect: false
            },
            position: {
                my: "right center",
                at: "left center",
                adjust: {
                    x: -12
                }
            },
            style: {
                classes: "tooltip-insert",
                tip: {
                    corner: "left center",
                    width: 16,
                    height: 25
                }
            }
        });
    },

    insertText: function(e) {
        e && e.preventDefault();
        chorus.PageEvents.broadcast("file:insertText", this.model.toText());
    },

    teardown: function() {
        this.$el.qtip("destroy");
        this._super("teardown", arguments);
    },

    additionalContext: function() {
        return {
            name: this.model.name(),
            iconUrl: this.model.iconUrl({size: "small"})
        };
    },

    nameClicked: function(e) {
        e.preventDefault();
    },

    toggleVisibility: function() {
        if(!this.columnsVisible) {
            this.columnList = this.buildColumnList();
            this.registerSubView(this.columnList);
            this.columnList.render();
        }

        else {
            this.columnList.teardown(true);
        }

        this.columnsVisible = !this.columnsVisible;
        this.updateArrowIcon();
    },

    updateArrowIcon: function() {
        var imageUrl = this.columnsVisible ? '/images/close.gif' : '/images/expand.gif';
        this.$('img:eq(0)').attr('src', imageUrl);
    },

    buildColumnList: function() {
        return new chorus.views.DataTabDatasetColumnList({
            el: this.$(".column_list"),
            dataset: this.model
        });
    }
});