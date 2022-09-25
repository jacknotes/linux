## day01



#### go常用命令

go run 
go build
go test	//单元测试
go tool	//go程序追踪、调试
go mod init
go mod tidy	//在go.mod文件中添加Import的包（未存在go.mod中的包）
go fmt	//格式化文本到go格式
go get -u //下载包


#### godoc
安装godoc第三方包，然后本地启动http服务，访问这个嗠，可以将包的注释以html形式展现。
PS D:\share\study\day01\first\const> go get golang.org/x/tools/cmd/godoc
PS D:\share\study\day01\first\const> godoc -http :6060
using module mode; GOMOD=D:\share\study\day01\first\go.mod



##  day02




### slice

#### append
1. 切片相对于数组最大的特点就是可以追加元素，可以自动扩容
2. 追加的元素放到预留的内存空间里，同时len加1
3. 如果预留空间已用完，则会重新申请一块更大的内存空间，把capacity变成之前的2倍（cap<1024）或1.25倍（cap>1024）。把原内存空间的数据拷贝过来，在新内存空间上执行append操作。

#### 截取子切片
* s := make([]int, 3, 5)	//len=3, cap=5
* sub_slice := s[1:3]		//len=2, cap=4
1. 刚开始，子切片和母切片共享底层的内存空间(底存数组)，修改子切片会反映到母切片上，在子切片上执行append会把新元素放到母切片预留的内存空间上。
2. 当子切片不断执行append，耗完了母切片预留的内存空间，子切片跟母切片就会发生内存分享，此后两个切片没有任何关系。
```
func sub_slice() {
	// 子切片，底层是数组，数组中每个元素大小为8个byte，每个元素都有一个内存地址
	arr := make([]int, 3, 5)
	crr := arr[0:2] //0，1两个元素
	fmt.Println(arr)
	crr[1] = 8
	fmt.Println(arr[1])
	crr = append(crr, 9) //第3个位置
	fmt.Println(arr[2])
	crr = append(crr, 9)                    //第4个位置
	crr = append(crr, 9)                    //第5个位置
	fmt.Println(arr)                        //此时其实是 [0 8 9 9 9]，只是len为3所以输出为3个元素
	fmt.Printf("%p %p\n", &arr[0], &crr[0]) //此时内存地址还是一样

	// 内存分离
	crr = append(crr, 9) //第6个位置，此时crr已经跟arr内存分离，crr会开辟一个新的内存空间，并复制之前内存的值到新内存空间
	crr[1] = 4
	fmt.Println(arr[1])                     //此时输出的还是8，crr不会再影响arr了
	fmt.Printf("%p %p\n", &arr[0], &crr[0]) //内存地址已经不一样了
}
```

#### 切片传参
* go语言函数传参，传的都是值，即传切片会把切片的{arrayPointer, len, cap}这3个字段拷贝一份传进来
* 由于传的是底层数组的指针，所以可以直接修改底层数组里面的元素
```
func update_slice(arr []int) {
	arr[0] = 100
}

func main() {
	crr := []int{2, 3, 4}
	update_slice(crr)
	fmt.Println(crr[0])	//输出为100
}
```

### map
1. 底层还是hash table，无序的
2. 新建1个map，map容量为5，就是slot为5，然后对存取里面的“key”进行unicode，然后对unicode进行对5取余，当有多个key取余数都一样，则此时在同一个slot的地方将会存取两个key（被称为链表），当下次要查找这其中某个key时，步骤是这样的{1首先对要查找的key取余，到达链表。
3. 然后对这个链表进行遍历找到自己要查询的key[此步骤遍历会导致性能下降，所以建议避免形成链表，将map的容量初始化为一个合理的值，如果map容量满了将会重新开辟内存空间，此步骤也会造成开销] }
``` var m = make(map[string]int, 5) ```

```
package main

import "fmt"

func main() {
	var m map[string]int
	// fmt.Println(len(m)) //长度为0
	// m = make(map[string]int)
	// fmt.Println(len(m)) //长度为0
	// m = make(map[string]int, 10)
	// fmt.Println(len(m)) //长度为0
	m = map[string]int{"A": 3, "B": 2}
	// fmt.Println(len(m)) //长度为2
	// m["D"] = 18         //长度为3
	// fmt.Println(len(m)) //长度为2

	// delete(m, "B")
	// for key, value := range m {
	// 	fmt.Printf("key=%s, value=%d\n", key, value)
	// }

	key := "F"
	v, ok := m[key]
	if ok {
		fmt.Println(v)
	} else {
		fmt.Printf("key %s not exists.", key)
	}
}
```

