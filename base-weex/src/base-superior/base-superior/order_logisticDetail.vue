<template>
    <div class='wrapper'>
        <navigation title="物流详情"/>
        <div style="flex:1">
            <list class="list">
                <cell>
                    <div class="header">
                        <div class="header-left">
                            <image class="img" :src="mainImg"/>
                            <div>
                                <text style="color:#333333;font-size:32px;padding-bottom:10px;">快递：{{data.ShipperName}}</text>
                                <text style="color:#999999;font-size:32px;">编码：{{data.LogisticCode}}</text>
                            </div>
                        </div>
                        <text v-if="data.State=='2'" style="margin:24px;font-size:30px;color:#e0a537;">在途中</text>
                        <text v-else-if="data.State=='3'" style="margin:24px;font-size:30px;color:#31b70d;">已签收</text>
                        <text v-else style="margin:24px;font-size:30px;color:#31b70d;">待揽收</text>
                    </div>
                </cell>
                <cell>
                    <div v-for="(item,index) in data.Traces" :key="index" class="cell-content">
                        <div v-if="index==0" style="align-items:center;width:60px;">
                            <div class="point-highlight"></div>
                            <div style="width:2px;flex:1;background-color:#f0f0f0;"></div>
                        </div>
                        <div v-else style="align-items:center;width:60px;">
                            <div style="width:2px;flex:1;background-color:#f0f0f0;"></div>
                            <div class="point"></div>
                        </div>
                        <div style="flex:1;margin-right:24px;border-bottom-width:2px;border-bottom-color:#f9f9f9;">
                            <div v-if="index == 0">
                                <text class="des-highlight">{{item.AcceptStation}}</text>
                                <text class="des-highlight">{{item.AcceptTime}}</text>
                            </div>
                            <div v-else>
                                <text class="des-info">{{item.AcceptStation}}</text>
                                <text class="des-info">{{item.AcceptTime}}</text>
                            </div>
                        </div> 
                    </div>
                </cell>
                <cell>
                    <div class="footer"></div>
                </cell>
            </list>
        </div>
    </div>
</template>

<script>
import navigation from "@/base-superior/components/NavigationBar.vue";
import Fetch from "@/base-superior/Fetch.js";

const modal = weex.requireModule('modal');
const storage = weex.requireModule("storage");

export default {
    components: { navigation },
    data() {
        return {
            logisticNumber:'',//物流号
            mainImg:'',//商品图片URL
            data:{"State": "",//物流状态:0-待揽收,2-在途中,3-签收，其中如果是2而且Traces是空或者Traces不存在，提示“商品已发出，暂无轨迹更新”，4-问题件，直接显示“商品已发出，暂无轨迹更新”；
                   "ShipperName": "",//物流名称
                   "LogisticCode": "",//物流单号
                   "Traces":[
                            /*{
                                "AcceptStation": "到达：上海青浦区华新镇公司华新工业区服务部 已收件",
                                "AcceptTime": "2017 - 05 - 07 19 : 17 : 18"
                            }*/
                   ]},
        }
    },
    created() {
         storage.getItem('Order_logisticCode', event => {
          console.log('物流订单号:', event.data)
          if(event.data && event.data != 'undefined'){
              var obj = JSON.parse(event.data);
              this.logisticNumber = obj.logisticCode;
              if(obj.photos.length>0){
                  this.mainImg = obj.photos[0];
              }
              this.loadLogisticInfo();
              storage.removeItem('Order_logisticCode',event => {})
          }
        });
    },
    methods: {
        //加载物流信息
        loadLogisticInfo:function(){
             const self = this;
            var param = {logisticCode:this.logisticNumber}
            Fetch.post('track/superiorLogisticDetail.json', param, function(respone){
                console.log('物流:'+respone);
                var result = JSON.parse(respone);
                if(result.op_flag == 'success'){
                    if(result.objs.Traces==undefined || result.objs.Traces.length == 0){
                        result.objs.Traces = [{AcceptStation:"商品已发出，暂无轨迹更新",
                                               AcceptTime:''}]
                    }
                    self.data = result.objs;
                }else{
                    modal.toast({message:result.info})
                }
            }, function(err){
                modal.toast({message:'错误信息:'+err})
            });
        },
    }
}
</script>

<style scoped>
.wrapper { 
    align-items: center;
}
.list{
    width: 750px;
    flex: 1;
}
.header {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    border-bottom-width: 2px;
    border-bottom-color: #f0f0f0;
}
.header-left{
    flex-direction: row;
    align-items: center;
    flex: 1;
}
.img {
    border-width: 2px;
    border-radius: 5px;
    border-color: #f0f0f0;
    width: 150px;
    height: 110px;
    margin-left: 24px;
    margin-top: 24px;
    margin-bottom: 24px;
    margin-right: 10px;
}
.cell-content{
    flex-direction: row;
}
.point {
    position: absolute;
    top:20px;
    left: 22px;
    width: 16px;
    height:16px;
    border-radius: 8px;
    background-color: #dddddd;
}
.des-info {
    color: #999999;
    font-size: 28px;
    padding:10px;
}
.des-highlight {
    color: #31b70d;
    font-size: 28px;
    padding:10px;
}
.point-highlight {
    margin-top: 20px;
    width: 24px;
    height:24px;
    border-radius: 12px;
    background-color: #31b70d;
    border-width: 4px;
    border-color: rgb(49, 246, 13)
}
.footer {
    height: 40px;
}
</style>
