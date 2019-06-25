# TMInterface

接口库，封装了网络请求协议和请求对象管理，目的是方便接口的封装、调用、复用。

# Requirements

iOS 8.0

# Install

``` Podfile
# 接口库基类
pod 'TMInterface', '~>1.0'
# 网络类型
pod 'TMInterface/NetwrokType', '~>1.0'
```

# Import

``` Objective-C
/*
  接口库基类
*/
#improt <TMInterface/TMInterface.h>
```

# Usage

Todo: 补充使用文档

# NetwrokType 子模块

TMNetwrokTypeManager 封装了风灵各接口协议中，部分接口需要使用的客户端网络类型，包括WIFI、移动、电信、联通等网络类型。该模块依赖于 AFNetworking 的 Reachability 子模块，项目一旦包含 TMNetwrokTypeManager 类，在程序启动时，会自动开启 AFNetworking 的网络状态监控功能，建议不要再重复启用。

# Author

CodingPub, lxb_0605@qq.com

# License

TMInterface is available under the MIT license. See the LICENSE file for more info.