### channel
1. 通道的cap在初始化后，是不能改变的，cap的值是make时的值，len()表示通道的值的长度
2. 当通道的len等于cap时，不能在往里sent值，因为会报错。可以先recv一个值，然后再放一个值。
3. 插入数据是sent，取出数据是recv
4. channel中如果容量满了再放值，则会阻塞，如果channel没有了再取值，也会阻塞。
```
package main

import "fmt"

func main() {
	var ch chan int
	fmt.Printf("channel is nil %t\n", ch == nil)
	fmt.Printf("len of ch is %d\n", len(ch))

	ch = make(chan int, 10)
	fmt.Printf("len of ch is %d\n", len(ch))
	fmt.Printf("cap of ch is %d\n", cap(ch))

	ch <- 1
	ch <- 2
	ch <- 2
	fmt.Printf("len of ch is %d\n", len(ch))

	L := len(ch)
	//遍历管道(环形队列)1, 可以不close()管道，但是建议先关闭close管道再取
	for i := 0; i < L; i++ {
		v := <-ch
		fmt.Println(v)
	}
	// close(ch)	//必须先关闭管道再遍历，特别是下面这种遍历方法
	// for ele := range ch {
	// 	fmt.Println(ele)
	// }
	fmt.Println(len(ch)) //当取出后，管道长度将为0
}
```

### 引用类型
1. slice(会自动扩容)、map(会自动扩容)和channel(不能扩容)是go语言里面的3种引用类型，都可以通过make函数来进行初始化（申请分配内存）
2. 因为它们都包含一个指向底层数据结构的指针，所以称之为“引用”类型
3. 引用类型未初始化时都是nil, 可以对它们执行len()函数，返回0





## day03



### 流程控制

#### if
```
package main

import (
	"fmt"
	"time"
)

func goo() {
	m := make(map[int]string, 10)
	m[1] = "abc"
	if value, exists := m[2]; exists {	//value是if块的局部变量，放在外面则是整个goo函数的变量
		fmt.Println(value)
	} else {
		fmt.Println("key 2 not exists!")
	}

}

func if_nest() {
	now := time.Now()
	weekday := now.Weekday()
	hour := now.Hour()
	fmt.Println(weekday, hour)
	if weekday.String() != "Saturday" && weekday.String() != "Sunday" {
		if hour <= 9 && hour >= 7 {
			fmt.Println("not go")
		} else {
			fmt.Println("go")
		}
	} else {
		fmt.Println("go")
	}
}

func main() {
	goo()
	if_nest()
}
```

#### switch
```
package main

import (
	"fmt"
)

func basic() {
	color := "yellow"
	switch color {
	case "red": // if color == "red"
		fmt.Println("color is red")
	case "green": // if color == "green"
		fmt.Println("color is green")
	case "black": // if color == "black"
		fmt.Println("color is black")
	default: // else
		fmt.Println("都不是")
	}
}

func add(n int) int {
	return n + 1
}

func sub(n int) int {
	return n - 1
}

func pos(n int) bool {
	return n > 0
}
func expression() {
	var a int = 10
	const B = 11
	switch add(a) {
	default:
		fmt.Println("都不是")
	case 5:
		fmt.Println("sum is 5")
	// case 11:
	// 	fmt.Println("sum is 11")
	// case sub(12):
	// 	fmt.Println("sum is 12 - 1")
	case 7, 8, B:
		fmt.Println("sum is 7 or 8 or B")
	case 12:
		fmt.Println("sum is 12")
	}
}

func switch_condition() {
	switch {
	case 5 > 8:
		fmt.Println("5 > 8")
	case add(5) == 9:
		fmt.Println("add(5) == 9")
	case pos(5):
		fmt.Println("5 > 0")
	}
}

func main() {
	basic()
	expression()
	switch_condition()
}
--- fallthrough
func fall(age int) {
	switch {
	case age > 50:
		fmt.Println("当总统")
		fallthrough // 意为执行到这里还要往下执行一次，可以配置多次
	case age > 25:
		fmt.Println("生孩子")
		fallthrough // 意为执行到这里还要往下执行一次，可以配置多次
	case age > 22:
		fmt.Println("结婚")
	case age > 18:
		fmt.Println("开车")
	}
}

func main() {
	fall(60)
}
--- switch type
func switch_type() {
	var num interface{} = 6.5 // interface类型Java的Object对象，所有类型的父类
	switch num.(type) {       // 判断num的具体类型，x.(type)只能放到switch使用
	case int:
		fmt.Println("num is int")
	case float64:
		fmt.Println("num is float64")
	case byte, string, bool:
		fmt.Println("num is byte or string or bool")
	default:
		fmt.Println("以上猜测都不对")
	}
	// 将类型赋予变量
	switch value := num.(type) {
	case int:
		fmt.Printf("num is %d\n", value)
	case float64:
		fmt.Printf("num is %.2f\n", value)
	case byte, string, bool:
		fmt.Printf("num is %v\n", value)
	default:
		fmt.Println("num是其它类型")
	}
	// 等价于上面那个switch
	switch num.(type) {
	case int:
		value := num.(int)	//跟x.type一样只能switch中使用
		fmt.Printf("num is %d\n", value)
	case float64:
		value := num.(float64)
		fmt.Printf("num is %.2f\n", value)
	case byte:
		value := num.(byte)
		fmt.Printf("num is %d\n", value)
	default:
		fmt.Println("num是其它类型")
	}
}

func main() {
	switch_type()
}
```



