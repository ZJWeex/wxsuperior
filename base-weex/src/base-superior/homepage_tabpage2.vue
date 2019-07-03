<template>
    <scroller class="tabpage" ref="h-scroller"
                  alwaysScrollableHorizontal='true' 
                  scroll-direction="horizontal" show-scrollbar="false"
                  @scroll="tabpageOnScroll">
        <div class="itemcontent" v-for="(item, index) in floors" :key="'floor'+index"
                 :ref="'floor'+index" @click="go2floor(index)">
            <text v-if="selectIndex==index" class="select-item-text" :ref="'text'+index">{{item.title}}</text>
            <text v-else class="item-text" :ref="'text'+index">{{item.title}}</text>
        </div>
    </scroller>
</template>

<script>
import { WxcPanItem } from "weex-ui";
const modal = weex.requireModule('modal');
const dom = weex.requireModule('dom')
export default {
    components: { WxcPanItem },
    props:{
        floors:{
            type: Array,
            default:()=>([
                {'title':'推荐'},{'title':'网红青团'},{'title':'南北干货'},
            ])
        },
        selectIndex:{
            type: Number,
            default:0
        },
    },
    data() {
        return {
            contentOffsetX:0,
        }
    },
    created() {

    },
    watch:{
        selectIndex(newValue, oldValue){
            console.log('二级分类改变了')
            const self = this
            self.scrollToElement(newValue)
        },
    },
    methods: {
        go2floor: function(index){
            // this.selectIndex = index
            this.$emit('changeSegment',index)
        },
        tabpageOnScroll:function(e){
            // console.log('contentOffset.x:',e.contentOffset.x)
            this.contentOffsetX = e.contentOffset.x
            
        },
        scrollToElement:function(newIndex){
            const self = this
            let aEl = this.$refs['floor'+newIndex][0]
            dom.getComponentRect(aEl, option => {
                console.log('left:'+option.size.left+',right:'+option.size.right+',width:'+option.size.width+',ofsetX:'+self.contentOffsetX)
                let left = option.size.left
                let elWidth = option.size.width
                if(left>375){
                    dom.scrollToElement(aEl,{ offset: -left + elWidth,animated: true})
                }else{
                    if(self.selectIndex<3){
                        aEl = this.$refs['floor0'][0]
                        dom.scrollToElement(aEl,{ offset: -20,animated: true})
                    }else{
                        if(self.contentOffsetX<0){
                            dom.scrollToElement(aEl,{ offset: -left - elWidth,animated: true})
                        }
                    }
                } 
            })
        },
    }
}
</script>

<style scoped>
.tabpage{
    position: absolute;
    width: 750px;
    top: 0;
    left: 0;
    right: 0;
    height: 64px;
    background-color: rgba(255, 255, 255, 0.95);
    flex-direction: row;
    padding-left: 20px;
}
.itemcontent{
    height: 64px;
    align-items: center;
    justify-content: center;
}
.item-text{
    color: #333333;
    font-size: 26px;
    margin-left:10px;
    margin-right: 10px;
}
.select-item-text{
    color: #ffffff;
    background-color:#ff0033;
    border-radius: 10px; 
    font-size: 26px;
    padding-left: 5px;
    padding-right: 5px;
    margin-left:10px;
    margin-right: 10px;
}
</style>
