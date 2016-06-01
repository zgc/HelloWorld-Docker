第一次写README，不知道写什么！<br />
这个Dockerfile的诞生是因为git@oschina提供了灵雀云的演示，却没提供相应的Dockerfile，而却灵雀云官方也没提供，所以只好自己去琢磨写一个。<br />
Dockerfile里面的tomcat部分是参考了docker官方的 [tomcat Dockerfile](https://hub.docker.com/_/tomcat)。<br />
网上流传的tomcat Dockerfile都是基于open-jdk，但是maven对open-jdk支持不好，所以只好自己动手换成oracle-jdk。<br />
在摸索过程中遇到了中文乱码（已解决）、时间不对（已解决）、上传war包很麻烦（我很懒，直接用maven打包war，启动就可以用），总体感觉docker很强大。<br />
吐槽一下灵雀云，现在居然不能领优惠券，以后只能自己掏钱玩了。。。<br />
我的javaweb源码只是个demo，不要在意写得好不好，请勿吐槽我，我受不了！！！请直接告诉我该怎么做，谢谢。