#### for循环

1. 初始化变量可以放在for上面
2. 后续操作可以放在for块内部
3. 只有条件判断时，前后的分别可以不要，否则都需要分号
4. for{}是一个无限循环，相当于while true

```
package main

import "fmt"

func basic() {
	arr := [...]int{1, 2, 3, 4, 5, 6}
	// for i := 0; i < len(arr); i++ {
	// 	fmt.Printf("%d %d\n", i, arr[i])
	// }
	// fmt.Println("等价============")
	// for i := 0; i < len(arr); {
	// 	fmt.Printf("%d %d\n", i, arr[i])
	// 	i++
	// }
	// fmt.Println("等价============")
	// i := 0
	// for i < len(arr) {
	// 	fmt.Printf("%d %d\n", i, arr[i])
	// 	i++
	// }

	for sum, i := 0, 0; i < len(arr) && sum < 100; sum, i = sum+arr[i], i+1 {
		fmt.Printf("sum=%d\n", sum)
	}
}

func main() {
	basic()
}
--- for range
1. 遍历数组或切片
	for i, ele := range arr
2. 遍历string
	for i, ele := range "我会唱ABC"		//ele是rune类型
3. 遍历map, go不保证遍历的顺序
	for key, value := range m
4. 遍历channel, 遍历前一定要先close
	for ele := range ch
5. for range拿到的是数据的拷贝
---
func for_range() {
	arr := [...]int{1, 2, 3, 4, 5, 6}
	str := "我会唱ABC"

	fmt.Println(len(arr))
	for i, ele := range arr {
		fmt.Printf("%d %d\n", i, ele)
	}
	fmt.Println("============")

	fmt.Println(len(str)) //以byte计算长度
	for i, ele := range str {
		fmt.Printf("%d %c\n", i, ele)
	}
	fmt.Println("============")
	brr := []byte(str)
	fmt.Println(len(brr)) //以byte计算长度
	for i, ele := range brr {
		fmt.Printf("%d %d\n", i, ele)
	}
	fmt.Println("============")

	m := map[int]int{1: 1, 2: 2, 3: 3, 4: 4, 5: 5}
	for key, value := range m {
		fmt.Printf("%d %d\n", key, value)
	}
	fmt.Println("============")
	for key, value := range m { //输出最先最后不一样，但是元素之间的连接顺序是一样的
		fmt.Printf("%d %d\n", key, value)
	}
	fmt.Println("============")

	ch := make(chan int, 10)
	for i := 0; i < 10; i++ {
		ch <- i
	}
	close(ch)
	for ele := range ch {
		fmt.Println(ele)
	}
}
func main() {
	for_range()
}
```

#### break和continue

1. break与continue用于控制 for循环的代码流程，并且只针对最靠近自己的外层for循环
2. break: 退出for循环，且本轮break下面的代码不再执行
3. continue: 本轮continue下面的代码不再执行，进入for循环的下一轮

```
package main

import "fmt"

func break_for() {
	arr := []int{1, 2, 3, 4, 5}
	for i, ele := range arr {
		fmt.Println(i, ele)
		if i > 2 {
			break
		}
		fmt.Printf("第%d行\n", i+1)
	}
}

func continue_for() {
	arr := []int{1, 2, 3, 4, 5}
	for i, ele := range arr {
		fmt.Println(i, ele)
		if i > 2 {
			continue
		}
		fmt.Printf("第%d行\n", i+1)
	}
}

func complex_break_continue() {
	const SIZE = 5
	arr := [SIZE][SIZE]int{{1, 2, 3, 4, 5}, {1, 2, 3, 4, 5}, {1, 2, 3, 4, 5}, {1, 2, 3, 4, 5}, {1, 2, 3, 4, 5}}
	for i := 0; i < SIZE; i++ {
		fmt.Printf("第%d行\n", i)
		if i%2 == 1 {
			for j := 0; j < SIZE; j++ {
				fmt.Printf("第%d列\n", j)
				if arr[i][j]%2 == 0 {
					continue
				}
				fmt.Printf("将要第%d列\n", j+1)
			}
			break //只跳出自己所在的for循环
		}
	}
}

func main() {
	// break_for()
	// continue_for()
	complex_break_continue()
}
```

