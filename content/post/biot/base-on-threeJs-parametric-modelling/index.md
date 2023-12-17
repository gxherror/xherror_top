---
title: "基于Three.js的参数化建模"
description: 项目
date: 2023-11-13T07:25:07Z
image: papametric-model.png
math: 
license: 
hidden: false
comments: true
categories:
    - BIOT
tags:
---
## 简介

参数化建模是一种一旦修改尺寸值就能够改变模型几何形状的建模过程。参数建模是通过设计计算机编程代码如脚本来定义模型的尺寸和形状。模型可以在三维绘图程序中可视化，以模拟原始项目的真实行为特征。参数模型通常使用基于特征的建模工具来操纵模型的属性。

## Three.js

Three.js是一款基于原生WebGL封装通用Web 3D引擎，使用JavaScript函数库或API来在网页浏览器中创建和展示动画的三维计算机图形。Three.js使用WebGL，允许使用JavaScript创建网页中的GPU加速的3D动画元素，而不是使用特定的浏览器插件。Three.js框架的运用能够让Web3D更加实用、便捷，能够充分发挥渲染器、模型、光源等功能进行3D场景的创建。由于Three.js是运用JavaScript编写的，这就使得Three.js的兼容性变得更强，由此就能实现二次开发，运用热点交互，促使用户在运用Web3D时能够拥有更强的交互性。

### 建模基本流程

在构建基于Three.js的三维模型的过程中，我们首先初始化一个场景对象（Scene），该对象为虚拟物体和光源的放置提供了一个上下文环境。随后，构建一个或多个照相机（Camera）实例，其中透视投影照相机（PerspectiveCamera）因其近似人眼视角的特性，被广泛应用。渲染器（Renderer）一般采用利用WebGL渲染器（WebGLRenderer）以利用GPU的加速特性。

随后涉及的是几何体（Geometry）的创建，它定义了三维物体的结构和顶点。Three.js内置了丰富的基础几何形状库，同时也支持更复杂模型的导入。与几何体相配套的材质（Material）定义了物体的表面特性，包括但不限于颜色、纹理和材料响应光照的特性。

通过结合特定的几何体与材质，生成网格（Mesh）对象，并将其添加至场景当中。此外，为了模拟真实环境中的光照效果，需要引入灯光（Light）实体，Three.js提供了多种光源类型以满足不同光照需求。为实现动态效果或交互响应，可以在渲染过程中制定动画函数和交互逻辑。实现此功能一般依赖于持续的渲染循环（Render Loop），用以定期更新场景、相机状态和渲染输出。

最终经过渲染器处理的图像将展示在用户的浏览器中。整个过程通过脚本逻辑控制，可以产生静态的三维模型展示也可以实现复杂的三维动画效果。

![image-20231113131618976](/images/image-20231113131618976.png)



## 项目实现

### 参数化建模

以三维框架为例参数化建模的流程如下所示：

1. 点击三维桁架按钮，输入三维框架的参数，提交表格，由submit3DTrussForm方法进行参数解析。

![image-20231113132149398](/images/image-20231113132149398.png)

