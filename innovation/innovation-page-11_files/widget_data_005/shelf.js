var ShelfEvents={OPEN:"shelfOpen",CLOSE:"shelfClose",SHELF_OPENED:"shelfOpened",SHELF_CLOSED:"shelfClosed",CHANGE_INDEX:"changeIndex"},SHELF_ITEM_RATIO=.765,SHELF_HEIGHT_BREAKPOINTS=[0,320,640],SHELF_ROWS=[1,2,4],SHELF_UPPER_MARGIN_PERCENT=7,SHELF_HEIGHT_PERCENT=23,SHELF_LEFT_MARGIN_PERCENT=30,SHELF_RIGHT_MARGIN_PERCENT=36,SHELF_ITEM_MARGIN_PERCENT=16,MAX_ITEM_WIDTH=89,MAX_ITEM_HEIGHT=116,ITEM_SPACING=15,SHELF_V_MARGIN=23,SHELF_H_MARGIN=46,SHELF_LEFT_MARGIN=27,SHELF_RIGHT_MARGIN=39,SHELF_HEIGHT=35,ITEM_SHELF_OFFSET=1,SHELF_NAV_BUTTON_WIDTH=26,ShelfTemplates={listView:'<div id="shelfListView"></div>',shelf:'<div class="shelf-container"><div class="shelf"></div><div class="shadow-container"><div class="left-shadow-container"><div class="left-shadow"></div></div><div class="mid-shadow"></div><div class="right-shadow-container"><div class="right-shadow"></div></div></div></div>',itemView:'<div class="shelf-item"></div>',row:'<div class="shelf-row"></div>',navView:'<div id="shelfNavView"><div class="shelf-nav left"></div><div class="shelf-nav right"></div></div>',tooltip:'<div class="shelf-tooltip"></div>',pageNum:'<div class="shelf-page-num"></div>',navButton:'<svg version="1.0" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="26.2px" height="26.2px" viewBox="0 0 26.2 26.2" style="enable-background:new 0 0 26.2 26.2;" xml:space="preserve"><g><g><path style="fill:#FFFFFF;" d="M13.1,0.2C5.9,0.2,0,6,0,13.2s5.9,13,13.1,13s13.1-5.8,13.1-13S20.4,0.2,13.1,0.2z M17.9,13.5l-7.3,7.2c-0.1,0.1-0.2,0.1-0.3,0.1s-0.2,0-0.3-0.1c-0.2-0.2-0.2-0.4,0-0.6l7-6.9l-7-6.9c-0.2-0.2-0.2-0.4,0-0.6s0.5-0.2,0.6,0l7.3,7.2C18.1,13.1,18.1,13.3,17.9,13.5z"/></g></g></svg>'},ShelfItemModel=Backbone.Model.extend({"default":{size:[MAX_ITEM_WIDTH,MAX_ITEM_HEIGHT],item:[],status:""}}),ShelfListModel=Backbone.Model.extend({defaults:{currentPageIndex:0,noOfPages:0,itemsPerPage:1,items:[],size:[100,100]},getHeightBreakpointIndex:function(h){for(var i=0,len=SHELF_HEIGHT_BREAKPOINTS.length,idx=len-1;i<len-1&&idx===-1;)SHELF_HEIGHT_BREAKPOINTS[i]>=h&&SHELF_HEIGHT_BREAKPOINTS[i+1]<=h&&(idx=i),i+=1;return idx}}),ShelfModel=Backbone.Model.extend({}),ShelfNavigationModel=Backbone.Model.extend({defaults:{currentPageIndex:0,noOfPages:1}}),ShelfPageModel=Backbone.Model.extend({defaults:{index:0,hasNavigation:!1,itemViews:[],rows:1,columns:1,display:!1,maxItemsPerPage:1}}),ShelfPageNumberModel=Backbone.Model.extend({defaults:{currentPageIndex:0,noOfPages:1}}),Shelf=Backbone.View.extend({template:_.template(ShelfTemplates.shelf),initialize:function(){this.setElement(this.template())},render:function(){return this}}),ShelfItemView=Backbone.View.extend({events:{click:"handleItemClick"},template:_.template(ShelfTemplates.itemView),initialize:function(){this.setElement(this.template()),this.item=this.model.get("item"),this.itemCoverLoader=null},render:function(){return this.$el.css("margin-top",MAX_ITEM_HEIGHT-this.model.get("size")[1]),this.createItemCoverLoader(),this},createItemCoverLoader:function(){this.itemCoverLoader=new SimpleLoader({model:new SimpleLoaderModel({width:this.model.get("size")[0],height:this.model.get("size")[1],scaleMode:"scale"})}),this.listenTo(this.itemCoverLoader.model,"change:status",this.loadItemCoverShadows),this.listenTo(this.itemCoverLoader.model,"change",this.positionBookShadow),this.$el.append(this.itemCoverLoader.render().el)},load:function(){var isArabicStyle=FSWidgetModel.gi().widgetSettings.get("arabicStyle"),itemPages=this.item.get("pages"),itemCover=isArabicStyle?itemPages.at(itemPages.length-1):itemPages.at(0),thumbUrl=itemCover.get("thumb");this.itemCoverLoader.model.set("source",thumbUrl)},handleItemClick:function(){this.trigger("click",this.model.get("item").get("itemIndex"))},loadItemCoverShadows:function(item,status){var $shadowDiv;status===ContentLoaderStatus.COMPLETE?(this.$el.addClass("visible"),$shadowDiv=$("<div/>").addClass("book-shadow"),this.$el.append($shadowDiv)):status===ContentLoaderStatus.ERROR&&this.$el.addClass("blank").addClass("visible"),this.model.set("status",status),$(this).trigger(status)},positionBookShadow:function(model){var shadowOffset,shadowSize,loaderWidth,imageWidth;("imageWidth"in model.changed||"imageHeight"in model.changed)&&(loaderWidth=this.itemCoverLoader.model.get("width"),imageWidth=this.itemCoverLoader.model.get("imageWidth"),shadowSize=6,shadowOffset=Math.ceil((loaderWidth-imageWidth)/2)-shadowSize,this.$el.find(".book-shadow").css("right",shadowOffset+"px"))},isLoadComplete:function(){var status=this.model.get("status");return status===ContentLoaderStatus.COMPLETE||status===ContentLoaderStatus.ERROR}}),ShelfListView=Backbone.View.extend({template:_.template(ShelfTemplates.listView),initialize:function(){this.setElement(this.template()),this.loadManager=new LoaderManager,this.itemViews=[],this.createItemViews(),this.pages=[],this.resetPageViews(),this.resize(),this.listenTo(this.model,"change:size",this.resize),this.listenTo(this.model,"change",this.resetPageViews),this.listenTo(this.model,"change:currentPageIndex",this.showPage)},render:function(){return this},resize:function(){var self=this;this.$el.css({width:this.model.get("size")[0]+"px",height:this.model.get("size")[1]+"px",marginLeft:SHELF_H_MARGIN+(this.model.get("noOfPages")>1?SHELF_NAV_BUTTON_WIDTH:0)+"px",marginTop:SHELF_V_MARGIN+"px"}),_.each(this.pages,function(page){page.model.set("size",self.model.get("size"))})},createItemViews:function(){var items=this.model.get("items"),i=0,len=items.length;for(i;i<len;i+=1)this.itemViews.push(this.createItem(items.at(i))),this.itemViews[i].render(),this.itemViews[i].on("click",this.openItem,this)},destroyItemViews:function(){this.itemViews.forEach(function(itemView){itemView.off(),itemView.remove()}),this.itemViews=[]},createItem:function(item){var itemHeight=Math.min(MAX_ITEM_HEIGHT,this.getShelfItemHeight(MAX_ITEM_WIDTH,item));return new ShelfItemView({model:new ShelfItemModel({size:[MAX_ITEM_WIDTH,itemHeight],item:item})})},getShelfItemHeight:function(width,item){var itemWidth=item.get("pages").at(0).get("width"),itemHeight=item.get("pages").at(0).get("height"),scale=itemWidth/width;return Math.round(itemHeight/scale)},handleItemClick:function(index){this.trigger("openItem",index)},createPageViews:function(){var page,noOfPages=this.model.get("noOfPages"),itemsPerPage=this.model.get("itemsPerPage"),totalItems=this.itemViews.length,i=0;for(i;i<noOfPages;i+=1)page=new ShelfPageView({model:new ShelfPageModel({index:i,hasNavigation:noOfPages>1,itemViews:this.itemViews.slice(i*itemsPerPage,Math.min(totalItems,(i+1)*itemsPerPage)),rows:this.model.get("rows"),columns:this.model.get("columns")})}),this.$el.append(page.render().$el),this.pages.push(page)},destroyPageViews:function(){this.pages.forEach(function(page){page.off(),page.remove()}),this.pages=[],this.$el.empty()},resetPageViews:function(){var changedAttrs=this.model.changedAttributes(),targetAttributes=["noOfPages","itemsPerPage","rows","columns"],canUpdatePages=targetAttributes.some(function(attribute){return attribute in changedAttrs});canUpdatePages&&(this.destroyPageViews(),this.createPageViews(),this.showPage())},showPage:function(){var pageIndex=this.model.get("currentPageIndex");this.pages.forEach(function(page,index){page.model.set("display",index===pageIndex)}),this.resetLoaderTasks()},resetLoaderTasks:function(){var i,pageIndex=this.model.get("currentPageIndex"),len=this.pages.length,self=this;for(this.loadManager.removeAllTasks(),i=pageIndex;i<len;i+=1)this.pages[i].model.get("itemViews").forEach(function(itemView){self.loadManager.addTask(itemView)});for(i=pageIndex-1;i>-1;i-=1)this.pages[i].model.get("itemViews").forEach(function(itemView){self.loadManager.addTask(itemView)})},openItem:function(itemIndex){this.trigger("openItem",itemIndex)},remove:function(){this.loadManager.removeAllTasks(),this.loadManager=null,this.destroyPageViews(),this.destroyItemViews(),Backbone.View.prototype.remove.apply(this,arguments)}}),ShelfNavigationView=Backbone.View.extend({events:{"click .shelf-nav.left":"previousPage","click .shelf-nav.right":"nextPage"},template:_.template(ShelfTemplates.navView),initialize:function(){this.setElement(this.template()),this.$leftButton=this.$el.find(".left"),this.$rightButton=this.$el.find(".right"),this.$leftButton.append(_.template(ShelfTemplates.navButton)()),this.$rightButton.append(_.template(ShelfTemplates.navButton)()),this.listenTo(this.model,"change",this.updateNavControls),this.pageNumberModel=new ShelfPageNumberModel({currentPageIndex:this.model.get("currentPageIndex"),noOfPages:this.model.get("noOfPages")}),this.pageNumberView=new ShelfPageNumberView({model:this.pageNumberModel}),this.$el.find(".left").after(this.pageNumberView.render().el),this.pageNumberView.on(ShelfEvents.CHANGE_INDEX,this.updateIndex,this)},render:function(){return this.updateNavControls(),this},previousPage:function(){var index=this.model.get("currentPageIndex");index>0&&(index-=1,this.model.set("currentPageIndex",index),this.pageNumberModel.set("currentPageIndex",index))},nextPage:function(){var index=this.model.get("currentPageIndex"),noOfPages=this.model.get("noOfPages");index<noOfPages-1&&(index+=1,this.model.set("currentPageIndex",index),this.pageNumberModel.set("currentPageIndex",index))},updateNavControls:function(){var index=this.model.get("currentPageIndex"),noOfPages=this.model.get("noOfPages");1===noOfPages?this.$el.hide():this.$el.show(),0===index?this.$leftButton.addClass("disabled"):this.$leftButton.removeClass("disabled"),index===noOfPages-1?this.$rightButton.addClass("disabled"):this.$rightButton.removeClass("disabled"),this.pageNumberModel.set("noOfPages",noOfPages)},remove:function(){this.undelegateEvents(),Backbone.View.prototype.remove.apply(this,arguments)},updateIndex:function(index){this.model.set("currentPageIndex",index),this.pageNumberModel.set("currentPageIndex",index)}}),ShelfPageNumberView=Backbone.View.extend({template:_.template(ShelfTemplates.pageNum),initialize:function(){this.setElement(this.template()),this.listenTo(this.model,"change:currentPageIndex",this.updatePageBullets),this.listenTo(this.model,"change:noOfPages",this.createPageBullets),this.$el.on("click",this,this.onBulletClick)},render:function(){return this.createPageBullets(),this},createPageBullets:function(){var bullet,active,last,i,noOfPages=this.model.get("noOfPages");for(this.$el.empty(),i=0;i<noOfPages;i+=1)active=this.model.get("currentPageIndex")===i?" active":"",last=i===noOfPages-1?" last":"",bullet='<span class="page-bullet'+active+last+'" data-page='+i+"></span>",this.$el.append(bullet)},updatePageBullets:function(){this.$el.find(".active").removeClass("active"),this.$el.find("[data-page = "+this.model.get("currentPageIndex")+"]").addClass("active")},onBulletClick:function(e){$(e.target).hasClass("page-bullet")&&e.data.trigger(ShelfEvents.CHANGE_INDEX,parseInt($(e.target).attr("data-page"),10))}}),ShelfPageView=Backbone.View.extend({className:"shelf-page",initialize:function(){this.shelfViews=[],this.createElements(),this.setPageDisplayMode(),this.listenTo(this.model,"change:items",this.resetView),this.listenTo(this.model,"change:display",this.setPageDisplayMode)},render:function(){return this},destroyShelves:function(){this.shelfViews.forEach(function(shelf){shelf.remove()}),this.shelfViews=[]},clearView:function(){this.destroyShelves(),this.$el.find(".shelf-item").detach(),this.$el.empty()},createShelves:function(){var $rowElem,itemViews=this.model.get("itemViews"),totalItems=itemViews.length,maxCols=this.model.get("columns"),maxRows=Math.ceil(totalItems/maxCols),i=0,j=0,currentItemIndex=0;for(i;i<maxRows;i+=1){for($rowElem=$(_.template(ShelfTemplates.row)()),this.$el.append($rowElem),j=0;j<maxCols&&currentItemIndex<totalItems;j+=1)$rowElem.append(itemViews[currentItemIndex].$el),currentItemIndex+=1;this.shelfViews.push(new Shelf({model:{}})),$rowElem.append(this.shelfViews[i].render().$el)}},createElements:function(){this.createShelves()},resetView:function(){this.clearView(),this.createElements()},remove:function(){this.clearView(),Backbone.View.prototype.remove.apply(this,arguments)},setPageDisplayMode:function(){var displayMode=this.model.get("display")?"flex":"none";this.$el.css("display",displayMode)}});!function(global){function createShelfView(){var widgetType=FSWidgetModel.gi().widgetSettings.get("widgetType"),forceWidget=FSWidgetModel.gi().get("forceWidget");widgetType!==WidgetType.SHELF||forceWidget||ShelfView.gi()}function destroyShelfView(){ShelfView._instance&&(ShelfView.gi().remove(),ShelfView._instance=null)}global.ShelfView=Backbone.View.extend({el:ComponentContainers.SHELF_VIEW,initialize:function(){var isCorrectDisplayType=FSWidgetModel.gi().widgetState.get("displayType")===DisplayType.SMALL,isFullScreenMode=FSWidgetModel.gi().widgetState.get("displayState")!==DisplayState.NORMAL;Backbone.Mediator.pub(ShelfEvents.OPEN),this.items=FSWidgetModel.gi().flipCollection2.get("items"),this.isVisible=!1,this.createListView(),this.createNavigation(),Backbone.Mediator.sub(WidgetEvent.RESIZE,this.resize,this),Backbone.Mediator.sub(WidgetEvent.FULLSCREEN_CHANGED,this.open,this),this.listenTo(FSWidgetModel.gi().widgetState,"change:displayType",this.handleDisplayTypeChange),this.listenTo(this.model,"change",this.setListViewSize),this.listenTo(this.listModel,"change",this.updateNavigation),this.listenTo(this.navigationModel,"change:currentPageIndex",this.updateList),this.listView.on("openItem",this.openItem,this),isCorrectDisplayType&&!isFullScreenMode&&this.render()},createListView:function(){this.listModel=new ShelfListModel({items:this.items,currentPageIndex:0,size:this.model.get("size")}),this.setListViewSize(),this.listView=new ShelfListView({model:this.listModel}),this.$el.append(this.listView.render().el)},createNavigation:function(){this.navigationModel=new ShelfNavigationModel({currentPageIndex:0,noOfPages:this.listView.model.get("noOfPages")}),this.navigationView=new ShelfNavigationView({model:this.navigationModel}),this.$el.append(this.navigationView.render().el)},render:function(){return this.$el.addClass("visible"),this.isVisible=!0,Backbone.Mediator.pub(ShelfEvents.SHELF_OPENED),this},calculateNumberOfPages:function(showNav){var noOfPages,itemsPerPage,availableShelfWidth,columns,rowHeight,availableShelfHeight,rows,noOfItems=this.items.length,widgetWidth=this.model.get("size")[0],widgetHeight=this.model.get("size")[1],navWidth=showNav?2*SHELF_NAV_BUTTON_WIDTH:0,hMargins=2*SHELF_H_MARGIN,pageWidth=widgetWidth-hMargins-navWidth,pageHeight=widgetHeight-2*SHELF_V_MARGIN;return availableShelfWidth=pageWidth-SHELF_LEFT_MARGIN-SHELF_RIGHT_MARGIN,columns=Math.max(Math.floor((availableShelfWidth+ITEM_SPACING)/(MAX_ITEM_WIDTH+ITEM_SPACING)),1),rowHeight=MAX_ITEM_HEIGHT+SHELF_HEIGHT-ITEM_SHELF_OFFSET,availableShelfHeight=pageHeight-SHELF_V_MARGIN,rows=Math.max(Math.floor(availableShelfHeight/rowHeight),1),itemsPerPage=rows*columns,noOfPages=Math.ceil(noOfItems/itemsPerPage),{size:[pageWidth,pageHeight],itemsPerPage:itemsPerPage,noOfPages:noOfPages,rows:rows,columns:columns,currentPageIndex:Math.min(this.listModel.get("currentPageIndex"),noOfPages-1)}},setListViewSize:function(){var obj=this.calculateNumberOfPages();obj.noOfPages>1&&(obj=this.calculateNumberOfPages(!0)),this.listModel.set(obj)},resize:function(){this.isVisible&&this.model.set("size",[FSWidgetModel.gi().get("width"),FSWidgetModel.gi().get("height")])},updateNavigation:function(){var changedAttributes=this.listModel.changedAttributes();("noOfPages"in changedAttributes||"itemsPerPage"in changedAttributes)&&this.navigationModel.set({currentPageIndex:this.listModel.get("currentPageIndex"),noOfPages:this.listModel.get("noOfPages")})},updateList:function(){this.listModel.set("currentPageIndex",this.navigationModel.get("currentPageIndex"))},openItem:function(itemIndex){Backbone.Mediator.pub(WidgetEvent.CHANGE_ITEM,itemIndex),Backbone.Mediator.pub(ShelfEvents.CLOSE),Backbone.Mediator.pub(WidgetEvent.ENTER_FULLSCREEN),this.close()},close:function(){this.isVisible&&(this.$el.removeClass("visible"),this.isVisible=!1,Backbone.Mediator.pub(ShelfEvents.SHELF_CLOSED))},open:function(obj){var displayType=FSWidgetModel.gi().widgetState.get("displayType");this.isVisible||obj.displayState!==DisplayState.NORMAL||displayType!==DisplayType.SMALL||(this.$el.addClass("visible"),this.isVisible=!0,Backbone.Mediator.pub(ShelfEvents.SHELF_OPENED))},handleDisplayTypeChange:function(){var displayType=FSWidgetModel.gi().widgetState.get("displayType");displayType===DisplayType.SMALL?this.open({displayState:FSWidgetModel.gi().widgetState.get("displayState")}):this.close()},remove:function(){this.listView.off(),this.listView.remove(),this.listView=null,this.navigationView.remove(),this.navigationView=null,Backbone.View.prototype.remove.apply(this,arguments)}}),ShelfView._instance=null,ShelfView.gi=function(){return ShelfView._instance||(ShelfView._instance=new ShelfView({model:new Backbone.Model({size:[FSWidgetModel.gi().get("width"),FSWidgetModel.gi().get("height")]})})),ShelfView._instance},Backbone.Mediator.sub(WidgetEvent.CONFIG_DONE,createShelfView,this),Backbone.Mediator.sub(WidgetEvent.DESTROY,destroyShelfView,this)}(window);
//# sourceMappingURL=maps/shelf.min.js.map