#### goto与Label

break、continue与Label

1. break、continue与Label结合使用可以跳转到更外层的for循环
2. continue和break针对的Label必须写在for前面，而goto可以针对任意位置的Label

```
案例1：
var i int = 4
MY_LABEL:
	i += 3
	fmt.Println(i)
	goto MY_LABEL  //返回定义MY_LABEL的那一行，把代码再执行一遍（会进入一个无限循环）
	
案例2：
if i%2 == 0{
	goto L1
} else {
	goto 2
}
L1: //后定义Label
	i += 3
L2:	//Lable定义后必须在代码的某个地方被使用
	i *= 3
	
案例3：	//退出for循环，实现break的功能，甚至更强大
for i := 0; i < SIZE; i++ {
L2:
	for j := 0; j < SIZE; j++ {
		goto L1:	//goto可以跳出指定的位置，不受多层for循环限制，而break会受for循环层次限制
	}
}
L1: 
	xxx

代码：
package main

import "fmt"

func basic() {
	var i int = 4
abc:
	i += 3
	i *= 4
	fmt.Println(i)
	if i > 200 {
		return
	}
	goto abc
}

func if_goto() {
	var i int = 4
	if i%2 == 0 {
		goto L1 //会走到L1，完成L1后还会继续L2
	} else {
		goto L2
	}
L1:
	i += 3
	fmt.Println(i)
L2:
	i *= 3
	fmt.Println(i)

}

func main() {
	basic()
	if_goto()
}
```



#### 结构体

1. 结构体创建、访问与修改
2. 结构体指针
3. 结构体嵌套
4. 深拷贝与浅拷贝    



##### 1. 结构体创建、访问与修改

###### 1. 1 定义结构体

```
package main

import (
	"fmt"
	"time"
)

type User struct {
	id            int
	Score         float64
	name, address string
	enrollment    time.Time
}

func main() {
	var ws User
	fmt.Printf("id %d, Score %g, name [%s], address [%s], enrollment %v\n", ws.id, ws.Score, ws.name, ws.address, ws.enrollment)
	ws = User{Score: 100, name: "Jack"}
	ws.Score = 93.5
	ws.enrollment = time.Now()

	a := ws.id + 24
	fmt.Printf("a=%d\n", a)

}
```

###### 1.2 成员函数（方法）

```
package main

import (
	"fmt"
	"time"
)

type User struct {
	id            int
	Score         float64
	name, address string
	enrollment    time.Time
}

func (user User) hello(man string) string {
	return "hello" + man + ", I'm" + user.name
}

func hello(man string, user User) string {
	return "hello" + man + ", I'm" + user.name
}

func main() {
	var ws User
	ws = User{Score: 100, name: "Jack"}
	fmt.Println(hello("jack", ws))
	fmt.Println(ws.hello("jack"))
}
```

###### 1.3 匿名结构体

```
#自定义结构体
type User struct {
	id int
	name string
	addr string
	tel string
}
var user User = User{1, "str1", "str2", "str3"}

#匿名结构体，只使用一次
var user struct {
	id int
	name string
	addr string
	tel string
}
user =  struct {
	id int
	name string
	addr string
	tel string
}{10, "str1", "str2", "str3"}
或者
var user = struct {
	id int
	name string
	addr string
	tel string
}{10, "str1", "str2", "str3"}

#结构体中含有匿名成员
type Student struct {
	Id int
	string //匿名字段
	float32 //直接使用数据类型作为字段名，所以匿名字段中不能出现重复的数据类型
}
var stu = Student{Id: 1, string: "zcy", float32: 79.5}
fmt.Printf("anonymous_member string member=%s float member=%f\n", stu.string, stu.float32)

```



##### 2. 结构体指针

###### 2.1 创建结构体指针

```
var u User
user := &u //通过取址符&得到指针
user = &User{ //直接创建结构体指针
    Id: 3, Name: "zcy", addr: "beijing",
}
user = new(User) //通过new()函数实体化一个结构体，并返回其指针

```

