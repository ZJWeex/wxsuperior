<template>
    <div class='wrapper'>
        <div style="flex:1">
            <div v-for="(item, index) in traces" :key="index">
                <div class="cell-content" :style="{width:width}">
                    <div class="path-zone">
                        <div class="path-left" v-if="item.AcceptTime.length">
                            <text :class="[index==0 ?'des-highlight-time':'des-info-time']">{{time(item.AcceptTime)}}</text>
                            <text :class="[index==0 ?'des-highlight-date':'des-info-date']">{{date(item.AcceptTime)}}</text>
                        </div>
                        <div v-if="index==0" class="path-point">
                            <div class="path-line-top" v-if="traces.length > 1" />
                            <div class="point-highlight" />
                        </div>
                        <div v-else class="path-point">
                            <div v-if="index == traces.length-1" class="path-line-bottom"></div>
                            <div v-else class="path-line"></div>
                            <div class="point" />
                        </div>
                    </div>
                    <div class="path-info">
                        <text v-if="index==0" class="des-info-highlight">【收货地址】{{item.AcceptStation}}</text>
                        <text v-else-if="index==1" class="des-info-new">{{item.AcceptStation}}</text>
                        <text v-else class="des-info">{{item.AcceptStation}}</text>
                    </div>
                </div>
            </div>
        </div>
        <div v-if="data&&!showAll&&data.Traces.length>2" style="height:100px;align-items: center;justify-content: center;">
            <div @click="checkMoreClick" style="flex-direction: row;align-items: center;justify-content: center;">
                <text v-if="showMore" style="color:#999999;font-size:26px;">点击收回物流详情</text>
                <text v-else style="color:#999999;font-size:26px;">点击查看更多物流详情</text>
                <div style="flex-direction: row;align-items: center;justify-content: center;margin-left:10px;border-color:#999;border-width:1px;border-radius:15px;width:30px;height:30px;">
                    <wxc-icon v-if="showMore" name="less" :icon-style="{color:'#999999',fontSize:'30px',paddingTop:5}" @wxcIconClicked="checkMoreClick"></wxc-icon>
                    <wxc-icon v-else name="more_unfold" :icon-style="{color:'#999999',fontSize:'30px',paddingTop:5}" @wxcIconClicked="checkMoreClick"></wxc-icon>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import Fetch from "@/base-superior/Fetch.js";
import { WxcIcon} from 'weex-ui'

const modal = weex.requireModule("modal");
const storage = weex.requireModule("storage");

export default {
    components: {WxcIcon},
    props: {
        data: {
            type: Object,
            default: null
        },
        mainImg: {
            type: String
        },
        width: {
            type: Number,
            default: 750
        },
        showAll:{
            type: Boolean,//默认显示全部物流信息，不显示查看更多
            default: true
        }
    },
    data() {
        return {
            traces:[],
            showMore:false,//showAll为fasle时，默认收起
        }
    },
    create(){
        
    },
    watch:{
        data(newValue, oldValue){
            this.cheackMoreInfo()
        }
    },
    methods: {
        //查看和收缩物流详情
        checkMoreClick:function(){
            this.showMore = !this.showMore;
            this.cheackMoreInfo();
        },
        cheackMoreInfo:function(){
            if(this.showAll){
                this.traces = this.data.Traces;
            }else{
                if(this.data.Traces.length>1 && !this.showMore){
                    this.traces = [this.data.Traces[0],this.data.Traces[1]];
                }else{
                    this.traces = this.data.Traces;
                }
            }
        },
        time: function(date) {
            date = date.replace(/-/g, "/");
            var timestamp = new Date(date);
            return (
                this.prefixInteger(timestamp.getHours()) +
                ":" +
                this.prefixInteger(timestamp.getMinutes())
            );
        },
        date: function(date) {
            date = date.replace(/-/g, "/");
            var timestamp = new Date(date);
            return (
                this.prefixInteger(timestamp.getMonth()+1) +
                "-" +
                this.prefixInteger(timestamp.getDate())
            );
        },
        prefixInteger: function(num) {
            return (Array(2).join(0) + num).slice(-2);
        },
        widthAuto: function(defaultWdith) {
            return defaultWdith * width / 750.0;
        }
    }
};
</script>

<style scoped>
.wrapper {
    align-items: center;
    background-color: white;
}
.cell-content {
    flex-direction: row;
    overflow: hidden;
}
.des-info {
    color: #999999;
    font-size: 28px;
}
.des-info-time {
    color: #999999;
    font-size: 24px;
}
.des-info-date {
    color: #999999;
    font-size: 20px; 
}
.des-highlight-time {
    color: #333333;
    font-size: 24px;
}
.des-highlight-date {
    color: #333333;
    font-size: 20px;
}
.des-info-highlight{
    color: #333333;
    font-size: 28px; 
}
.des-info-new{
    color:#2588f7;
    font-size: 28px; 
}
.path-left {
    width: 140px;
    align-items: center;
    margin-top: 20px;
}
.point {
    position: absolute;
    top: 40px;
    left: 22px;
    width: 16px;
    height: 16px;
    border-radius: 8px;
    background-color: #dddddd;
}
.point-highlight {
    position: absolute;
    top: 40px;
    left: 18px;
    width: 24px;
    height: 24px;
    border-radius: 12px;
    background-color: #ff0033;
    border-width: 4px;
    border-color: #ff9999;
}
.path-zone {
    position:absolute;
    top: 0;
    left: 0;
    bottom: 0;
    width: 220px;
    padding-left: 30px;
    padding-top: 10px;
    padding-bottom: 10px;
}
.path-point {
    width: 60px;
    position: absolute;
    top: 0;
    bottom: 0;
    right: 10px;
    height: 500px;
}
.path-info {
    position: relative;
    width: 490px;
    margin-left: 220px;
    padding-left: 15px;
    padding-top: 35px;
    padding-bottom: 15px;
}
.path-line-top {
    position: absolute;
    width: 2px;
    background-color: #f0f0f0;
    top: 60px;
    bottom: 0;
    left: 29px;
    height: 400px;
    
}
.path-line-bottom {
    position: absolute;
    width: 2px;
    background-color: #f0f0f0;
    top: -10px;
    height: 50px;
    left: 29px;
}
.path-line {
    position: absolute;
    width: 2px;
    left: 29px;
    background-color: #f0f0f0;
    margin-top: -30px;
    height: 400px;
}
</style>