```html
<!--HTML文件-->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>My first three.js app</title>
    <!--弹窗实现-->
    <style>
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgb(0,0,0);
            background-color: rgba(0,0,0,0.4);
            padding-top: 60px;
        }

        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
        }

        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }
        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <button onclick="open3DTrussForm()">三维桁架</button>
    <div id="3DTrussModal" class="modal">
        <div class="modal-content">
        <span class="close" onclick="close3DTrussForm()">&times;</span>
        <form id="3DTrussForm">
            <label>开间数X:</label><input type="number" id="3DTruss-bayNumberX"  value="2"><br>
            <label>开间数Y:</label><input type="number" id="3DTruss-bayNumberY"  value="3"><br>
            <label>跨度X:</label><input type="number" id="3DTruss-widthX"  value="3"><br>
            <label>跨度Y:</label><input type="number" id="3DTruss-widthY"  value="3"><br>
            <label>X向分段数:</label><input type="number" id="3DTruss-spanX"  value="3"><br>
            <label>Y向分段数:</label><input type="number" id="3DTruss-spanY"  value="3"><br>
            <label>高度:</label><input type="number" id="3DTruss-height"  value="3"><br>
            <button type="button" id="3DTrussFormButton" onclick="submit3DTrussForm()">提交</button>
        </form> 
        </div>
	</div>
    <button type="button" id="buttonLine">画线</button>
    <div id="canvas"></div>
    <script type="module" src="main.js"></script>	
    <script>
        function open3DTrussForm() {
            document.getElementById('3DTrussModal').style.display = "block";
        }
        function close3DTrussForm() {
            document.getElementById('3DTrussModal').style.display = "none";
        }
        function submit3DTrussForm() {
            var bayNumberX = document.getElementById('3DTruss-bayNumberX').value;
            var bayNumberY = document.getElementById('3DTruss-bayNumberY').value;
            var widthX = document.getElementById('3DTruss-widthX').value;
            var widthY = document.getElementById('3DTruss-widthY').value;
            var spanX = document.getElementById('3DTruss-spanX').value;
            var spanY = document.getElementById('3DTruss-spanY').value;
            var height = document.getElementById('3DTruss-height').value;
            // Convert input string values to integers if necessary
            bayNumberX = parseInt(bayNumberX, 10);
            bayNumberY = parseInt(bayNumberY, 10);
            widthX = parseInt(widthX, 10);
            widthY = parseInt(widthY, 10);
            spanX = parseInt(spanX, 10);
            spanY = parseInt(spanY, 10);
            height = parseInt(height, 10);
            document.getElementById('3DTrussModal').style.display = "none";
            console.log(bayNumberX, bayNumberY, widthX, widthY, spanX, spanY, height);
            window.generate3DTruss(bayNumberX, bayNumberY, widthX, widthY, spanX, spanY, height);
        }
    </script>	
</body>
</html>
```

2.  由于Three.js默认为右手坐标系，绘制轴网前需要进行坐标轴转换。
3.  由于框架的特征对于第二层及以上的杆件与交点可以按照绘制轴网的方式进行绘制，仅需要对绘制的材质进行调整，在代码中表现为generate3DGrid方法最后一位的真假值；而第一层交点需要单独绘制。
4.  绘制第一层的竖向支撑，注意这里的Y向为右手坐标系的Y向，后文也默认为右手坐标系的Y向。
5.  绘制框架的支撑，这里支撑存在负Y向的偏移量为方便后续选点画线操作。
6.  更新交互空间，用于后续选点绘线时实时显示当前轨迹。

![image-20231113132751254](/images/image-20231113132751254.png)

```js
function generate3DFrame(bayNumberX,bayNumberY,floorNumber,widthX,widthY,height) {
    //坐标轴转换,绘制轴网
    generate3DGrid(bayNumberX,floorNumber,bayNumberY,widthX,height,widthY,0,0,0,false);
    
    //坐标轴转换,绘制杆件
    generate3DGrid(bayNumberX,floorNumber-1,bayNumberY,widthX,height,widthY,0,height,0,true);
    
    //坐标轴转换,绘制交点
    generate3DPoints(bayNumberX,0,bayNumberY,widthX,0,widthY,0,0,0,true);

    //绘制Y向线
    var points = [];
    points.push(new THREE.Vector3(0, 0,0));
    points.push(new THREE.Vector3(0, height,0));
    var bufferGeometry = new THREE.BufferGeometry().setFromPoints(points);
    for (var i = 0; i <= bayNumberX; i++) {
        for (var j = 0; j <= bayNumberY; j++) {
            let lineY = new THREE.Line(bufferGeometry, lineMaterial);
            lineY.position.x = i*widthX;
            lineY.position.z = j*widthY;
            scene.add(lineY);
        }
    }

    //绘制支撑
    support(bayNumberX,bayNumberY,widthX,widthY,0,-0.25);

    //交互空间更新
    updateIntersectMesh(bayNumberX*widthX,floorNumber*height,bayNumberY*widthY,0,0,0);
}
```

### 选点绘线

选点绘线功能实现在参数化建模后进行结构修改，或是直接在轴网之上构建自定义模型，其流程如下所示：