###### 2.2 构造函数

```
//构造函数。返回指针是为了避免值拷贝
func NewUser(id int, name string) *User {
	return &User{
		Id: id,
		Name: name,
		addr: "China",
		Score: 59,
	}
}
```

```
// 案例
package main
import "fmt"

type Student struct {
	Name string
	string
	int
}

func NewStudent(name string, city string, age int) *Student {
	return &Student{name, city, age}
}

func main() {
	stu := NewStudent("jack", "ShangHai", 28)
	fmt.Println(*stu)
}

```

###### 2.3 方法接收指针

```
//user传的是值，即传的是整个结构体的拷贝。在函数里修改结构体不会影响原来的结构体
func hello(u user, man string) {
    u.name = "杰克"
    fmt.Println("hi " + man + ", my name is " + u.name)
}
//传的是user指针，在函数里修改user的成员会影响原来的结构体
func hello2(u *user, man string) {
    u.name = "杰克"
    fmt.Println("hi " + man + ", my name is " + u.name)
}

//把user理解为hello()的参数，即hello(u user, man string)
func (u user) hello(man string) {
    u.name = "杰克"
    fmt.Println("hi " + man + ", my name is " + u.name)
}
//可以理解为hello2(u *user, man string)
func (u *user) hello2(man string) {
    u.name = "杰克"
    fmt.Println("hi " + man + ", my name is " + u.name)
}

```

##### 3. 结构体嵌套

###### 3.1 结构体嵌套

```
type user struct {
    name string
    sex byte
}
type paper struct {
    name string
    auther user //结构体嵌套
}
p := new(paper)
p.name = "论文标题"
p.auther.name = "作者姓名"
p.auther.sex = 0
type vedio struct {
    length int
    name string
    user//匿名字段,可用数据类型当字段名
}

```

###### 3.2 字段名冲突

```
v := new(vedio)
v.length = 13
v.name = "视频名称"
v.user.sex = 0 //通过字段名逐级访问
v.sex = 0 //对于匿名字段也可以跳过中间字段名，直接访问内部的字段名
v.user.name = "作者姓名" //由于内部、外部结构体都有name这个字段，名字冲突了，所以需要指定中间字段名

```



#### 4 深拷贝与浅拷贝

###### 4.1 拷贝

```
// 示例1
type User struct {
	Name string
}
type Vedio struct {
	Length int
	Author User
}

vedio1 := Vedio{25, "吴承恩"}
vedio2=vedio1	//赋值拷贝

// 示例2
type User struct {
	Name string
}
type Vedio struct {
	Length int
	Author *User	//为指针结构体，后面vedio1和vedio2无论哪个更改都会生效
}
vedio1 := Vedio{Length: 25, Author: new(User)}
vedio1.Author.Name = "吴承恩"
vedio2=vedio1	//赋值拷贝

```

###### 4.2 深拷贝与浅拷贝

```
深拷贝，拷贝的是值，比如Vedio.Length
浅拷贝，拷贝的是指针，比如Vedio.Author
深拷贝开辟了新的内存空间，修改操作不影响原先的内存
浅拷贝指向的还是原来的内存空间，修改操作直接作用在原内存空间上

```

###### 4.3 结构体slice传参

```
users := []User{{Name: "康熙"}}
func update_users(users []User) {
    users[0].Name = "光绪"
}
传slice，对slice的3个字段进行了拷贝，拷贝的是底层数组的指针，所以修改底层数组的元素会反应到原数组上
type slice struct {
    array unsafe.Pointer
    len int
    cap int
}
```



## day04



### Go语言函数基础

* 函数的基本形式
* 匿名函数
* 闭包
* 延迟调用defer
* 异常处理



#### 函数的基本形式

