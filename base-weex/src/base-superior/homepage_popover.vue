<template>
    <div>
        <div class='wrapper' v-if="show">
            <div class="topoffset" :style="{height:topoffset}" @click="closePopover">
                <div style="height:68px;background-color:#fff;margin-right:60px;flex:1;justify-content: center;">
                    <text style="color:#333;font-size:28px;padding:30px;">全部</text>
                </div>
            </div>
            <div class="content-table" ref="list">
                <div v-for="(item,index) in dataSorce" :key="index">
                    <div :class="[selectIndex==index?'select-cell':'cell']"
                         @click="didSelectCell(index)">
                        <text :class="[selectIndex==index?'select-celltxt':'celltxt']">{{ item.title }}</text>
                    </div>
                </div>
            </div>
            <div class="mask" @click="closePopover"></div>
        </div>
    </div>
</template>

<script>

const modal = weex.requireModule('modal');
const animation = weex.requireModule('animation');

export default {
    components: { },
    props:{
        show: {
            type: Boolean,
            default: false
        },
        dataSorce:{
            type: Array,
            default:()=>([
                {'title':'推荐'},{'title':'网红青团'},{'title':'南北干货'},
            ])
        },
        // selectIndex:{
        //     type:Number,
        //     default:0
        // },
        topoffset:{
            type:Number,
            default:200
        }
    },
    data() {
        return {
           selectIndex:0
        }
    },
    created() {
        setTimeout(()=> {
            this.showAnimation(0)
        },100)
         
    },
    watch:{
        show(newValue, oldValue){
            if(newValue){
                this.showAnimation(1.0)
            }
            if(oldValue){
                this.showAnimation(0)
            }
        }
    },
    methods: {
        //点击cell事件
        didSelectCell:function(index){
            this.setIndex(index)
            this.$emit('didSelectItem', index)
        },
        setIndex:function(index){
             this.selectIndex = index
        },
        //隐藏popover弹框
        closePopover:function(){
            this.$emit('closePopover', {})
        },
        //动画不执行？？
        showAnimation:function(y){
            var duration = 300
            let ref1 = this.$refs.list
            animation.transition(ref1, {
                styles: {
                    transform: 'scaleY('+y+')',
                    transformOrigin: 'center top'
                },
                duration: duration, //ms
                timingFunction: 'ease',
                needLayout:false,
                delay: 0 //ms
                }, function () {
                    
                })
        },
    }
}
</script>

<style scoped>
.wrapper { 
    width: 750px;
    position: fixed;
    left: 0;
    top: 0;
    bottom: 0;
    right: 0;
    z-index: 9999;
}
.topoffset {
    flex-direction: row;
    align-items:flex-end;
}
.mask{
    width: 750px;
    flex: 1;
    background-color: rgba(0, 0, 0, 0.6)
}
.content-table{
    background-color: #ffffff;
    padding-left: 20px;
    padding-right: 20px;
    flex-direction: row;
    flex-wrap: wrap;
}
.cell{
    border-width: 2px;
    border-color: #ebebeb;
    border-radius: 10px;
    height: 54px;
    width: 150px;
    margin: 10px;
    justify-content: center;
    align-items: center;
}
.select-cell{
    border-radius: 10px;
    height: 54px;
    width: 150px;
    background-color:#df133c; 
    margin: 10px;
    justify-content: center;
    align-items: center;
}
.celltxt{
    font-size: 26px;
    color: #666666;
}
.select-celltxt{
    font-size: 26px;
    color: #ffffff;
}

</style>
