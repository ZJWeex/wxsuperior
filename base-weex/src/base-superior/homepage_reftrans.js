/* eslint-disable indent */
// 旋转动画参考1：http://dotwe.org/vue/a12521666eb5a44969029fc1299a422a
// 旋转动画参考2: http://dotwe.org/vue/3e8660d7182f24901f122a0855c09370
const animation = weex.requireModule('animation')

export default {
    // el为通过设置节点的ref获取的dom元素
    // 旋转动画angle(0~360)
    transformRotate: function (el, angle) {
        animation.transition(el, {
            styles: {
                transform: 'rotate(' + angle + 'deg)',
                transformOrigin: 'center center'
            },
            duration: 300, // ms
            timingFunction: 'ease',
            needLayout: false,
            delay: 0 // ms
        }, function () {

        })
    },
    transformRotateX: function (el, angle) {
        animation.transition(el, {
            styles: {
                transform: 'rotateX(' + angle + 'deg)',
                transformOrigin: 'center center'
            },
            duration: 300, // ms
            timingFunction: 'ease',
            needLayout: false,
            delay: 0 // ms
        }, function () {

        })
    },
    // scroll下拉滑动放大图片
    scrollScaleTransform: function (el, offsetY) {
        // console.log('el:', el)
        if (offsetY >= 0) {
            var imgH = el.style.height ? el.style.height : 300 //元素高度iOS有效
            var scale = 1 + offsetY / imgH
            animation.transition(el, {
                styles: {
                    transform: 'scale(' + scale + ') ' + 'translateY(-' + offsetY / 2 + ')'
                }
            }, function () { })
        }
    }
}