```
## 形参与实参
//a,b是形参，形参是函数内部的局部变量，实参的值会拷贝给形参
func argf(a int, b int) { //注意大括号{不能另起一行
	a = a + b //在函数内部修改形参的值，实参的值不受影响
}
var x, y int = 3, 6
argf(x, y) //x,y是实参
形参可以有0个或多个
参数类型相同时可以只写一次，比如argf(a,b int)


## 参数传指针
如果想通过函数修改实参，就需要指针类型
func argf(a, b *int) { 
*a = *a + *b
*b = 888
}
var x, y int = 3, 6
argf(&x, &y)


## 传引用和传引用的指针
slice、map、channel都是引用类型，它们作为函数参数时其实跟普通struct没什么区别，都是对struct内部的各个字段做一次拷贝传到函数内部
func slice_arg_1(arr []int) { //slice作为参数，实际上是把slice的arrayPointer、len、cap拷贝了一份传进来
        arr[0] = 1 //修改底层数据里的首元素
        arr = append(arr, 1) //arr的len和cap发生了变化，不会影响实参
}


## 函数返回值
可以返回0个或多个参数
可以在func行直接声明要返回的变量
return后面的语句不会执行
无返回参数时return可以不写
func returnf(a, b int) (c int) { //返回变量c已经声明好了
a = a + b
c = a //直接使用c
return //由于函数要求有返回值，即使给c赋过值了，也需要显式写return
}


## 不定长参数
func variable_ength_arg(a int, other ...int) int { 
sum := a
for _, ele := range other {//不定长参数实际上是slice类型
	sum += ele
}
fmt.Printf("len %d cap %d\n", len(other), cap(other))
return sum
}
variable_ength_arg(1)
variable_ength_arg(1,2,3,4)

#append函数接收的就是不定长参数
arr = append(arr, 1, 2, 3)
arr = append(arr, 7)
arr = append(arr)
slice := append([]byte("hello "), "world"...) ...自动把"world"转成byte切片，等价于[]byte("world")...
slice2 := append([]rune("hello "), []rune("world")...) //需要显式把"world"转成rune切片


## 递归函数
func Fibonacci(n int) int {
if n == 0 || n == 1 {
	return n //凡是递归，一定要有终止条件，否则会进入无限循环
}
return Fibonacci(n-1) + Fibonacci(n-2) //递归调用函数自身
}

#递归函数案例
//计算斐波那契数列的第n个值
//
//斐波那契数列以如下被以递推的方法定义： F (0)=0， F (1)=1, F (n)= F (n - 1)+ F (n - 2)
//
//斐波那契数列前10个数为：0，1，1，2，3，5，8，13，21，34
func Fibonacci(n int) int {
	if n == 0 || n == 1 {
		return n //凡是递归，一定要有终止条件，否则会进入无限循环
	}
	return Fibonacci(n-1) + Fibonacci(n-2) //递归调用函数自身
}

```

#### 匿名函数

```
//匿名函数
var sum = func(a, b int) int {
	return a + b
}

func function_arg1(f func(a, b int) int, b int) int { //f参数是一种函数类型（函数类型看上去比较冗长）
	a := 2 * b
	return f(a, b)
}

type foo func(a, b int) int //foo是一种函数类型
func function_arg2(f foo, b int) int { //参数类型看上去乘洁多了
	a := 2 * b
	return f(a, b)
}
```

#### 闭包

•闭包（Closure）是引用了自由变量的函数

•自由变量将和函数一同存在，即使已经离开了创造它的环境

•闭包复制的是原对象的指针

```
package main

import "fmt"

//闭包（Closure）是引用了自由变量的函数。自由变量将和函数一同存在，即使已经离开了创造它的环境。
func sub() func() {
	i := 10
	fmt.Printf("%p\n", &i)
	b := func() {
		fmt.Printf("i addr %p\n", &i) //闭包复制的是原对象的指针
		i--                           //b函数内部引用了变量i
		fmt.Println(i)
	}
	return b //返回了b函数，变量i和b函数将一起存在，即使已经离开函数sub()
}

// 外部引用函数参数局部变量
func add(base int) func(int) int {
	return func(i int) int {
		fmt.Printf("base addr %p\n", &base)
		base += i
		return base
	}
}

func main() {
	b := sub()
	b()
	b()
	fmt.Println()

	tmp1 := add(10)
	fmt.Println(tmp1(1), tmp1(2)) //11,13
	// 此时tmp1和tmp2不是一个实体了
	tmp2 := add(100)
	fmt.Println(tmp2(1), tmp2(2)) //101,103
}

//go run function/closure/main.go

```

#### 延迟调用defer

•defer用于注册一个延迟调用（在函数返回之前调用）

•defer典型的应用场景是释放资源，比如关闭文件句柄，释放数据库连接等

•如果同一个函数里有多个defer，则后注册的先执行

•defer后可以跟一个func， func 内部如果发生panic，会把panic暂时搁置，当把其他defer执行完之后再来执行这个panic，panic之后的代码就不会再被执行了。

•defer后不是跟func，而直接跟一条执行语句，则相关变量在注册defer时被拷贝或计算