1. 监听鼠标点击与鼠标移动事件，来实现选点与实时轨迹显示。
2. 进行屏幕坐标到标准设备坐标的转换，用于确定鼠标咋在显示设备上的标准坐标。
3. 使用光线投射对象（Raycaster）来确定鼠标选中的点，当该点为选中的第一个点，绘制球面来表示起始点对象；当该点为选中的第二个点，删除轨迹线，绘制支撑线，并绘制结束点。
4. 设置raycaster.params.Line.threshold为0.1来避免选中支撑。
5. 利用鼠标移动时与交互空间的交点与起始点来绘制轨迹线。

![image-20231113132737289](/images/image-20231113132737289.png)

```js
window.addEventListener('click', onMouseClick, false);
window.addEventListener('mousemove', onMouseMove, false);
let intersectGeometry = null;
let intersectMaterial = null;
let intersectMesh = null;
function onMouseClick(event) {
    event.preventDefault();
    if (flagLine){
        let raycaster = new THREE.Raycaster();
        let mouse = new THREE.Vector2();
        mouse.x = (event.offsetX / window.innerWidth) * 2 - 1;
        mouse.y = -(event.offsetY / window.innerHeight) * 2 + 1;
        raycaster.setFromCamera(mouse, camera);
        //!避免选到支撑
        raycaster.params.Line.threshold = 0.1;
        var intersects = raycaster.intersectObjects(scene.children);
        if (intersects.length > 0 && intersects[0].object.name === 'point') {
            if (!lineStartFlag){
                console.log("选中起始点");
                lineStartFlag = true;
                startPoint = intersects[0].object.position;
                if (lineTemp) {
                    scene.remove(lineTemp);
                }
                const points = [startPoint.clone(), startPoint.clone()];
                const geometry = new THREE.BufferGeometry().setFromPoints(points);
                lineTemp = new THREE.Line(geometry, lineMaterial);
                scene.add(lineTemp);

                //绘制起始点
                let sphere1 = new THREE.Mesh(sphereGeometry, sphereMaterial);
                sphere1.position.set(startPoint.x,startPoint.y,startPoint.z);
                scene.add(sphere1);
            }else{
                console.log("画线");
                lineStartFlag = false;
                flagLine = false;
                const points = [startPoint.clone(), intersects[0].object.position];
                const bufferGeometry = new THREE.BufferGeometry().setFromPoints(points);
                var linePermanent = new THREE.Line(bufferGeometry, lineMaterial);
                scene.remove(lineTemp);
                scene.add(linePermanent);
                //绘制结束点
                let sphere2 = new THREE.Mesh(sphereGeometry, sphereMaterial);  sphere2.position.set(intersects[0].object.position.x,intersects[0].object.position.y,intersects[0].object.position.z);
                scene.add(sphere2);
            }
            
        }
    }
}
function onMouseMove(event) {
    if (!lineStartFlag) return;
    let raycaster = new THREE.Raycaster();
    let mouse = new THREE.Vector2();
    mouse.x = (event.offsetX / window.innerWidth) * 2 - 1;
    mouse.y = -(event.offsetY / window.innerHeight) * 2 + 1;
    raycaster.setFromCamera(mouse, camera);
    //!避免选到支撑
    raycaster.params.Line.threshold = 0.1;
    let intersects = raycaster.intersectObject(intersectMesh);
    lineTemp.geometry.setFromPoints([startPoint.clone(),intersects[0].point]);
    lineTemp.geometry.verticesNeedUpdate = true;
}
```

### 项目成果

项目实现轴网、梁、二维桁架、三维桁架、二维框架、三维框架、墙的参数化建模，可以进行选点画线，可以通过网页http://model.xherror.top/访问。项目实现的基于Three.js的参数化建模与SAP2000建模相比：

1）无需使用专业软件，利用常见的Web浏览器即可实现参数化建模，模型更加直观。

2）视角切换更加自由灵活，模型渲染速度更快，对主机的配置没有需求，更加轻量化。

3）采用JavaScript编写，扩展性高，方便后续集成到统一的建筑数字管理平台。

### 项目缺陷

项目目前仅实现了基础模型的参数化建模，仅有简单的选点绘线功能，缺少对复杂模型网格化建模的支持与删除、撤销操作等功能。





https://threejs.org/

http://www.webgl3d.cn/pages/4a14ce/

https://blog.csdn.net/weixin_38245190/article/details/104721516

http://word.wd1x.com/