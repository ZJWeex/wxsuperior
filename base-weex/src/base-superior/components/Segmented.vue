<!-- 自定义Segmented组件 安卓左右切换需设置切换列表的高度，否则滑动与点击手势冲突 -->
<template>
<div>
    <div v-if="items.length*itemWidth>750">
        <scroller class="scroller" 
                  :show-scrollbar="false"  
                  scroll-direction="horizontal" 
                  @scroll="onDidScroll">
            <div v-for="(item, index) in items" :key="index">
                <div v-if="selectedIndex == index">
                    <div class="item-select" :ref="'itemX-'+index" :style="styleBind(index)" @click="onChanged(item,index)">
                        <text class="text-select" :style="textColorType(index)">{{item}}</text>
                    </div>
                </div>
                <div v-else>
                    <div class="item-nonselect" :ref="'itemX-'+index" :style="styleBind(index)" @click="onChanged(item,index)">
                        <text class="text-nonselect" :style="textColorType(index)">{{item}}</text>
                    </div>
                </div>
            </div>
        </scroller>
    </div>
    <div v-else>
        <div class="inSegmented">
            <div v-for="(item, index) in items" :key="index">
                <div v-if="selectedIndex == index">
                    <div class="item-select" :style="styleBind(index)" @click="onChanged(item,index)">
                        <text class="text-select" :style="textColorType(index)">{{item}}</text>
                    </div>
                </div>
                <div v-else>
                    <div class="item-nonselect" :style="styleBind(index)" @click="onChanged(item,index)">
                        <text class="text-nonselect" :style="textColorType(index)">{{item}}</text>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</template>

<script>
const modal = weex.requireModule("modal");
const dom = weex.requireModule('dom')

export default {
    //定义属性,且prop定义的属性在当前组件中不可修改
    props: {
        items:{
            default: function (){
                return ['推荐','自由组团','热门活动','游记']
            }
        },
        cornerRadius:{
            default: 10.0
        },
        itemWidth: {
            //设置可滑动的标签，必须设置itemWidth
            default:0
        },
        tintColor: {
            default:'blue'
        }
    },
    data() {
        return {
          //定义全局变量  
          selectedIndex:0,
        }
    },
    mounted: function (){
    },
    methods: {
        //动态绑定样式
        styleBind(index) {
            var that = this;
            let cornerType = that.cornerType(index);

            let tintColorType = that.tintColorType(index);

            let relustStyle = that.itemWidth> 0 ?
                      {...cornerType,...tintColorType,'width':that.itemWidth}
                     :{...cornerType,...tintColorType};

            return relustStyle
        },
        //初始化style
         cornerType(index) {
           const { cornerRadius, items, tintColor } = this;
            const cornerTypeFirst = {
                'border-top-left-radius': cornerRadius+'px',
                'border-bottom-left-radius': cornerRadius+'px',
            };
            const cornerTypeLast = {
                'border-top-right-radius': cornerRadius+'px',
                'border-bottom-right-radius': cornerRadius+'px'
            };

            let borderAround = {
                'border-left-width': '2px',
                'border-right-width': '2px'
            };

            if(index == 0){
                borderAround = {
                'border-left-width': '2px',
                'border-right-width': '1px'
               };
            }else if(index == items.length - 1) {
                borderAround = {
                'border-left-width': '1px',
                'border-right-width': '2px'
               };
            }else{
                borderAround = {
                'border-left-width': '1px',
                'border-right-width': '1px'
               };
            }
            
            if(index == 0){
                return cornerTypeFirst;
            }else if(index == items.length - 1){
                return cornerTypeLast;
            }else{
                return borderAround;
            }
        },
        //主题颜色修改
        tintColorType:function(index) {
            const { tintColor } = this;
            let tintColorType = {};
            if(this.selectedIndex == index) {
                tintColorType = {
                    'border-color': tintColor,
                    'background-color': tintColor
                };
            }else{
                tintColorType = {
                    'border-color': tintColor,
                    'background-color': 'white'
                };
            }

            return tintColorType;
        },
        //文字颜色修改
        textColorType:function(index){
            const { tintColor } = this;
            let textColorType = {};
            if(this.selectedIndex == index) {
                textColorType = {
                    'color': 'white'
                };
            }else{
                textColorType = {
                    'color': tintColor
                };
            }

            return textColorType;
        },
        //点击事件
        onChanged:function (item, index) {
            var that = this;
            // console.log('点击事件');
            if(that.items.length*that.itemWidth > 750) {
                that.autoOffset(index, callBack=>{
                    if(this.selectedIndex != index){
                        this.selectedIndex = index;
                        this.$emit('changedClick', item);
                    } 
                });
            }else{
               if(this.selectedIndex != index){
                    this.selectedIndex = index;
                    this.$emit('changedClick', item);
                }  
            }
            
        },
        //设置标签自动滑动
        autoOffset:function(index,callBack) {
            var that = this;
             if(that.items.length*that.itemWidth > 750) {
                const itemEl = that.$refs['itemX-'+index][0];
                if(itemEl) {
                   dom.getComponentRect(itemEl, option => { 
                    //    console.log('left:', option.size.left,'right:',option.size.right)
                       //是否点击左边的按钮
                       let leftEvent = false;
                       if(that.selectedIndex > index){
                            leftEvent = true;
                       }

                       let leftX =  option.size.left;
                       var targetIndex = -1;
                       
                       if(leftEvent){
                        //    console.log(leftEvent)
                           targetIndex = index - 2;
                           if(targetIndex<0){
                              targetIndex = 0; 
                           }
                       }else{
                           if(leftX > 750/2.0){
                               if(that.selectedIndex < index){
                                   targetIndex = index-1;
                               }
                           }
                       }

                       if(targetIndex>-1 && targetIndex<that.items.length){
                           const targetEl = that.$refs['itemX-'+ targetIndex][0];
                           dom.scrollToElement(targetEl, { offset: 0 })
                       }
                       callBack();
                   })
                   
                }
            }
        },
        //指定索引值
        setSelectIndex(index) {
            var that = this;
            if(index >= that.items.length) return;
    
            let item = that.items[index];
            that.onChanged(item, index);
        },
        //Scroll滑动事件
        onDidScroll: function(e) {
            let offsetX = e.contentOffset.x;
            let contentWidth = e.contentSize.width;
            //  dom.scrollToElement(el, { offset: 0 })
        }
    
    }
    
}
</script>

<style scoped>
.scroller {
    flex-direction: row;
    justify-content:flex-start;
    align-items: center;
    background-color: chartreuse;
    height: 90px;
}
.inSegmented {   
    flex-direction: row;
    justify-content:center;
    align-items: center;
    height: 90px;
    background-color: cornflowerblue;
}
.item-select {
    align-items: center;
    border-top-width: 2px;
    border-bottom-width: 2px;
    border-left-width: 2px;
    border-right-width: 2px;
    border-color: blue;
    background-color: blue;
    height: 80px;
}
.item-nonselect {
    align-items: center;
    border-top-width: 2px;
    border-bottom-width: 2px;
    border-left-width: 2px;
    border-right-width: 2px;
    border-color: blue;
    background-color: white;
    height: 80px;
}
.text-select {
    margin: 10px;
    font-size: 34px;
    text-align: center;
    color: white; 
    lines: 1;
    text-overflow: ellipsis; 
}
.text-nonselect {
    margin: 10px;
    font-size: 34px;
    text-align: center;
    color: blue; 
    lines: 1;
    text-overflow: ellipsis; 
}
</style>