```
## defer执行顺序
func basic() {
fmt.Println("A")
defer fmt.Println(1) fmt.Println("B")
//如果同一个函数里有多个defer，则后注册的先执行
defer fmt.Println(2)
fmt.Println("C")
}

## defer func
func defer_exe_time() (i int) {
i = 9
defer func() { //defer后可以跟一个func,defer中的func不会先赋值，只有在被调用执行时才赋值
	fmt.Printf("i=%d\n", i) //打印5，而非9
}()
defer fmt.Printf("i=%d\n", i) //变量在注册defer时被拷贝或计算
return 5 //先返回5给变量i，等defer结束后再执行return退出 
}


/*
	defer典型的应用场景是释放资源，比如关闭文件句柄，释放数据库连接等
*/
package main

import (
	"fmt"
)

func basic() {
	fmt.Println("A")
	defer fmt.Println(1) //defer用于注册一个延迟调用（在函数返回之前调用）
	fmt.Println("B")
	defer fmt.Println(2) //如果同一个函数里有多个defer，则后注册的先执行
	fmt.Println("C")
	defer fmt.Println(3)
	fmt.Println("D")
}

func defer_exe_time() (i int) {
	i = 9
	defer func() { //defer后可以跟一个func
		fmt.Printf("first i=%d\n", i) //打印5，而非9。充分理解“defer在函数返回前执行”的含义，不是在“return语句前执行defer”
	}()
	defer func(i int) {
		fmt.Printf("second i=%d\n", i) //打印9
	}(i)
	defer fmt.Printf("third i=%d\n", i) //defer后不是跟func，而直接跟一条执行语句，则相关变量在注册defer时被拷贝或计算
	return 5
}

func defer_panic() {
	defer fmt.Println(1)
	n := 0
	// defer fmt.Println(1 / n) //在注册defer时就要计算1/n，发生panic，第3个defer根本就没有注册。发生panic时首先会去执行已注册成功的defer，然后打印错误调用堆栈，最后exit(2)
	defer func() {
		fmt.Println(1 / n)   //defer func 内部发生panic，main协程不会exit，其他defer还可以正常执行
		defer fmt.Println(2) //上面那行代码发生发panic，所以本行的defer没有注册成功
	}()
	defer fmt.Println(3)
}

func main() {
	basic()
	fmt.Println()
	defer_exe_time()
	fmt.Println()
	defer_panic()
}

//go run function/defer/main.go
```

#### 异常处理

```
## 异常机制
func divide(a, b int) (int, error) {// go语言没有try catch，它提倡返回error
if b == 0 {
	return -1, errors.New("divide by zero")
}
return a / b, nil
}
if res, err := divide(3, 0); err != nil {//函数调用方判断error是否为nil
        fmt.Println(err.Error())
}


## 自定义error
type PathError struct {    //自定义error
path string
op string
createTime string
message string
}func (err PathError) Error() string {    //error接口要求实现Error() string方法
	return err.createTime + ": " + err.op + " " + err.path + " " + err.message
}


## panic
何时会发生panic:
	1. 运行时错误会导致panic，比如数组越界、除0
	2. 程序主动调用panic(error)
panic会执行什么：
	1. 逆序执行当前goroutine的defer链（recover从这里介入）
	2. 打印错误信息和调用堆栈
	3. 调用exit(2)结束整个进程

## recover
recover会阻断panic的执行
func soo(a, b int) {
	defer func() {
		//recover必须在defer中才能生效
		if err := recover(); err != nil {	fmt.Printf("soo函数中发生了panic:%s\n", err)
		}
	}()
	panic(errors.New("my error"))
}


## 异常处理代码
package main

import (
	"errors"
	"fmt"
	"time"
)

//自定义error
type PathError struct {
	path       string
	op         string
	createTime string
	message    string
}

func NewPathError(path, op, message string) PathError {
	return PathError{
		path:       path,
		op:         op,
		createTime: time.Now().Format("2006-01-02"),
		message:    message,
	}
}

//error接口要求实现Error() string方法
func (err PathError) Error() string {
	return err.createTime + ": " + err.op + " " + err.path + " " + err.message
}

func divide(a, b int) (int, error) {
	if b == 0 {
		return -1, errors.New("divide by zero")
	}
	return a / b, nil
}

func delete_path(path string) error {
	//如果文件路径不存在，就返回一个error；否则返回nil
	return NewPathError(path, "delete", "path not exists") //返回自定义error
}

func soo() {
	fmt.Println("enter soo")
	defer func() { //去掉这个defer试试，看看panic的流程
		//recover必须在defer中才能生效
		if err := recover(); err != nil {
			fmt.Printf("soo函数中发生了panic:%s\n", err)
		}
	}()
	fmt.Println("regist recover")
	defer fmt.Println("hello")
	n := 0
	_ = 3 / n //除0异常，发生panic，下一行的defer没有注册成功
	defer fmt.Println("how are you")
}

func main() {
	if res, err := divide(3, 0); err == nil {
		fmt.Println(res)
	} else {
		fmt.Println(err.Error())
	}
	fmt.Println()
	soo()
	fmt.Println("soo没有使main协程退出")
}

//go run function/panic/main.go
```





