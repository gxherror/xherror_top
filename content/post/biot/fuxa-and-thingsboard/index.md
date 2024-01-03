---
title: "fuxa与thingsboard集成"
description: 
date: 2023-12-17T14:30:36Z
image: FuxaThingsboard_ba-style@nulla.top.png
math: 
license: 
hidden: false
comments: true
categories:
    - BIOT
tags:
---
# tb与fuxa对接

## 简介 

ThingsBoard是一个基于Java的开源物联网平台，用于数据收集、处理、可视化和设备管理。与其他开源物联网平台相比，ThingsBoard有以下特点：

1. 组件化规则引擎(rule engine)，通过自定义规则链来处理复杂事件
2. 可自定义的部件(widget)与规则节点(rule node)，方便添加新功能
3. 使用RPC（Remote Procedure Call，远程过程调用）控制设备，实现对建筑设备的控制
4. 可扩展的IOT网关，对接多种IoT设备
5. 多种部署架构，完整的开发文档，较成熟的生态环境
   可自定义的部件与规则节点方便设备管理系统的搭建，IOT网关与RPC方便对设备的统一管理，因此项目选用ThingsBoard来简化开发流程，减低开发复杂度。

[FUXA](https://github.com/frangoteam/FUXA)是基于Web的开源组态软件，可快速构建和部署可扩展的SCADA、HMI或IoT系统，可用于项目中SCADA系统的搭建。

利用iframe将FUXA嵌入tb来实现简单的集成, 并使用adapter来完成JSON格式转化,身份验证等工作

## tb

- 其中`hostname:port`为fuxa地址
- 需要配置HTTPS,不然会报错,配置见fuxa部分

### 自定义widget实现

```html
<!DOCTYPE html>
<html>
<head>
</head>
<body>
    <iframe src="https://hostname:port/" width="1900" height="950" >
    </iframe>
</body>
</html>
```

```js
self.onInit = function() {
    const data = JSON.stringify({
        "userId": self.ctx.currentUser.userId,
        "jwt_token": localStorage.jwt_token,
        "refresh_token": localStorage.refresh_token
    });
    console.log(self.ctx.currentUser.userId);
    var httpRequest = new XMLHttpRequest();
    httpRequest.open('POST', '/adapter/userinfo', true);
    //post方式必须设置请求头（在建立连接后设置请求头）
    httpRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    httpRequest.send(data);
    httpRequest.onreadystatechange =function() { 
        if (httpRequest.readyState == 4 && httpRequest.status == 200) { 
            var json = httpRequest.responseText; 
            //将从服务器获取的json传给本地fuxa
            var forwardRequest = new XMLHttpRequest();
            forwardRequest.open('POST', `https://hostname:port/api/project?userId=${self.ctx.currentUser.userId}`, true);
            forwardRequest.setRequestHeader("Content-Type","application/json");
            forwardRequest.send(json);
        }
    };
};

```

### 修改源码实现

新建module,并编写逻辑

```bash
$cd ui-ngx/src/app/modules/home/pages/
# {name} 这里是fuxa
$ng g module {name} --routing
$ng g c {name}
```

会生成如图所示的文件结构,在componemt写逻辑

![image-20231219215229592](/images/image-20231219215229592.png)

```ts
//fuxa-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { FuxaComponent } from './fuxa.component';

