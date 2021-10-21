#python
<pre>
python开发需要掌握的：
1. 平台：类unix平台
2. 系统：线程、进程、shell编程
3. 网络：网络原理、HTTP协议。Socket开发、异步IO开发。
4. WEB开发：偏后端。MVC框架要求会Django、Flask、Tornado之一。
5. 算法要求：转置矩阵、求质数等现场能写
6. 数据库：关系型数据库至少会MySql,NoSQL应该，最好会一个。
7. 可视化：WEB的前端开发多一些HTML、JS要会
课程体系：
1. 基础：操作系统、网络基础、数据库基础、Python语言基础...
2. 进阶：函数封装思想、面向对象设计、装饰器、描述器...
3. 高级：网络编程、并发编程、ORM、最新前端架构开发（ES6、React）...
4. 实战：WEB框架、博客系统、CMDB、跳板机...
职业方向：
1. 运维自动化工程师：需求多样，问题复杂
2. 全栈工程师：偏向WEB开发，指的是WEB前后端开发。
3. 大数据开发工程师：部分可以使用Python语言完成，注重算法应用
4. 分析工程师：科学计算，数据建模，注重算法的设计(对学历数学有要求)
5. AI：facebook算法框架PyTorch(对学历数学有要求)

#shell基础
fork炸弹(将会快速未尽系统资源)：
:(){ :|:& };:
bomb(){ bomb | bomb & }; bomb
脚本实现：
vim Bomb.sh
#!/bin/sh
./$0 | ./$0&


#Python之旅
#pyenv: 
https://github.com/pyenv/pyenv
https://github.com/pyenv/pyenv-installer
[root@master ~]# yum install -y git
[root@master ~]# yum install -y gcc make patch gdbm-devel openssl-devel sqlite-devel readline-devel zlib-devel bzip2-devel libffi-devel
[root@master ~]# useradd python
[root@master ~]# echo 'python' | passwd python --stdin
--使用python用户登录
[python@master ~]$ curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
[python@master ~]$ cat ~/.bash_profile
export PATH
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
[python@master ~]$ source ~/.bash_profile
[python@master ~]$ pyenv install -l
[python@master ~]$ pyenv version
system (set by /home/python/.pyenv/version)
[python@master ~]$ pyenv versions
* system (set by /home/python/.pyenv/version) #此时系统版本是2.7.5
--安装python3.7.0版本
[python@master ~/.pyenv]$ mkdir ~/.pyenv/cache
[python@master ~]$ cd ~/.pyenv/cache/
--下载install 3.7.0的版本时下载太慢，所以事先先下载到这个目录下，软件版本跟安装时的版本要一致，有时候是tar.gz包
[python@master ~/.pyenv/cache]$ curl -OL http://unzip.top:8088/software/Python-3.7.0.tar.xz
[python@master ~]$ pyenv install 3.7.0 -v
[python@master ~/.pyenv/cache]$ pyenv versions
* system (set by /home/python/.pyenv/version)
  3.7.0
[python@master ~]$ pyenv install 3.5.3 -v
[python@master ~/.pyenv/cache]$ pyenv versions
* system (set by /home/python/.pyenv/version)
  3.5.3
  3.7.0
--------
pyenv global version  #应用全局 
pyenv shell version  #应用当前shell，shell关闭则版本失效
pyenv local version  #应用当前目录版本
pyenv update #更新pyenv
--------
Directory:
web --> python3.7.0
web/blog --> virtualenv
cmdb --> python3.5.3
[python@master ~]$ mkdir -p ~/projects/web/blog
[python@master ~]$ mkdir -p ~/projects/cmdb
[python@master ~/projects/web]$ pyenv local 3.7.0
[python@master ~/projects/web]$ pyenv version
3.7.0 (set by /home/python/projects/web/.python-version)
[python@master ~/projects/web/blog]$ pyenv virtualenv 3.5.3 blog3.5.3
[python@master ~/projects/web/blog]$ pyenv local blog3.5.3 
(blog3.5.3) [python@master ~/projects/web/blog]$ python -V
Python 3.5.3
[python@master ~/projects/cmdb]$ pyenv local 3.5.3
[python@master ~/projects/cmdb]$ python -V
Python 3.5.3
#pip
[python@master ~/projects/cmdb]$ mkdir ~/.pip
[python@master ~/projects/cmdb]$ vim ~/.pip/pip.conf
[global]
timeout = 6000
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
[python@master ~/projects/cmdb]$ pip -V #pip跟pyenv版本走
pip 9.0.1 from /home/python/.pyenv/versions/3.5.3/lib/python3.5/site-packages (python 3.5)
[python@master ~/projects/cmdb]$ pip install redis
[python@master ~/projects/cmdb]$ pip install ipython
[python@master ~/projects/cmdb]$ pip install Jupyter
[python@master ~/projects/cmdb]$ jupyter notebook password #设置jupyter密码
magedu:magedu
[python@master ~/projects/cmdb]$ jupyter notebook --ip=0.0.0.0 --no-browser
访问：http://192.168.15.199:8888/输入密码即可
----pip包的导出和导入
[python@master ~/projects/cmdb]$ pip freeze > packages.txt  #导出
(blog3.5.3) [python@master ~/projects/web/blog]$ pip install -r ~/projects/cmdb/packages.txt  #导入

#低级语言到高级语言：
c,c++等语言是编译型语言
java,python,c#,php等是解释型语言，把源代码解释编译成中间语言(字节码byteCode),然后运行在虚拟机上，java的虚拟机是JVM,python的虚拟机是PVM
高级语言的发展：
1. 非结构化语言
2. 结构化语言
3. 面向对象语言：更接近人类认知的放言，封装，继承，多态。
4. 函数式语言：古老的编程范式，应用在数学计算，并行处理场景。引入到现代高级语言中。
#程序
--什么是程序
1. 算法 + 数据结构 = 程序
2. 数据是一切程序的核心
3. 数据结构是数据在计算机中的类型和组织方式
4. 算法是处理的数据方式，算法有优劣之分。
--写程序难点
1. 理不清数据
2. 搞不清处理方法
3. 无法把数据设计转换成数据结构，无法把处理方法转换成算法。
4. 无法用设计范式来进行程序设计。
5. 世间程序皆有bug,但不会debug.
#python解释器
1. 官方CPython: c语言开发，最广泛的python解释器
2. IPython：一个交换式，功能增加的cpython
3. pypy: python语言写的python解释器，JIT技术，动态编译python代码(效率双Cpythonn快1到5倍)
4. Jython： python的源代码编译成Java的字节码，跑在JVM上
5. IronPython：与Jython类似，运行在.Net平台上的解释器，python代码被编译成.Net的字节码。

python的语言类型：
1. python，ruby,perl,JavaScript等是动态类型语言
2. java，c,c++,c#等是静态类型语言
3. 强制类型转换是强类型，python是强类型
4. 不强制类型转换是弱类型，JavaScript是弱类型

python内存管理：
1. 变量无须事先声明，也不需要指定类型：动态语言的特性
2. 编程中一般无须关心变量的存亡，也不用关心内存的管理
3. python使用引用计数记录所有变量的引用数
	1. 当变量引用数变为0，它就可以被垃圾回收GC
	2. 计数增加：赋值给其它变量就增加引用计数，例如x=3;y=x
	3. 计数减少：
		1. 函数运行结束时，局部变量就会被自动销毁，对象引用计数减少。
		2. 变量被赋值给其它对象。例如x=3;y=x;x=4
	4. 有关性能的时候，就需要考虑变量的引用问题，是该释放内存，还是尽量不释放内存，看需求而定。






</pre>