### Go语言接口编程



#### 接口的基本概念

```
## 接口的定义
//接口是一组行为规范的集合
type Transporter interface { //定义接口。通常接口名以er结尾
	//接口里面只定义方法，不定义变量
	move(src string, dest string) (int, error) //方法名 (参数列表) 返回值列表
	whistle(int) int //参数列表和返回值列表里的变量名可以省略
}


## 接口的实现
type Car struct { //定义结构体时无需要显式声明它要实现什么接口,一个struct可以同时实现多个接口
	price int
}
//只要结构体拥有接口里声明的所有方法，就称该结构体“实现了接口”
func (car Car) move(src string, dest string) (int, error) {
	return car.price, nil
}
func (car Car) whistle(n int) int {
	return n
}


## 接口的本质
接口值有两部分组成, 一个指向该接口的具体类型的指针和另外一个指向该具体类型真实数据的指针
car := Car{100}
var transporter Transporter
transporter = car
transporter.whistle(3)


## 接口的使用
func transport(src, dest string, transporter Transporter) error {
	 _,err := transporter.move(src, dest)
	return err
}
var car Car		//Car实现了Transporter接口
var ship Shiper	// Shiper实现了Transporter接口
transport("北京", "天津", car)	//会调用car对象的move方法
transport("北京", "天津", ship)	//会调用ship对象的move方法


## 接口的赋值
func (car Car) whistle(n int) int {…}//方法接收者用值
func (ship *Shiper) whistle(n int) int {…} //方法接收者用指针，则实现接口的是指针类型
car := Car{}
ship := Shiper{}
var transporter Transporter
transporter = car 	//whistle方法接收者是值，所以这里传值类型
transporter = &car     //whistle方法接收者是值，所以指针类型同样也实现了
transporter = &ship	  //whistle方法接收者是指针，所以这里只能传指针类型


# 代码
------
package main

// 定义Interface
type Transporter interface {
	move(string, string) (int, error)
	say(int)
}

type Humna interface {
	think(a int)
}

// 定义结构体实现接口
type Car struct {
}

func (Car) move(string, string) (int, error) {
	return 1, nil
}

func (Car) say(int) {

}

func (Car) think(a int) {

}

func foo(t Transporter) {

}

func main() {
	var t Transporter
	car := Car{}
	t = car
	t.say(2)

	foo(t)
	foo(car)

	var h Humna
	h = car
	h.think(4)
}
------
```

#### 接口嵌入

```
type Transporter interface {
	whistle(int) int
}
type Steamer interface {
	Transporter //接口嵌入。相当于Transporter接口定义的行为集合是Steamer的子集
	displacement() int
}

```

#### 空接口

```
空接口类型用interface{}表示，注意有{}
	var i interface{} 
空接口没有定义任何方法，因此任意类型都实现了空接口
	var a int = 5
	i = a
func square(x interface{}) {}该函数可以接收任意数据类型
slice的元素、map的key和value都可以是空接口类型

	sli := make([]interface{}, 5, 10)
	sli = append(sli, 1)
	sli = append(sli, "string")

	m := make(map[interface{}]interface{},5)
	m[1] = "string"
	m["str"] = 100
```

#### 类型断言

```
if v, ok := i.(int); ok {//若断言成功，则ok为true，v是具体的类型
	fmt.Printf("i是int类型，其值为%d\n", v)
} else {
	fmt.Println("i不是int类型")
}
当要判断的类型比较多时，就需要写很多if-else，更好的方法是使用switch i.(type)


## switch type
switch v := i.(type) {    //隐式地在每个case中声明了一个变量v
case int:  //v已被转为int类型
	fmt.Printf("ele is int, value is %d\n", v)
	//在 Type Switch 语句的 case 子句中不能使用fallthrough
case float64:      //v已被转为float64类型
	fmt.Printf("ele is float64, value is %f\n", v)
case int8, int32, byte: //如果case后面跟多种type，则v还是interface{}类型
	fmt.Printf("ele is %T, value is %d\n", v, v)
}
```



#### 面向接口编程

```
在框架层面全是接口
具体的实现由不同的开发者去完成，每种实现单独放到一个go文件里，大家的代码互不干扰
通过配置选择采用哪种实现，也方便进行效果对比

```