const routes: Routes = [
  {
    path: "fuxa",
    component: FuxaComponent,
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class FuxaRoutingModule { }
```

```ts
//fuxa.component.ts
import { Component } from '@angular/core';
import {getCurrentAuthUser } from '@app/core/public-api';
import { Store } from '@ngrx/store';
import { AppState } from '@core/core.state';
@Component({
  selector: 'tb-fuxa',
  templateUrl: './fuxa.component.html',
  styleUrls: ['./fuxa.component.scss']
})
export class FuxaComponent {
  constructor(private store: Store<AppState>) {
}
  // 在module加载时起作用
  ngOnInit() {
    const data = JSON.stringify({
      //! userId的获取方法
      userId: getCurrentAuthUser(this.store).userId,
      jwt_token: localStorage.getItem('jwt_token'), 
      refresh_token: localStorage.getItem('refresh_token') 
    });
    const httpRequest = new XMLHttpRequest();
    httpRequest.open('POST', 'https://hostname:port/adapter/userinfo', true);
    httpRequest.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    httpRequest.send(data);
    httpRequest.onreadystatechange = () => { 
      if (httpRequest.readyState === XMLHttpRequest.DONE && httpRequest.status === 200) {
        const json = httpRequest.responseText;
        const forwardRequest = new XMLHttpRequest();
        forwardRequest.open('POST', `https://hostname:port/api/project?userId=${getCurrentAuthUser(this.store).userId}`, true);
        forwardRequest.setRequestHeader("Content-Type", "application/json");
        forwardRequest.send(json);
      }
    };
  }
}
```

```ts
//fuxa.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { FuxaRoutingModule } from './fuxa-routing.module';
import { FuxaComponent } from './fuxa.component';


@NgModule({
  declarations: [
    FuxaComponent
  ],
  imports: [
    CommonModule,
    FuxaRoutingModule
  ]
})
export class FuxaModule { }
```

修改menu显示的内容,注意不同角色对应的函数不同,有需要的话需要修改对应的函数

```ts
// ui-ngx/src/app/core/services/menu.service.ts
private buildSysAdminMenu(): Array<MenuSection> {
    const sections: Array<MenuSection> = [];
    sections.push(
      {
        id: 'home',
        name: 'home.home',
        type: 'link',
        path: '/home',
        icon: 'home'
      },

      // 新建菜单FUXA begin
      {
        id: 'fuxa',
        name: 'fuxa',
        type: 'link',
        path: '/fuxa',
        icon: 'mdi:layers-edit'
      },
      // 新建菜单FUXA end
      ....
    }
}
```

最终实现的效果

![image-20231219214656271](/images/image-20231219214656271.png)

http://www.yuhangwei.com/web/note/2021-07-28/68.html

## fuxa

由于开源的fuxa没有多项目管理的功能的[问题](https://github.com/frangoteam/FUXA/discussions/379),需要进行修改

### 调整api路由

```js
app: function () {
    var prjApp = express();
    //用于传递userId
    var localUserId;
    prjApp.use(function(req,res,next) {
        if (!runtime.project) {
            res.status(404).end();
        } else {
            next();
        }
    });

    /**
         * POST Project data
         * Set to project storage
         */
    prjApp.post("/api/project", secureFnc, function(req, res, next) {
        //存储userId
        if(req.query.userId){
            localUserId = req.query.userId;
        }
        console.log(localUserId);
        ...
    });

    /**
         * POST Single Project data
         * Set the value (general/view/device/...) to project storage
         */
    prjApp.post("/api/projectData", secureFnc, function(req, res, next) {
        ...
        //更新服务器json
        runtime.project.getProject(req.userId, groups).then(result => {
            if (result) {
                console.log(result);
                const axios = require('axios');
                console.log(localUserId);
                axios.post(`https://you.host.name/adapter/project?userId=${localUserId}`, result);
            } else {
                runtime.logger.error("api get project: Not Found!");
            }
        });
    });
}
```

### 配置https

https://developer.aliyun.com/article/1173617

https://blog.51cto.com/momolinux/2679299

```bash
# 生成私钥
$openssl genrsa -out key.pem

# 创建 CSR（证书签名请求）,内容需要认真填写
$openssl req -new -key key.pem -out csr.pem

# 创建openssl配置文件
# 解决 NET::ERR_CERT_COMMON_NAME_INVALID
$cat ssl.cnf
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = www.xxxxx.com

# 自己作为证书颁发机构,向自己生成SSL证书=.=
# 注意证书格式为crt,chrome不接收pem格式的
$openssl x509 -req -days 365 -in csr.pem -signkey key.pem -out cert.crt -extfile ssl.cnf
```

将cert.crt与key.pem放在_appdata中,设置settigns.json

```js
const fs = require('fs');
module.exports = {
    ...
    // See http://nodejs.org/api/https.html#https_https_createserver_options_requestlistener
    // for details on its contents.
    // See the comment at the top of this file on how to load the `fs` module used by
    // this setting.
    //
    https: {
       key: fs.readFileSync('key.pem'),
       cert: fs.readFileSync('cert.crt')
    },
    ...
}
```

添加自签证书到chrome,解决`NET::ERR_CERT_AUTHORITY_INVALID`

![Screenshot 2023-12-17 011252](/images/Screenshot-2023-12-17-011252.png)

### wsl问题

可以使用vscode简单实现wsl到win的端口映射,但一定一定要`***\**\*netstat -aon|findstr "{port}"`

## adapter

1. 实现tb的JSON格式到FUXA的JSON格式的转换

2. 定时获取JWT Token

3. 对RPC API添加JWT

4. 管理不同用户的json

```go
func main() {
	 r := gin.Default()
	 go getJWTTokenPeriodly()
	 r.POST("/adapter/userinfo",UserInfoHandler)
	 r.GET("/adapter/api/plugins/telemetry/DEVICE/*deviceID", ProxyTelemetry)
	 r.POST("/adapter/project", ProjectPostHandler)
	 r.POST("/adapter/api/plugins/rpc/*suffix", ProxyRpc)
	 log.Fatal(r.Run(":8082"))
}
```

# fuxa与设备对接

- 注意fuxa与设备的通讯**均通过adapter**,不进行直接通讯

  ## fuxa显示mqtt设备状态

### tb获取设备数据的RESTful

https://thingsboard.io/docs/user-guide/telemetry/#get-latest-time-series-data-values-for-specific-entity

https://github.com/frangoteam/FUXA/wiki/HowTo-Devices-and-Tags

```shell
curl -v -X GET http(s)://host:port/api/plugins/telemetry/{entityType}/{entityId}/values/timeseries?keys=key1,key2,key3 \
--header "Content-Type:application/json" \
--header "X-Authorization: $JWT_TOKEN"
```

### fuxa设置

![image-20231217214742978](/images/image-20231217214742978.png)

### adapter设置

```go
//删除了err != nil 的判定
func ProxyTelemetry(c *gin.Context) {
	deviceID := c.Param("deviceID")
	originalURL := fmt.Sprintf("https://your.host.name/api/plugins/telemetry/DEVICE%s", deviceID)
	var err error
	req, err = http.NewRequest("GET", originalURL, nil)
	if err != nil {
		c.JSON(http.StatusBadRequest, err.Error())
		return
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Authorization", userinfo.JwtToken)

	client := &http.Client{}
	resp, err := client.Do(req)
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if resp.StatusCode != http.StatusOK {
		c.String(resp.StatusCode, "upstream server response status: %d", resp.StatusCode)
		return
	}

	var inputData InputJSON
	if err := json.Unmarshal(body, &inputData); 

	outputData := OutputJSON{
		Temperature: getValue(inputData.Temperature),
		Version:     getValue(inputData.Version),
		Name:        getValue(inputData.Name),
		Position:    getValue(inputData.Position),
		Status:      getValue(inputData.Status),
	}

	c.JSON(http.StatusOK, outputData)
}
```

## fuxa控制mqtt设备

### fuxa调用RPC API

http://www.ithingsboard.com/docs/user-guide/rpc/#rest-api

```shell
curl -v -X POST -d @set-gpio-request.json http(s)://host:port/api/plugins/rpc/{callType}/{deviceId} \
--header "Content-Type:application/json" \
--header "X-Authorization: $JWT_TOKEN"
```

```json
{
   //必须
   "method": "setStatus",
   //必须
   "params": {
     "value": 1
   },
  "timeout": 30000
}
```

### fuxa设置

```js
const https = require('https')

const data = JSON.stringify({
   "method": "setStatus",
   "params": {
     "value": $getTag('t_673c961d-cb494ad8' /* FUXA Server - device01input */)
   }
})
const options = {
  hostname: 'your.host.name',
  port: 443,
  path: '/adapter/api/plugins/rpc/twoway/{deviceId}',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  }
}

const req = https.request(options, res => {
  console.log(`状态码: ${res.statusCode}`)

  res.on('data', d => {
    process.stdout.write(d)
  })
})

req.on('error', error => {
  console.error(error)
})

req.write(data)
req.end()
```

### adapter设置

```go
//删除了err != nil 的判定
func ProxyRpc(c *gin.Context) {
	suffix := c.Param("suffix")
	originalURL := fmt.Sprintf("https://your.host.name/api/plugins/rpc%s", suffix)

	reqBody, err := io.ReadAll(c.Request.Body)
	defer c.Request.Body.Close()

	req, err = http.NewRequest(c.Request.Method, originalURL, bytes.NewReader(reqBody))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("X-Authorization", userinfo.JwtToken)

	client := &http.Client{}
	resp, err := client.Do(req)
	defer resp.Body.Close()

	respBody, err := io.ReadAll(resp.Body)
    
	if resp.StatusCode != http.StatusOK {
		c.String(resp.StatusCode, "upstream server response status: %d", resp.StatusCode)
		return
	}

	c.Data(resp.StatusCode, "application/json", respBody)
}

```

### 
https://lab.nulla.top/ba-logo
